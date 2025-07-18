package Booker::Schema::ResultSet::Event;

use Moose;
use MooseX::NonMoose;

extends 'DBIx::Class::ResultSet';

sub BUILDARGS { $_[2] }

sub sorted_events {
  my $self = shift;

  return $self->search(undef, { order_by => { -desc => 'year' } });
}

sub decades {
  my $self = shift;

  my %decades;

  for ($self->all) {
    $decades{$_->decade}++;
  }

  return [ sort keys %decades ];
}

__PACKAGE__->meta->make_immutable;

1;
