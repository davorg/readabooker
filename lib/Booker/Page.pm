package Booker::Page;

use strict;
use warnings;

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

with 'Booker::Role::SEO';

1;
