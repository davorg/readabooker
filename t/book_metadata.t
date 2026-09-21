use strict;
use warnings;
use Test::More;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Template;
use JSON::PP qw(decode_json);
use Booker::Schema;

my $schema = Booker::Schema->get_schema(':memory:');
open my $ddl_fh, '<', "$FindBin::Bin/../booker.sql" or die $!;
my $ddl = do { local $/; <$ddl_fh> };
{
    my $dbh = $schema->storage->dbh;
    local $dbh->{sqlite_allow_multiple_statements} = 1;
    $dbh->do($ddl);
}
my $author = $schema->resultset('Person')->create({
    name => 'Example Author', sort_name => 'Author, Example', slug => 'example-author',
});
my $event = $schema->resultset('Event')->create({ year => '2025', slug => '2025' });
my $book = $event->create_related('books', {
    title => 'Example Book', sort_title => 'Example Book', slug => 'example-book',
    author_id => $author->id, asin => '0224099787', isbn13 => '9780224099783',
});

my $tt = Template->new(
    INCLUDE_PATH => "$FindBin::Bin/../tt_lib",
    PRE_PROCESS => 'book_widgets.tt',
);
my $template = '[% book_display(book, tag, 16772) %]';
for my $tag ('davblog-21', 'another-affiliate-21') {
    my $html;
    $tt->process(\$template, { book => $book, tag => $tag, ass_tag => 'wrong-tag' }, \$html)
        or die $tt->error;
    like($html, qr{href="https://www\.amazon\.co\.uk/dp/0224099787/\?tag=\Q$tag\E"},
        "Amazon URL uses supplied tag $tag without JavaScript");
    like($html, qr{data-amazon-tag="\Q$tag\E"}, 'enhancement attribute uses the same tag');
    like($html, qr{data-amazon-asin="0224099787"}, 'Amazon identifier remains the ASIN');
    like($html, qr{href="https://uk\.bookshop\.org/a/16772/9780224099783"},
        'Bookshop link retains its ISBN and affiliate');
    unlike($html, qr/wrong-tag/, 'unrelated template variable does not override the argument');
}

sub structured_data {
    my $wrapped = $book->json_ld_wrapped;
    my ($json) = $wrapped =~ m{<script type="application/ld\+json">\s*(.*?)\s*</script>}s;
    return decode_json($json);
}

my $data = structured_data();
is($data->{isbn}, '9780224099783', 'rendered JSON-LD uses ISBN-13 rather than ASIN');
is($data->{'@type'}, 'Book', 'book schema type retained');
is($data->{author}{name}, 'Example Author', 'author metadata retained');

for my $missing (undef, '', '   ') {
    $book->isbn13($missing);
    # Isolate ISBN metadata from the cover URL, whose missing-ISBN handling
    # is tracked separately in issue #14.
    no warnings 'redefine';
    local *Booker::Schema::Result::Book::image = sub { 'https://example.test/cover.jpg' };
    my $without_isbn = structured_data();
    ok(!exists $without_isbn->{isbn}, 'absent or blank ISBN is omitted from JSON-LD');
}

done_testing;
