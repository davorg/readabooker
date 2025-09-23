use utf8;
package Booker::Schema::Result::Author;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Booker::Schema::Result::Author

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';
__PACKAGE__->table_class("DBIx::Class::ResultSource::View");

=head1 TABLE: C<author>

=cut

__PACKAGE__->table("author");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_nullable: 1

=head2 name

  data_type: 'text'
  is_nullable: 1

=head2 sort_name

  data_type: 'text'
  is_nullable: 1

=head2 slug

  data_type: 'varchar'
  is_nullable: 1
  size: 120

=head2 biography

  data_type: 'text'
  is_nullable: 1

=head2 books_count

  data_type: (empty string)
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_nullable => 1 },
  "name",
  { data_type => "text", is_nullable => 1 },
  "sort_name",
  { data_type => "text", is_nullable => 1 },
  "slug",
  { data_type => "varchar", is_nullable => 1, size => 120 },
  "biography",
  { data_type => "text", is_nullable => 1 },
  "books_count",
  { data_type => "", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07053 @ 2025-09-02 14:49:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:c4FHHnNvh5iBFtF93/ve3w

__PACKAGE__->result_source_instance->is_virtual(0);
__PACKAGE__->resultset_class('Booker::Schema::ResultSet::Author');

__PACKAGE__->has_many(
  "books",
  "Booker::Schema::Result::Book",
  { "foreign.author_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

with 'MooX::Role::JSON_LD', 'Booker::Role::Defaults', 'Booker::Role::PrevNext';

sub sort_col { 'sort_name' }

sub type { 'author' }

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

sub is_author { return 1 }

sub og_title { return 'Read a Booker - Author: ' . shift->name }

sub og_description {
  return 'Explore Booker Prize-shortlisted novels by ' . shift->name . '. ' .
         'Learn more about their work and discover which titles earned a ' .
         'place on the list.';
}

sub url_path {
  my $self = shift;

  my $url = '/';
  $url .= $self->type . '/' if $self->type;
  $url .= $self->slug . '/' if $self->slug;

  return $url;
}

sub has_biography {
  my $self = shift;

  return defined $self->biography;
}

sub letter {
  my $self = shift;

  return uc substr $self->sort_name, 0, 1;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
