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

=head2 slug

  data_type: 'varchar'
  is_nullable: 1
  size: 120

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 0 },
  "sort_name",
  { data_type => "text", is_nullable => 0 },
  "slug",
  { data_type => "varchar", is_nullable => 1, size => 120 },
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


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2024-10-17 09:55:17
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ZDjoYDPg21ofiyh7GsI4oQ

with 'MooX::Role::JSON_LD', 'Booker::Role::SEO';

sub json_ld_type { 'Person' }

sub json_ld_fields {
  [
    qw/name/,
  ];
}

with 'Booker::Role::SEO';

sub type { 'author' }

sub slug { return lc shift->name }

sub title { return 'Read a Booker - Author: ' . shift->name }

sub description {
  return 'ReadABooker: Choose a Booker Prize shortlisted novel to read by author - Author: ' . shift->name . '.';
}

sub url_path {
  my $self = shift;

  my $url = '/';
  $url .= $self->type . '/' if $self->type;
  $url .= $self->slug . '/' if $self->slug;

  return $url;
}

sub is_author {
  my $self = shift;

  return $self->books->count;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
