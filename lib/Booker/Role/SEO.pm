package Booker::Role::SEO;

use experimental 'signatures';
use Moo::Role;

requires qw[type slug];

sub seo_url ($self) {

  my $url = '/';
  $url .= $self->type . '/' if $self->type;
  $url .= $self->slug . '/' if $self->slug;

  return $url;
}

sub seo_title {
  my $self = shift;

  return $self->title // 'Read a Booker';
}

sub seo_description {
  my $self = shift;

  return $self->description // 'No description!';
}

sub seo_image {
  my $self = shift;

  my $url = 'https://readabooker.com';
  my $image;

  if ($self->can('image') and $self->image) {
    $image = $self->image;
  } else {
    $image = '/images/booker2024-short.jpg';
  }

  if ($image !~ m|^https?://|) {
    $image = "$url$image";
  }

  return $image;
}

sub og_type {
  return 'website';
}

1;
