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

=head2 entries

Type: has_many

Related object: L<Booker::Schema::Result::Entry>

=cut

__PACKAGE__->has_many(
  "entries",
  "Booker::Schema::Result::Entry",
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


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2024-10-17 09:55:17
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:400/TnBAy573EiAvJBiqXw

sub slug { return shift->year }

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
