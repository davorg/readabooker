package Booker::Page;

use v5.20;
use strict;
use warnings;
use experimental 'signatures';

use Moo;

has type => (
  is => 'ro',
  default => '',
);

has slug => (
  is => 'ro',
  required => 1,
);

has title => (
  is => 'ro',
  required => 1,
);

has description => (
  is => 'ro',
  required => 1,
);

has url_path => (
  is => 'ro',
  required => 1,
);

has image => (
  is => 'ro',
);

sub og_type { return 'website' }
sub og_title { return shift->title }
sub og_description { return shift->description }
sub og_image ($self) {
  my $url = $self->domain_url;

  return $url . ($self->image // '/images/booker2024-short.jpg');
}

sub og_url ($self) {
  return $self->domain_url . $self->url_path;
}

with 'Booker::Role::Defaults', 'MooX::Role::SEOTags';

1;
