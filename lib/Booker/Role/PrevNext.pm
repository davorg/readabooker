package Booker::Role::PrevNext;

use experimental 'signatures';
use Moo::Role;

requires qw[sort_col];

sub prev_or_next($self, $next) {

  my $rs = $self->result_source->resultset;
  my $sort_col = $self->sort_col;

  return $rs->search({ $sort_col => { ($next ? '>' : '<') => $self->$sort_col }},
                     { order_by  => { ($next ? '-asc' : '-desc') => $sort_col }})->first;
}

sub prev($self) {
  return $self->prev_or_next(0);
}

sub next($self) {
  return $self->prev_or_next(1);
}

1;
