package Booker::Role::Defaults;

use v5.20;
use experimental 'signatures';
use Moo::Role;

requires qw[type slug];

sub domain_url ($self) {
  return 'https://readabooker.com';
}

sub og_url_path ($self) {
  return $self->url_path;
}

sub og_url ($self) {
  return $self->domain_url . $self->og_url_path;
} 

sub og_title ($self) {
  return 'Read a Booker';
}

sub og_description ($self) {
  return 'No description!';
}

sub og_image ($self) {
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

sub no_index {
  return 0;
}

1;
