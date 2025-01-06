package Booker::App;

use Moo;
use Types::Standard qw[Str HashRef ArrayRef InstanceOf];

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
  isa => HashRef,
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
  # isa => InstanceOf['HashRef'],
);

has carousel_asins => (
  is => 'ro',
  # isa => InstanceOf['ArrayRef'],
  default => sub { [ qw(1529922933
                        0861546458
                        1914502078
                        1784744069
                        152901929X
                        1526605902
                        0099511894) ] },
);

sub _build_carousel_books {
  my $self = shift;

  my %books;
  for (@{ $self->carousel_asins }) {
    $books{$_} = $self->rs->{book}->find({
      asin => $_,
    });
  }

  return \%books;
}

sub build {
  my $self = shift;

  my $tt = $self->tt;
  my $rs = $self->rs;

  warn "Building index...\n";
  $tt->process('index.html.tt', {
    carousel_books => $self->carousel_books,
  }, 'index.html')
    or die $tt->error;

  warn "Building years...\n";
  $tt->process('year/index.html.tt', {
    events => [ $rs->{event}->all ],
  }, 'year/index.html')
    or die $tt->error;

  for ($rs->{event}->all) {
    $tt->process('year/year.html.tt', {
      event => $_,
    }, 'year/' . $_->slug . '/index.html')
      or die $tt->error;
  }

  my @authors = grep { $_->is_author } $rs->{person}->sorted_people->all;

  warn "Building authors...\n";
  $tt->process('author/index.html.tt', {
    authors => \@authors,
  }, 'author/index.html')
    or die $tt->error;

  for (@authors) {
    $tt->process('author/author.html.tt', {
      author => $_,
    }, 'author/' . $_->slug . '/index.html')
      or die $tt->error;
  }

  warn "Building titles...\n";
  $tt->process('title/index.html.tt', {
    books => [ $rs->{book}->sorted_books->all ],
  }, 'title/index.html')
    or die $tt->error;

  for ($rs->{book}->sorted_books->all) {
    $tt->process('title/title.html.tt', {
      book => $_,
    }, 'title/' . $_->slug . '/index.html')
      or die $tt->error;
  }
}

1;
