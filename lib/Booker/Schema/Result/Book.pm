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
  is_nullable: 0

=head2 slug

  data_type: 'varchar'
  is_nullable: 1
  size: 120

=head2 event_id

  data_type: 'int'
  default_value: 1
  is_foreign_key: 1
  is_nullable: 0

=head2 is_winner

  data_type: 'boolean'
  default_value: false
  is_nullable: 0

=head2 blurb

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
  { data_type => "text", is_nullable => 0 },
  "slug",
  { data_type => "varchar", is_nullable => 1, size => 120 },
  "event_id",
  {
    data_type      => "int",
    default_value  => 1,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "is_winner",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
  "blurb",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

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
  { id => "author_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07053 @ 2025-09-02 15:18:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:4amxnebtAlxA9MyWa7NUcA

with 'MooX::Role::JSON_LD', 'MooX::Role::SEOTags',
      'Booker::Role::Defaults', 'Booker::Role::PrevNext';

use Text::Unidecode;

__PACKAGE__->belongs_to(
  "author",
  "Booker::Schema::Result::Author",
  { id => "author_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

sub sort_col { 'sort_title' }

sub json_ld_type { 'Book' }

sub json_ld_fields {
  [
    { name => 'title' },
    { author => sub {
        my $author = $_[0]->author;
        {
          '@type' => 'Person',
          name    => $author->name,
          url     => 'https://readabooker.com' . $author->url_path,
        }
      }
    },
    { isbn => 'asin' },
    'image',
  ];
}

sub type { 'title' }

sub og_title { return 'Read a Booker - Title: ' . shift->title }

sub og_description {
  my ($min, $max) = (110, 160);

  my $desc = 'Learn more about ‘' . shift->title . '’, a Booker ' .
    'Prize-shortlisted novel.';

  my $padding = ' See why it made the list and explore other titles from the ' .
    'same year or author.';

  if (length($desc) < $min) {
    $desc .= $padding;
  }

  return $desc;
}

sub url_path {
  my $self = shift;

  my $url = '/';
  $url .= $self->type . '/' if $self->type;
  $url .= $self->slug . '/' if $self->slug;

  return $url;
}

sub has_blurb {
  my $self = shift;

  return defined $self->blurb;
}

sub letter {
  my $self = shift;

  my $letter = uc substr $self->sort_title, 0, 1;

  return $letter =~ /[A-Z]/ ? $letter : '#';
}

sub image {
  my $self = shift;

  return 'https://images.amazon.com/images/P/' .$self->asin . '.jpg';
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
