use utf8;
package Booker::Schema::Result::Judge;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Booker::Schema::Result::Judge

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 TABLE: C<judge>

=cut

__PACKAGE__->table("judge");

=head1 ACCESSORS

=head2 event_id

  data_type: 'int'
  is_foreign_key: 1
  is_nullable: 0

=head2 person_id

  data_type: (empty string)
  is_foreign_key: 1
  is_nullable: 0

=head2 is_chair

  data_type: 'boolean'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "event_id",
  { data_type => "int", is_foreign_key => 1, is_nullable => 0 },
  "person_id",
  { data_type => "", is_foreign_key => 1, is_nullable => 0 },
  "is_chair",
  { data_type => "boolean", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</event_id>

=item * L</person_id>

=back

=cut

__PACKAGE__->set_primary_key("event_id", "person_id");

=head1 RELATIONS

=head2 event

Type: belongs_to

Related object: L<Booker::Schema::Result::Event>

=cut

__PACKAGE__->belongs_to(
  "event",
  "Booker::Schema::Result::Event",
  { id => "event_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 person

Type: belongs_to

Related object: L<Booker::Schema::Result::Person>

=cut

__PACKAGE__->belongs_to(
  "person",
  "Booker::Schema::Result::Person",
  { id => "person_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-11-01 11:07:10
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:1wqLnAJ66WttHsOaFVYRqQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
