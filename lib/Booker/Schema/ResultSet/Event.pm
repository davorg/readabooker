package Booker::Schema::ResultSet::Event;

use Moose;
use MooseX::NonMoose;

extends 'DBIx::Class::ResultSet';

use v5.20;
use experimental 'signatures';

sub BUILDARGS { $_[2] }

sub sorted_events ($self) {
  return $self->search(undef, { order_by => { -desc => 'year' } });
}

sub decades ($self) {
  my %decades;

  for ($self->all) {
    $decades{$_->decade}++;
  }

  return [ sort keys %decades ];
}

__PACKAGE__->meta->make_immutable;

1;
