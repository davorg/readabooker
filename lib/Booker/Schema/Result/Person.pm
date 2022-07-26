use utf8;
package Booker::Schema::Result::Person;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Booker::Schema::Result::Person

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 TABLE: C<person>

=cut

__PACKAGE__->table("person");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 sort_name

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 0 },
  "sort_name",
  { data_type => "text", is_nullable => 0 },
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
  { "foreign.author_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 judges

Type: has_many

Related object: L<Booker::Schema::Result::Judge>

=cut

__PACKAGE__->has_many(
  "judges",
  "Booker::Schema::Result::Judge",
  { "foreign.person_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-11-01 11:07:10
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:xpvq1Cgw1Uk4TXC4HOxrjg

with 'MooX::Role::JSON_LD';

sub json_ld_type { 'Person' }

sub json_ld_fields {
  [
    qw/name/,
  ];
}

sub is_author {
  my $self = shift;

  return $self->books->count;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
