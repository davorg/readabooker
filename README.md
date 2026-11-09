# ReadABooker

A website that encourages people to read novels that were shortlisted
for the Booker Prize.

* [readabooker.com](https://readabooker.com/)

To build, install Perl and cpanminus (`cpanm`), then run from the repository root:

```sh
cpanm --installdeps .
perl bin/build
```

The build is verified on Perl 5.42.3. The application declares a Perl 5.20
language minimum; older interpreters have not been tested, and resolved CPAN
dependencies may require a newer version. Installing dependencies from source
also requires a C compiler and `make` for modules such as the SQLite driver.
The [cpanfile](cpanfile) declares build dependencies; optional data-maintenance
tools have separate requirements described in the codebase guide.

The build reads the supplied `booker.db`, renders the templates, and copies
`static/` into `docs/`. Edit CSS, images, and hosting files in `static/`; `docs/`
is generated output and can be recreated from scratch. To preview with Python 3:

```sh
python3 -m http.server 8000 --directory docs
```

Visit <http://localhost:8000/>.

`docs/` is ignored by Git. Commit changes to the database, templates, Perl code,
and `static/`; there is no need to commit a local build.

The [Pages workflow](.github/workflows/pages.yml) tests and builds every push to
`main` and every pull request targeting `main`. Successful pushes to `main`
deploy to GitHub Pages. It can also be run manually from the Actions tab;
manual runs deploy only when run on `main`. Dependencies are installed from
`cpanfile` and cached, using Perl 5.42 on Ubuntu 24.04.

Pages must use **GitHub Actions** as its publishing source (Settings → Pages →
Build and deployment), rather than `main:/docs`. Keep `readabooker.com` as the
custom domain and HTTPS enforcement enabled. With Actions deployments, the
domain is configured in Pages settings; `static/CNAME` remains in the output
for compatibility with other static hosting arrangements. See
[GitHub's custom workflow documentation](https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages).

## Recording the winner

When the result is announced, run:

```sh
perl bin/winner
```

The command displays the latest year's shortlist with numbered books and authors.
Enter the winner's number, then confirm with `y`. Enter or EOF at the selection
prompt, or anything other than `y`/`yes` at confirmation, cancels without changes.
It uses the repository's `booker.db` even when run from another directory.
Check the displayed year before confirming; `--year 2026` selects a specific year.
An empty latest event fails rather than silently selecting an older shortlist.

The update is transactional and affects only that year's winner flags. Selecting
an existing sole winner makes no changes; selecting a different book warns that
it will replace the recorded winner. This command records a single winner, so it
should not be used to maintain historical joint awards.

Publish the result with:

```sh
git add booker.db
git commit -m "Record the Booker Prize winner"
git push
```

The Actions workflow builds and deploys the updated site. To preview first, run
`perl bin/build`. For a rehearsal, copy `booker.db` to a temporary location and
pass `--database /path/to/copy.db`; the command never creates a missing database.

Run the regression tests with `prove -v t`. They cover static-asset builds and
winner/shortlist carousel selection and rendering, using temporary output and
test databases so the catalogue and published output remain unchanged.

See [How ReadABooker works](CODEBASE.md) for the architecture, database model,
build instructions, templates, and data-maintenance tools.
