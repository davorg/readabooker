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

=head2 biography

  data_type: 'text'
  is_nullable: 1

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
  "biography",
  { data_type => "text", is_nullable => 1 },
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


# Created by DBIx::Class::Schema::Loader v0.07053 @ 2025-06-04 11:51:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:duxzeoe2XCV2mo4/Ah6WDg

with 'MooX::Role::JSON_LD';

# MooX::Role::JSON_LD requires these two methods, but when using
# json_ld_date(), they aren't used
sub json_ld_fields {}
sub json_ld_type {}

sub json_ld_data {
  my $self = shift;
  my $url = 'https://readabooker.com';
  my $author_url = $url . $self->url_path;

  return {
    '@context' => 'https://schema.org',
    '@graph'   => [
      {
        '@type' => 'Person',
        '@id'   => $author_url,
        name    => $self->name,
        url     => $author_url,
      },
      map {
        {
          '@type' => 'Book',
          name    => $_->title,
          url     => $url . $_->url_path,
          author  => { '@id' => $author_url },
        }
      } $self->books
    ]
  };
}

sub is_author {
  my $self = shift;

  return $self->books->count;
}

sub has_biography {
  my $self = shift;

  return defined $self->biography;
}

sub letter {
  my $self = shift;

  return uc substr $self->sort_name, 0, 1;
}

# TODO: Fix this horrible hack
sub url_path {
  my $self = shift;

  return '/author/' . $self->slug . '/';
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable(inline_constructor => 0);
1;
