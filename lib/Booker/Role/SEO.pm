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

  if ($self->can('image') and $self->image) {
    return $self->image;
  } else {
    return '/images/booker2024-short.jpg';
  }
}

sub og_type {
  return 'website';
}

1;
