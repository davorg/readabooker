# How ReadABooker works

ReadABooker is a static catalogue of Booker Prize shortlisted novels and winners,
browsable by year, author, and title. A Perl program reads the SQLite database,
renders Template Toolkit templates, and writes HTML and a sitemap into `docs/`.
The published site needs no Perl application or database server.

This guide describes the repository inspected on 20 September 2026. File links
refer to the implementation; data counts are a snapshot, not build requirements.

## Repository map

| Location | Purpose |
| --- | --- |
| [`booker.db`](booker.db) | Current SQLite data and schema; the build's source of catalogue content. |
| [`bin/build`](bin/build) | Build entry point. |
| [`lib/Booker/App.pm`](lib/Booker/App.pm) | Build orchestration, template configuration, page generation, redirects, and sitemap. |
| [`lib/Booker/Page.pm`](lib/Booker/Page.pm) | Metadata object for pages that do not represent database rows. |
| [`lib/Booker/Schema.pm`](lib/Booker/Schema.pm) | Database connection and DBIx::Class schema loading. |
| [`lib/Booker/Schema/Result/`](lib/Booker/Schema/Result/) | Row models, relationships, URL generation, and metadata. |
| [`lib/Booker/Schema/ResultSet/`](lib/Booker/Schema/ResultSet/) | Queries for ordering and grouping records. |
| [`lib/Booker/Role/`](lib/Booker/Role/) | Shared site defaults and previous/next navigation. |
| [`src/`](src/) | Page-specific Template Toolkit templates (`.html.tt`). |
| [`tt_lib/`](tt_lib/) | Shared layout, macros, and redirect template. |
| [`docs/`](docs/) | Generated pages **and** maintained static assets and hosting files. |
| [`bin/`](bin/) | Import, inspection, and data-maintenance scripts as well as the builder. |
| `Booker*.csv` | Historical import data and annual shortlist files. Not read during a build. |
| [`booker.sql`](booker.sql) | Current schema definition for creating an empty database, without catalogue data. |
| [`dbic.conf`](dbic.conf) | DBIx::Class schema-loader configuration. Not used by the site build. |

## Build and preview

Run commands from the repository root:

```sh
perl bin/build
python3 -m http.server 8000 --directory docs
```

Then visit `http://localhost:8000/`. A local HTTP server supports the site's
root-relative links; opening an HTML file directly is not an equivalent preview.
Canonical URLs still point to `https://readabooker.com`, and external scripts,
images, fonts, and embeds remain active in a local preview.

The working directory matters. Although `bin/build` locates `lib/` and the app's
root relative to its own path, the default database name is `booker.db` relative
to the working directory. The layout also reads `docs/css/style.css` relative to
that directory to obtain its modification time.

### Dependencies

There is no dependency manifest or lockfile in the repository. The main build
uses these non-core Perl modules, including their dependencies:

- `Moo`, `Moose`, `MooseX::NonMoose`, `MooseX::MarkAsMethods`,
  `Types::Standard`, and `namespace::autoclean`.
- `DBIx::Class`, `DBIx::Class::Schema::ResultSetNames`, and `DBD::SQLite`.
- `Template` (Template Toolkit).
- `MooX::Role::JSON_LD`, `MooX::Role::SEOTags`, and `Text::Unidecode`.

The code uses Perl signatures and other modern language features. The build was
verified with Perl 5.42.3; a minimum supported Perl version is not established by
the repository. Auxiliary scripts have additional dependencies described below.

### Build sequence

1. `bin/build` adds the local `lib/` directory to Perl's module search path,
   constructs `Booker::App` with the repository root, and calls `build`.
2. The app lazily connects through `Booker::Schema->get_schema`. This uses
   `dbi:SQLite:booker.db` and SQLite's Unicode fallback string mode.
3. It obtains `Author`, `Event`, and `Book` resultsets and creates a Template
   Toolkit instance with `tt_lib/` and `src/` as include paths and `docs/` as
   the output directory.
4. It builds the home, about, contact, and privacy pages, then the year, author,
   and title indexes and their individual detail pages.
5. It writes two legacy author redirects and finally `docs/sitemap.xml`.

Each call to `write_page` requires an `object` for metadata. A path ending in `/`
gets `index.html` appended. Template output is UTF-8; template failures abort
the build. Indexable objects contribute their URL paths to the sitemap.
Every sitemap entry gets the build's local date as `lastmod`, regardless of
whether that page's content changed.

This is a full render, with no incremental build or cleanup stage. It overwrites
pages at their current paths but leaves obsolete files behind if records or
slugs change. Output is written in place, so a failed build can leave a mixture
of old and newly rendered pages.

**Do not delete `docs/` to obtain a clean build.** Its CSS, images, and hosting
files have no asset-copy step that would restore them. For an isolated build,
copy the repository, including these assets and the database, to a temporary
directory and run the builder there.

## Data model

The current database contains four application tables and one view:

| Object | Important fields and relationships |
| --- | --- |
| `person` | `id`, `name`, `sort_name`, `slug`, `biography`. People can be authors, judges, or both. |
| `author` (view) | People joined to books by `book.author_id`, grouped by person, with `books_count`. Only people with books appear. |
| `event` | `id`, `year`, `slug`. One prize event with many books and judge assignments. `year` is text, allowing labels such as the Lost Booker. |
| `book` | `id`, `title`, `sort_title`, `author_id`, `event_id`, `is_winner`, `asin`, `slug`, `blurb`, `isbn13`, `isbn_source`. Each book belongs to one person and one event. |
| `judge` | `event_id`, `person_id`, `is_chair`, with a composite primary key on the two IDs. Links people to events. |

At inspection there were 473 people, 233 authors, 58 events, 339 books, and 280
judge assignments. The newest event was 2025. All books had non-null slugs,
ISBN-13 values, and blurbs, and none retained the importer's `XXXXXX` ASIN.

`booker.sql` recreates the current tables, index, and `author` view. There is no
`entry` join table: `event_id` and `is_winner` live on `book`.

To create an empty database, run this from the repository root with a new
destination filename:

```sh
sqlite3 -bail /tmp/readabooker-empty.db < booker.sql
```

This creates only the schema, not the catalogue records required for a full
site build. Use a copy of the supplied `booker.db` when you need the existing
catalogue. Do not apply the DDL to that populated database: it is a creation
script, not an upgrade or data-loading script.

For future schema changes, update `booker.sql` and the ORM mappings together
with the database change. Verify the DDL against an empty temporary database,
comparing columns, defaults, keys, indexes, and views with the updated catalogue
database. Keep custom ORM code below the schema-loader boundaries when
regenerating mappings. There is no checked-in migration chain; any migration
of an existing database needs to be handled separately.

### ORM responsibilities

The `Result` classes map database fields and relationships. `Book` exposes both
`person` (the underlying person row) and `author` (the author view).
`Event` exposes its books and judges; judge rows expose their person. The build
uses `Author` for author pages rather than generating pages for every person.

The generated portions of these classes have schema-loader boundary comments.
Custom methods and relationships live below those boundaries. `dbic.conf`
configures regeneration into `lib/`, including the relationship-name mapping
that calls the book's underlying author relationship `person`.

Resultset methods order books by `sort_title`, people by `sort_name`, and events
by descending `year`. They also produce the letter and decade lists used by
index navigation. Titles beginning with a non-ASCII-A–Z character in their
sort key are grouped under `#`; author letters come directly from `sort_name`.
Decades are derived from the first three characters of the event's year.

`Booker::Role::PrevNext` selects the nearest lower or higher sort key for detail
page navigation. It uses `sort_title`, `sort_name`, or `year`, depending on the
model. This is value-based navigation, with no wraparound or tie-breaker for
equal sort keys.

## Pages, templates, and presentation

| URL | Template under `src/` | Content |
| --- | --- | --- |
| `/` | `index.html.tt` | Introductory material and a carousel of recent winners. |
| `/about/`, `/contact/`, `/privacy/` | Corresponding `index.html.tt` | Static editorial content; contact embeds a Google Form. |
| `/year/` | `year/index.html.tt` | Events grouped by decade, newest first. |
| `/year/<slug>/` | `year/year.html.tt` | Judges and books for an event, or an unannounced-shortlist message. |
| `/author/` | `author/index.html.tt` | Authors grouped alphabetically by sort name. |
| `/author/<slug>/` | `author/author.html.tt` | Author's books and optional biography. |
| `/title/` | `title/index.html.tt` | Books grouped alphabetically by sort title. |
| `/title/<slug>/` | `title/title.html.tt` | Book details and optional blurb. |

Detail paths come from database slugs. The home-page carousel takes the five
most recent events with a winner, then one winning book from each. `get_winner`
returns the first matching book, so a tied event contributes only one winner to
the carousel; its year page can show all books marked as winners.

Template Toolkit pre-processes `book_widgets.tt`, `book.tt`, and `prev_next.tt`
to define shared macros, then wraps each page in [`tt_lib/page.tt`](tt_lib/page.tt).
The layout supplies navigation, footer, metadata, CSS and JavaScript references,
and the page's rendered content. `STRICT` is disabled, so undefined template
values need not fail the build.

- `book.tt` defines `display_book`: title and author links, winner/shortlist
  badges, and purchase/cover widgets. It suppresses redundant fields according
  to whether the current template is a title, author, or year page.
- `book_widgets.tt` provides cover images and Bookshop.org/Amazon buttons.
  Covers use Open Library with `isbn13`, with a browser-side Amazon image
  fallback using `asin`. Bookshop links use affiliate ID `16772`.
- `prev_next.tt` renders neighboring records using the shared navigation role.
- `redirect.tt` opts out of the wrapper and emits a canonical link, meta
  refresh, JavaScript redirect, fallback link, and `noindex` tag.

`Booker::Page` supplies metadata for ordinary pages, while database models
supply metadata for detail pages. Shared defaults fix the domain to
`https://readabooker.com` and provide a fallback social image.
`MooX::Role::SEOTags` produces title, description, canonical, Open Graph, and
Twitter tags. Author and book templates also emit JSON-LD through
`MooX::Role::JSON_LD`. Event JSON-LD methods are placeholders and the year
template does not emit it.

The two redirects are hard-coded in `Booker::App`: `/author/colm-t-ib-n/` to
`/author/colm-toibin/`, and `/author/mich-le-roberts/` to
`/author/michele-roberts/`. They are excluded from the sitemap.

### Static assets and browser services

Edit [`docs/css/style.css`](docs/css/style.css) directly for styling. Its
modification time becomes the stylesheet query-string version during a build.
Images live in `docs/images/` and `docs/assets/img/`; the hero image is referenced
from CSS. There is no CSS compilation, JavaScript bundling, or image processing.

The layout loads Bootstrap 5.3.7, Bootstrap Icons, Google Fonts, Google Analytics,
Google AdSense, and an external Amazon-store enhancement script. Inline
JavaScript initializes Amazon buttons with tag `davblog-21` and highlights the
current letter/decade navigation link while scrolling. These services run in
the browser; ordinary builds do not fetch their content.

`docs/CNAME` contains `readabooker.com`, and `docs/.nojekyll` disables Jekyll
processing on GitHub Pages. `docs/ads.txt` contains the advertising publisher
entry. Generated output is tracked in Git. These files support static hosting,
but there is no checked-in build/deployment workflow; hosting configuration
outside this repository was not inspected.

## Data-maintenance scripts

These are separate operations, not build stages. Run them from the repository
root. Several do not add `lib/` themselves, so use `perl -Ilib bin/<script>`.
Back up the database before scripts that write to it.

| Script | Behavior and important limitations |
| --- | --- |
| `bin/load <csv>` | Imports rows using `Text::CSV_XS`. Finds or creates events and people, creates books, and adds any supplied judges. Removes leading `A`, `An`, or `The` from book sort titles and sets ASIN to `XXXXXX`. Does **not** import the CSV's `Winner` or `Publisher` values, generate slugs, or populate ISBNs/descriptions. Repeated imports can duplicate books or encounter duplicate judge keys; it is not an idempotent synchronizer. |
| `bin/event [year]` | Prints book IDs, titles, and authors for the specified event, or the latest event if omitted. Read-only; assumes the selected event exists. |
| `bin/sortnames` | Rewrites every person's current `sort_name` by moving its final whitespace-separated word to the front. Assumes simple names and is not safe to rerun indiscriminately on already rearranged names. |
| `bin/mk_slugs` | Intended to transliterate names/titles/years, lowercase them, remove apostrophes, and replace other punctuation/spaces with hyphens. Currently broken: it accesses `$app->rs->{person}`, but the app only supplies `author`, `event`, and `book`. It updates book slugs before reaching this failure. It also has no collision detection or automatic redirects. |
| `bin/describe_book` | Generates blurbs for at most 20 books whose `blurb` is undefined, using `OpenAPI::Client::OpenAI` and configured model `gpt-4o`; requires `OPENAI_API_KEY`, prints results, and writes them directly to the database. |
| `bin/describe_person` | Likewise generates biographies for at most 20 people lacking them, including judges. Also requires `OPENAI_API_KEY`. Both description scripts import `builtin::trim`, so their interpreter requirements differ from the builder's. |
| `bin/enrich_isbn` | Fills null `isbn13` values by validating/converting ASINs first, then searching Open Library by title and author. Records `isbn_source` as `asin` or `openlibrary`. Uses `URI::Escape`, `HTTP::Tiny`, and `JSON::MaybeXS`. |

The ISBN tool accepts `--db PATH`, `--dry-run`, `--limit N`, and `--sleep SECONDS`
(default 0.2). A dry run skips database updates but can still access Open Library
and overwrites `isbn_needs_review.tsv`. Open Library selection takes the first
valid ISBN-13 it finds, without an edition-matching review. Its final “Updated”
count actually counts processed records, including unsuccessful or dry-run rows.

For a new shortlist, importing the CSV is only the first step. Review the
resulting people and books, set correct sort names and unique slugs, replace
placeholder ASINs, populate ISBNs as needed, and explicitly set winner flags
when known. Rebuild after database changes; the published site never reads
`booker.db` directly.

## Where to make changes

| Change | Edit |
| --- | --- |
| Book, author, judge, or event facts | `booker.db`, through a reviewed database edit or appropriate maintenance script. |
| Home/about/contact/privacy text | Corresponding template in `src/`. |
| Shared page layout, navigation, scripts, or footer | `tt_lib/page.tt`. |
| Book rows, covers, or retailer links | `tt_lib/book.tt` and `tt_lib/book_widgets.tt`. |
| Styling and local images | Assets directly under `docs/`. |
| A new page or legacy URL redirect | `lib/Booker/App.pm` plus its template as needed. |
| Record URL or metadata behavior | Relevant model under `lib/Booker/Schema/Result/`, or shared roles. |
| Sort/group query behavior | Relevant resultset under `lib/Booker/Schema/ResultSet/`. |

Edit templates rather than generated HTML, then rebuild and review the `docs/`
diff. If a slug changes, account for the old URL explicitly: a rebuild does not
remove the previous page or create a redirect automatically.

## Existing implementation caveats

In addition to the maintenance-script limitations above, these details are
useful when debugging the current code:

- The carousel assumes at least five events with winners; it sets the event
  array's last index to four without guarding against a smaller dataset.
- In `book_widgets.tt`, `book_display` accepts `amazon_ass_tag` but passes
  `ass_tag` to `amazon_button`. The generated link can therefore have an empty
  affiliate tag, although the browser enhancement is given a default tag.
- Book JSON-LD maps its `isbn` field to `asin`, rather than `isbn13`.
- Templates interpolate database text without a general HTML-escaping policy;
  biography and blurb output uses `html_para`. Database content therefore needs
  to be treated as publishable template input.

These observations describe existing behavior; the investigation did not change
application code or catalogue data.

## Verification performed

The investigation read the actual SQLite schema in read-only mode, traced the
scripts, models, templates, and assets, and checked `perl -Ilib -c bin/build`.
A full `perl bin/build` run in a temporary repository copy completed successfully
under Perl 5.42.3. The output contained 639 HTML files and 637 sitemap entries:
339 book pages, 233 author pages, 58 event pages, seven static/index pages, and
two redirects excluded from the sitemap.

No automated test suite was found. The successful build verifies rendering with
the current data, not browser behavior, external services, or editorial accuracy.
The working repository's database and generated site were left unchanged.
