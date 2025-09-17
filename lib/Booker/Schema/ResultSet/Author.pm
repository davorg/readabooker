package Booker::Schema::ResultSet::Author;

use Moose;
extends 'DBIx::Class::ResultSet';
use namespace::autoclean;

sub BUILDARGS { $_[2] }

sub sorted_people {
  my $self = shift;

  return $self->search(undef, { order_by => 'sort_name' });
}

sub authors {
  my $self = shift;

  return $self->search(
    undef,
    {
      join     => 'books',
      group_by => 'me.id',
      order_by => 'sort_name',
      '+select' => [ { count => 'books.id' } ],
      '+as'     => ['books_count'],
      having   => \['COUNT(books.id) > 0'],
    }
  );
}

sub author_letters {
  my $self = shift;

  my %letters;

  for ($self->authors->all) {
    $letters{$_->letter}++;
  }

  return [ sort keys %letters ];
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
