package Booker::Schema::ResultSet::Book;

use Moose;
use MooseX::NonMoose;

extends 'DBIx::Class::ResultSet';

sub BUILDARGS { $_[2] }

sub sorted_books {
  my $self = shift;

  return $self->search(undef, { order_by => 'sort_title' });
}

__PACKAGE__->meta->make_immutable;

1;
