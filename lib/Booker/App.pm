package Booker::App;

use Moo;
use Types::Standard qw[Str HashRef ArrayRef InstanceOf];
use Time::Piece;

use Template;

use Booker::Schema;
use Booker::Page;

has root => (
  is => 'ro',
  isa => Str,
  required => 1,
);

has schema => (
  is => 'lazy',
  isa => InstanceOf['Booker::Schema'],
);

sub _build_schema {
  return Booker::Schema->get_schema;
}

has rs => (
  is => 'lazy',
  isa => HashRef[InstanceOf['DBIx::Class::ResultSet']],
);

sub _build_rs {
  my $self = shift;

  my %rs = map { lc $_ => $self->schema->resultset($_) } qw[Author Event Book];

  return \%rs;
}

has tt => (
  is => 'lazy',
  isa => InstanceOf['Template'],
);

sub _build_tt {
  my $root = $_[0]->root;

  return Template->new(
    ENCODING     => 'utf8',
    INCLUDE_PATH => [ "$root/tt_lib", "$root/src" ],
    OUTPUT_PATH  => "$root/docs",
    PRE_PROCESS  => ['amazon.tt', 'book.tt', 'prev_next.tt'],
    WRAPPER      => 'page.tt',
    STRICT       => 0,
  );
}

has carousel_books => (
  is => 'lazy',
  isa => ArrayRef[InstanceOf['Booker::Schema::Result::Book']],
);

sub _build_carousel_books {
  my $self = shift;

  my @events = grep { defined $_->get_winner } $self->rs->{event}->sorted_events;
  $#events = 4;
  my @books = map { $_->get_winner } @events;

  return \@books;
}

has urls => (
  isa => ArrayRef[Str], # TODO: URI
  is => 'rw',
  default => sub { [] },  
);

sub build {
  my $self = shift;

  my $tt = $self->tt;
  my $rs = $self->rs;

  warn "Building index...\n";
  my $index_page = Booker::Page->new(
    title => 'Read a Booker',
    url_path => '/',
    type => '',
    slug => '',
    description => 'ReadABooker helps you choose a Booker Prize-shortlisted ' .
                   'novel to read - filter by year, author, or title and ' .
                   'start exploring literary excellence.',
  );
  push @{ $self->urls }, $index_page->url_path;

  $tt->process('index.html.tt', {
    carousel_books => $self->carousel_books,
    object => $index_page,
  }, 'index.html', {binmode => ':utf8'})
    or die $tt->error;

  warn "Building years...\n";
  warn "  index...\n";

  my $years_page = Booker::Page->new(
    title => 'ReadABooker by year',
    url_path => '/year/',
    type => 'year',
    slug => '',
    description => 'Explore Booker Prize-shortlisted novels by year. Trace ' .
                   'literary trends over time and pick a prize-worthy read ' .
                   'from any year since 1969.',
  );
  push @{ $self->urls }, $years_page->url_path;
  $tt->process('year/index.html.tt', {
    decades => $rs->{event}->decades,
    events => [ $rs->{event}->all ],
    object => $years_page,
  }, 'year/index.html', {binmode => ':utf8'})
    or die $tt->error;

  warn "  years...\n";
  for ($rs->{event}->all) {
    push @{ $self->urls }, $_->url_path;
    $tt->process('year/year.html.tt', {
      object => $_,
    }, 'year/' . $_->slug . '/index.html', {binmode => ':utf8'})
      or die $tt->error;
  }

  my @authors = $rs->{author}->all;
  my $author_letters = $rs->{author}->author_letters;

  warn "Building authors...\n";
  warn "  index...\n";
  my $authors_page = Booker::Page->new(
    title => 'ReadABooker by author',
    url_path => '/author/',
    type => 'author',
    slug => '',
    description => 'Browse Booker Prize-shortlisted novels by author. ' .
                   'Discover new voices and established names - every writer ' .
                   'with a place on the shortlist.',
  );
  push @{ $self->urls }, $authors_page->url_path;
  $tt->process('author/index.html.tt', {
    authors => \@authors,
    letters => $author_letters,
    object => $authors_page,
  }, 'author/index.html', {binmode => ':utf8'})
    or die $tt->error;

  warn "  authors...\n";
  for (@authors) {
    push @{ $self->urls }, $_->url_path;
    $tt->process('author/author.html.tt', {
      object => $_,
    }, 'author/' . $_->slug . '/index.html', {binmode => ':utf8'})
      or die $tt->error;
  }

  my $letters = $rs->{book}->letters;

  warn "Building titles...\n";
  warn "  index...\n";
  my $titles_page = Booker::Page->new(
    title => 'ReadABooker by title',
    url_path => '/title/',
    type => 'title',
    slug => '',
    description => 'Find Booker Prize-shortlisted novels by title. From ' .
                   'iconic classics to hidden gems - pick your next read ' .
                   'from decades of great literature.',
  );
  push @{ $self->urls }, $titles_page->url_path;
  $tt->process('title/index.html.tt', {
    books => [ $rs->{book}->sorted_books->all ],
    letters => $letters,
    object => $titles_page,
  }, 'title/index.html', {binmode => ':utf8'})
    or die $tt->error;

  warn "  titles...\n";
  for ($rs->{book}->sorted_books->all) {
    push @{ $self->urls }, $_->url_path;
    $tt->process('title/title.html.tt', {
      object => $_,
    }, 'title/' . $_->slug . '/index.html', {binmode => ':utf8'})
      or die $tt->error;
  }

  my $date = localtime->ymd;

  my $sitemap = $self->root . '/docs/sitemap.xml';

  open my $sitemap_fh, '>', $sitemap
    or die "[$sitemap] $!\n";

  print $sitemap_fh qq[<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n];

  for ( @{ $self->urls } ) {
    print $sitemap_fh <<EOF_URL;
  <url>
    <loc>https://readabooker.com$_</loc>
    <lastmod>$date</lastmod>
  </url>
EOF_URL
  }

  print $sitemap_fh "</urlset>\n";

}

1;
