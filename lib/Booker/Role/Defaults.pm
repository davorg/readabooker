package Booker::Role::Defaults;

use experimental 'signatures';
use Moo::Role;

requires qw[type slug];

sub domain_url ($self) {
  return 'https://readabooker.com';
}

sub og_url_path ($self) {

  my $url = '/';
  $url .= $self->type . '/' if $self->type;
  $url .= $self->slug . '/' if $self->slug;

  return $url;
}

sub og_url ($self) {
  return $self->domain_url . $self->og_url_path;
} 

sub og_title {
  my $self = shift;

  return 'Read a Booker';
}

sub og_description {
  my $self = shift;

  return 'No description!';
}

sub og_image {
  my $self = shift;

  my $url = $self->domain_url;
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
