use utf8;
package Booker::Schema::Result::Event;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Booker::Schema::Result::Event

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 TABLE: C<event>

=cut

__PACKAGE__->table("event");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 year

  data_type: 'text'
  is_nullable: 1

=head2 slug

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "year",
  { data_type => "text", is_nullable => 1 },
  "slug",
  { data_type => "varchar", is_nullable => 1, size => 50 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 books

Type: has_many

Related object: L<Booker::Schema::Result::Book>

=cut

__PACKAGE__->has_many(
  "books",
  "Booker::Schema::Result::Book",
  { "foreign.event_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 judges

Type: has_many

Related object: L<Booker::Schema::Result::Judge>

=cut

__PACKAGE__->has_many(
  "judges",
  "Booker::Schema::Result::Judge",
  { "foreign.event_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07052 @ 2025-03-11 12:05:28
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:qfBC+mUJkbOQNP8cPrtBRQ

with 'Booker::Role::SEO';

sub type { 'year' }

sub slug { return shift->year }

sub title { return 'Read a Booker - Event: ' . shift->year }

sub description {
  return 'Discover all the Booker Prize-shortlisted novels from ' .
         shift->year . '. Explore the full list and find a standout read ' .
         'from the year’s selection.';
}

sub url_path {
  my $self = shift;

  my $url = '/';
  $url .= $self->type . '/' if $self->type;
  $url .= $self->slug . '/' if $self->slug;

  return $url;
}

sub get_winner {
  my $self = shift;

  my $winner = $self->books->search({ is_winner => 1 })->first;

  return $winner;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
