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

  my %rs = map { lc $_ => $self->schema->resultset($_) } qw[Person Event Book];

  return \%rs;
}

has tt => (
  is => 'lazy',
  isa => InstanceOf['Template'],
);

sub _build_tt {
  my $root = $_[0]->root;

  return Template->new(
    INCLUDE_PATH => [ "$root/tt_lib", "$root/src" ],
    OUTPUT_PATH  => "$root/docs",
    PRE_PROCESS  => 'amazon.tt',
    WRAPPER      => 'page.tt',
    STRICT       => 1,
  );
}

has carousel_books => (
  is => 'lazy',
  isa => ArrayRef[InstanceOf['Booker::Schema::Result::Book']],
);

sub _build_carousel_books {
  my $self = shift;

  my @events = $self->rs->{event}->sorted_events;
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
    description => 'ReadABooker: Choose a Booker Prize shortlisted novel to read.',
  );
  push @{ $self->urls }, $index_page->url_path;

  $tt->process('index.html.tt', {
    carousel_books => $self->carousel_books,
    object => $index_page,
  }, 'index.html')
    or die $tt->error;

  warn "Building years...\n";
  warn "  index...\n";
  my $years_page = Booker::Page->new(
    title => 'ReadABooker by year',
    url_path => '/year/',
    type => 'year',
    slug => '',
    description => 'ReadABooker: Choose a Booker Prize shortlisted novel to read by year.',
  );
  push @{ $self->urls }, $years_page->url_path;
  $tt->process('year/index.html.tt', {
    events => [ $rs->{event}->all ],
    object => $years_page,
  }, 'year/index.html')
    or die $tt->error;

  warn "  years...\n";
  for ($rs->{event}->all) {
    push @{ $self->urls }, $_->url_path;
    $tt->process('year/year.html.tt', {
      object => $_,
    }, 'year/' . $_->slug . '/index.html')
      or die $tt->error;
  }

  my @authors = $rs->{person}->authors->sorted_people->all;
  my $author_letters = $rs->{person}->author_letters;

  warn "Building authors...\n";
  warn "  index...\n";
  my $authors_page = Booker::Page->new(
    title => 'ReadABooker by author',
    url_path => '/author/',
    type => 'author',
    slug => '',
    description => 'ReadABooker: Choose a Booker Prize shortlisted novel to read by author.',
  );
  push @{ $self->urls }, $authors_page->url_path;
  $tt->process('author/index.html.tt', {
    authors => \@authors,
    letters => $author_letters,
    object => $authors_page,
  }, 'author/index.html')
    or die $tt->error;

  warn "  authors...\n";
  for (@authors) {
    push @{ $self->urls }, $_->url_path;
    $tt->process('author/author.html.tt', {
      object => $_,
    }, 'author/' . $_->slug . '/index.html')
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
    description => 'ReadABooker: Choose a Booker Prize shortlisted novel to read by title.',
  );
  push @{ $self->urls }, $titles_page->url_path;
  $tt->process('title/index.html.tt', {
    books => [ $rs->{book}->sorted_books->all ],
    letters => $letters,
    object => $titles_page,
  }, 'title/index.html')
    or die $tt->error;

  warn "  titles...\n";
  for ($rs->{book}->sorted_books->all) {
    push @{ $self->urls }, $_->url_path;
    $tt->process('title/title.html.tt', {
      object => $_,
    }, 'title/' . $_->slug . '/index.html')
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
