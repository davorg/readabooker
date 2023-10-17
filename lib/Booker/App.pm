package Booker::App;

use Moo;
use Types::Standard qw[Str HashRef InstanceOf];

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

sub build {
  my $self = shift;

  my $tt = $self->tt;
  my $rs = $self->rs;

  $tt->process('index.html.tt', {}, 'index.html')
    or die $tt->error;

  $tt->process('year/index.html.tt', {
    events => [ $rs->{event}->all ],
  }, 'year/index.html')
    or die $tt->error;

  my @authors = grep { $_->is_author } $rs->{person}->sorted_people->all;

  $tt->process('author/index.html.tt', {
    authors => \@authors,
  }, 'author/index.html')
    or die $tt->error;

  $tt->process('title/index.html.tt', {
    books => [ $rs->{book}->sorted_books->all ],
  }, 'title/index.html')
    or die $tt->error;
}

1;
