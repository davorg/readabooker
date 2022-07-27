use utf8;
package Booker::Schema::Result::Book;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Booker::Schema::Result::Book

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 TABLE: C<book>

=cut

__PACKAGE__->table("book");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 title

  data_type: 'text'
  is_nullable: 0

=head2 author_id

  data_type: 'int'
  is_foreign_key: 1
  is_nullable: 0

=head2 sort_title

  data_type: 'text'
  is_nullable: 0

=head2 asin

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "title",
  { data_type => "text", is_nullable => 0 },
  "author_id",
  { data_type => "int", is_foreign_key => 1, is_nullable => 0 },
  "sort_title",
  { data_type => "text", is_nullable => 0 },
  "asin",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 author

Type: belongs_to

Related object: L<Booker::Schema::Result::Person>

=cut

__PACKAGE__->belongs_to(
  "author",
  "Booker::Schema::Result::Person",
  { id => "author_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 entries

Type: has_many

Related object: L<Booker::Schema::Result::Entry>

=cut

__PACKAGE__->has_many(
  "entries",
  "Booker::Schema::Result::Entry",
  { "foreign.book_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-11-01 20:01:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:TFicZK1XXled75sMcBe4Ag

with 'MooX::Role::JSON_LD';

sub json_ld_type { 'Book' }

sub json_ld_fields {
  [
    { name => 'title' },
    { author => sub { $_[0]->author->json_ld_data } },
    { isbn => 'asin' },
  ];
}

sub entry {
  my $self = shift;

  return +($self->entries)[0];
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
