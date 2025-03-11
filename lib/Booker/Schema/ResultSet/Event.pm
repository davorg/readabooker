package Booker::Schema::ResultSet::Event;

use Moose;
use MooseX::NonMoose;

extends 'DBIx::Class::ResultSet';

sub BUILDARGS { $_[2] }

sub sorted_events {
  my $self = shift;

  return $self->search(undef, { order_by => { -desc => 'year' } });
}

__PACKAGE__->meta->make_immutable;

1;
