use utf8;
package Booker::Schema::Result::Entry;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Booker::Schema::Result::Entry

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 TABLE: C<entry>

=cut

__PACKAGE__->table("entry");

=head1 ACCESSORS

=head2 book_id

  data_type: 'int'
  is_foreign_key: 1
  is_nullable: 0

=head2 event_id

  data_type: 'int'
  is_foreign_key: 1
  is_nullable: 0

=head2 is_winner

  data_type: 'boolean'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "book_id",
  { data_type => "int", is_foreign_key => 1, is_nullable => 0 },
  "event_id",
  { data_type => "int", is_foreign_key => 1, is_nullable => 0 },
  "is_winner",
  { data_type => "boolean", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</book_id>

=item * L</event_id>

=back

=cut

__PACKAGE__->set_primary_key("book_id", "event_id");

=head1 RELATIONS

=head2 book

Type: belongs_to

Related object: L<Booker::Schema::Result::Book>

=cut

__PACKAGE__->belongs_to(
  "book",
  "Booker::Schema::Result::Book",
  { id => "book_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

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


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2024-10-17 09:55:17
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:HUX4bQGXRJz3PmIDQIqkiA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
