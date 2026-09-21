use strict;
use warnings;
use Test::More;
use File::Temp qw(tempdir);
use FindBin;
use Cwd qw(abs_path);
use lib "$FindBin::Bin/../lib";
use Booker::App;
use Booker::Schema;

my $root = abs_path("$FindBin::Bin/..");
my $temp = tempdir(CLEANUP => 1);
for my $directory (qw(src tt_lib static)) {
    symlink "$root/$directory", "$temp/$directory" or die "symlink: $!";
}

sub empty_schema {
    my $schema = Booker::Schema->get_schema(':memory:');
    open my $fh, '<', "$root/booker.sql" or die $!;
    my $ddl = do { local $/; <$fh> };
    my $dbh = $schema->storage->dbh;
    local $dbh->{sqlite_allow_multiple_statements} = 1;
    $dbh->do($ddl);
    return $schema;
}

sub render {
    my ($schema) = @_;
    my $app = Booker::App->new(root => $temp, schema => $schema);
    $app->mk_index_page;
    open my $fh, '<:encoding(UTF-8)', "$temp/docs/index.html" or die $!;
    my $html = do { local $/; <$fh> };
    return ($app, $html);
}

my $schema = empty_schema();
my $author = $schema->resultset('Person')->create({
    name => 'Example Author', sort_name => 'Author, Example', slug => 'example-author',
});
for my $year (2020 .. 2026) {
    my $event = $schema->resultset('Event')->create({ year => $year, slug => $year });
    next if $year == 2026; # Future event with no shortlist yet.
    for my $number (reverse 1 .. ($year == 2025 ? 6 : 1)) {
        $event->create_related('books', {
            title => "Novel $year-$number", sort_title => "Novel $year-$number",
            slug => "novel-$year-$number", author_id => $author->id,
            asin => '1234567890', isbn13 => '9781234567897',
            is_winner => $year == 2025 ? 0 : 1,
        });
    }
}

my ($app, $html) = render($schema);
is_deeply([map { $_->year } @{ $app->carousel_events }],
    [2025, 2024, 2023, 2022, 2021], 'five recent populated events, including shortlist');
is(scalar(() = $html =~ /class="carousel-item(?: active)?"/g), 5, 'five slides');
is(scalar(() = $html =~ /data-bs-slide-to=/g), 5, 'five indicators');
like($html, qr/aria-label="Shortlist 2025"/, 'shortlist indicator label');
like($html, qr/aria-label="Winner 2024"/, 'winner indicator label');
is(scalar(() = $html =~ /class="shortlist-book"/g), 6, 'full shortlist on one slide');
like($html, qr/class="carousel-item active".*?class="carousel-shortlist"/s,
    'newest event is the active shortlist slide');
like($html, qr{href="/year/2025/">2025 shortlist}, 'shortlist links to its event');
like($html, qr{href="/title/novel-2025-1/"}, 'shortlist links to book details');
like($html, qr{href="/author/example-author/">Example Author}, 'author name and link');
like($html, qr{covers\.openlibrary\.org/b/isbn/9781234567897-L\.jpg}, 'cover image');
like($html, qr{https://uk\.bookshop\.org/a/16772/9781234567897}, 'purchase link');
ok(index($html, 'Novel 2025-1') < index($html, 'Novel 2025-6'), 'shortlist sorted by title');
unlike($html, qr/data-bs-ride="carousel"/, 'shortlist carousel does not auto-advance');
like($html, qr/The winner of the 2024 Booker Prize was/, 'existing winner format retained');

# A newly announced winner changes the slide on the next render, with no date logic.
$schema->resultset('Book')->find({ slug => 'novel-2025-3' })->update({ is_winner => 1 });
($app, $html) = render($schema);
unlike($html, qr/class="carousel-shortlist"/, 'winner replaces shortlist slide');
like($html, qr/The winner of the 2025 Booker Prize was <i>Novel 2025-3<\/i>/,
    'correct winner selected');
like($html, qr/aria-label="Winner 2025"/, 'indicator switches to winner');
like($html, qr/data-bs-ride="carousel"/, 'winner-only carousel retains autoplay');

# More than one pending event can be represented.
$schema->resultset('Book')->search({ is_winner => 1 })->update({ is_winner => 0 });
($app, $html) = render($schema);
is(scalar(() = $html =~ /class="carousel-shortlist"/g), 5, 'multiple shortlist slides supported');

my $small_schema = empty_schema();
($app, $html) = render($small_schema);
is_deeply($app->carousel_events, [], 'empty catalogue yields no events');
unlike($html, qr/id="myCarousel"/, 'empty carousel is omitted');

my $person = $small_schema->resultset('Person')->create({
    name => 'Solo Author', sort_name => 'Author, Solo', slug => 'solo-author',
});
my $event = $small_schema->resultset('Event')->create({ year => '2025', slug => '2025' });
$event->create_related('books', {
    title => 'Solo Book', sort_title => 'Solo Book', slug => 'solo-book',
    author_id => $person->id, asin => '1234567890', isbn13 => '9781234567897',
});
($app, $html) = render($small_schema);
is(scalar @{ $app->carousel_events }, 1, 'fewer than five events are not padded');
is(scalar(() = $html =~ /class="carousel-item(?: active)?"/g), 1, 'single event renders once');

done_testing;
