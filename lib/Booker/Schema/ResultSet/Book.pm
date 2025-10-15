package Booker::Schema::ResultSet::Book;

use Moose;
use MooseX::NonMoose;

extends 'DBIx::Class::ResultSet';

use v5.20;
use experimental 'signatures';

sub BUILDARGS { $_[2] }

sub sorted_books ($self) {
  return $self->search(undef, { order_by => 'sort_title' });
}

sub letters ($self) {
  my %letters;

  for ($self->all) {
    $letters{$_->letter}++;
  }

  return [ sort keys %letters ];
}

__PACKAGE__->meta->make_immutable;

1;
