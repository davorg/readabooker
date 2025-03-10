package Booker::App;

use Moo;
use Types::Standard qw[Str HashRef ArrayRef InstanceOf];
use Time::Piece;

use Template;

use Booker::Schema;

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
  push @{ $self->urls }, '/';
  $tt->process('index.html.tt', {
    carousel_books => $self->carousel_books,
    url => $self->urls->[-1],
  }, 'index.html')
    or die $tt->error;


  warn "Building years...\n";
  push @{ $self->urls }, '/year/';
  $tt->process('year/index.html.tt', {
    events => [ $rs->{event}->all ],
    url => $self->urls->[-1],
  }, 'year/index.html')
    or die $tt->error;

  for ($rs->{event}->all) {
    push @{ $self->urls }, '/year/' . $_->slug . '/';
    $tt->process('year/year.html.tt', {
      event => $_,
      url => $self->urls->[-1],
    }, 'year/' . $_->slug . '/index.html')
      or die $tt->error;
  }

  my @authors = grep { $_->is_author } $rs->{person}->sorted_people->all;

  warn "Building authors...\n";
  push @{ $self->urls }, '/author/';
  $tt->process('author/index.html.tt', {
    authors => \@authors,
    url => $self->urls->[-1],
  }, 'author/index.html')
    or die $tt->error;

  for (@authors) {
    push @{ $self->urls }, '/author/' . $_->slug . '/';
    $tt->process('author/author.html.tt', {
      author => $_,
      url => $self->urls->[-1],
    }, 'author/' . $_->slug . '/index.html')
      or die $tt->error;
  }

  warn "Building titles...\n";
  push @{ $self->urls }, '/title/';
  $tt->process('title/index.html.tt', {
    books => [ $rs->{book}->sorted_books->all ],
    url => $self->urls->[-1],
  }, 'title/index.html')
    or die $tt->error;

  for ($rs->{book}->sorted_books->all) {
    push @{ $self->urls }, '/title/' . $_->slug . '/';
    $tt->process('title/title.html.tt', {
      book => $_,
      url => $self->urls->[-1],
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
