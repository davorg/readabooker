package Booker::Schema::ResultSet::Person;

use Moose;
use MooseX::NonMoose;

extends 'DBIx::Class::ResultSet';

sub BUILDARGS { $_[2] }

sub sorted_people {
  my $self = shift;

  return $self->search(undef, { order_by => 'sort_name' });
}

__PACKAGE__->meta->make_immutable;

1;
