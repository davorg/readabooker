package Booker::App;

use strict;
use warnings;
use v5.20;
use experimental 'signatures';

use Moo;
use Types::Standard qw[Str HashRef ArrayRef InstanceOf];
use Time::Piece;

use Template;

use Booker::Schema;
use Booker::Page;

has root => (
  is => 'ro',
  isa => Str,
  required => 1,
);

has schema => (
  is => 'lazy',
  isa => InstanceOf['Booker::Schema'],
);

sub _build_schema {
  return Booker::Schema->get_schema;
}

has rs => (
  is => 'lazy',
  isa => HashRef[InstanceOf['DBIx::Class::ResultSet']],
);

sub _build_rs($self) {
  my %rs = map { lc $_ => $self->schema->resultset($_) } qw[Author Event Book];

  return \%rs;
}

has tt => (
  is => 'lazy',
  isa => InstanceOf['Template'],
);

sub _build_tt($self) {
  my $root = $self->root;

  return Template->new(
    ENCODING     => 'utf8',
    INCLUDE_PATH => [ "$root/tt_lib", "$root/src" ],
    OUTPUT_PATH  => "$root/docs",
    PRE_PROCESS  => ['book_widgets.tt', 'book.tt', 'prev_next.tt'],
    WRAPPER      => 'page.tt',
    STRICT       => 0,
  );
}

has carousel_books => (
  is => 'lazy',
  isa => ArrayRef[InstanceOf['Booker::Schema::Result::Book']],
);

sub _build_carousel_books($self) {
  my @events = grep { defined $_->get_winner } $self->rs->{event}->sorted_events;
  $#events = 4;
  my @books = map { $_->get_winner } @events;

  return \@books;
}

has redirects => (
  is => 'lazy',
  isa => ArrayRef[HashRef],
);

sub _build_redirects($self) {
  return [{
    from => '/author/colm-t-ib-n/',
    to   => '/author/colm-toibin/',
  },{
    from => '/author/mich-le-roberts/',
    to   => '/author/michele-roberts/',
  }];
}

has urls => (
  isa => ArrayRef[Str], # TODO: URI
  is => 'rw',
  default => sub { [] },  
);

sub write_page ($self, $template, $output, $vars) {
  my $tt = $self->tt;

  die "No 'object' passed to write_page\n"
    unless exists $vars->{object};

  if ($output =~ m{/$}) {
    $output .= 'index.html';
  }

  $tt->process($template, $vars, $output, {binmode => ':utf8'})
    or die $tt->error;

  push @{ $self->urls }, $vars->{object}->url_path
    unless $vars->{object}->no_index;
}

sub mk_index_page ($self) {
  my $tt = $self->tt;

  warn "Building index...\n";

  my $index_page = Booker::Page->new(
    title => 'Read a Booker',
    url_path => '/',
    type => '',
    slug => '',
    description => 'ReadABooker helps you choose a Booker Prize-shortlisted ' .
                   'novel to read - filter by year, author, or title and ' .
                   'start exploring literary excellence.',
  );

  $self->write_page('index.html.tt', $index_page->url_path, {
    carousel_books => $self->carousel_books,
    object => $index_page,
  });
}

sub mk_years_pages($self) {

  my $tt = $self->tt;
  my $rs = $self->rs->{event};

  warn "Building years...\n";
  warn "  index...\n";
  my $years_page = Booker::Page->new(
    title => 'ReadABooker by year',
    url_path => '/year/',
    type => 'year',
    slug => '',
    description => 'Explore Booker Prize-shortlisted novels by year. ' .
                   'Trace literary trends over time and pick ' .
                   'a prize-worthy read from any year since 1969.',
  );

  $self->write_page('year/index.html.tt', $years_page->url_path, {
    events => [ $rs->sorted_events->all ],
    decades => $rs->decades,
    object => $years_page,
  });

  warn "  years...\n";
  for ($rs->sorted_events->all) {
    $self->write_page('year/year.html.tt', $_->url_path . 'index.html', {
      object => $_,
    });
  }
}

sub mk_authors_pages($self) {
  my $tt = $self->tt;
  my @authors = $self->rs->{author}->all;
  my $author_letters = $self->rs->{author}->author_letters;

  warn "Building authors...\n";
  warn "  index...\n";
  my $authors_page = Booker::Page->new(
    title => 'ReadABooker by author',
    url_path => '/author/',
    type => 'author',
    slug => '',
    description => 'Browse Booker Prize-shortlisted novels by author. ' .
                   'Discover new voices and established names - every writer ' .
                   'with a place on the shortlist.',
  );

  $self->write_page('author/index.html.tt', $authors_page->url_path, {
    authors => \@authors,
    letters => $author_letters,
    object => $authors_page,
  });

  warn "  authors...\n";
  for (@authors) {
    $self->write_page('author/author.html.tt', $_->url_path . 'index.html', {
      object => $_,
    });
  }
}

sub mk_titles_pages($self) {
  my $tt = $self->tt;
  my $rs = $self->rs->{book};
  my $letters = $rs->letters;

  warn "Building titles...\n";
  warn "  index...\n";
  my $titles_page = Booker::Page->new(
    title => 'ReadABooker by title',
    url_path => '/title/',
    type => 'title',
    slug => '',
    description => 'Find Booker Prize-shortlisted novels by title. From ' .
                   'iconic classics to hidden gems - pick your next read ' .
                   'from decades of great literature.',
  );

  $self->write_page('title/index.html.tt', $titles_page->url_path, {
    books => [ $rs->sorted_books->all ],
    letters => $letters,
    object => $titles_page,
  });

  warn "  titles...\n";
  for ($rs->sorted_books->all) {
    $self->write_page('title/title.html.tt', $_->url_path . 'index.html', {
      object => $_,
    });
  }
}

sub mk_redirects($self) {
  my $tt = $self->tt;

  warn "Redirects...\n";
  for my $redirect (@{ $self->redirects }) {
    if ($redirect->{from} =~ m{/$}) {
      $redirect->{from} .= 'index.html';
    }

    $self->write_page('redirect.tt', $redirect->{from}, {
      redirect => $redirect,
      object => Booker::Page->new(
        title => 'Redirecting...',
        url_path => $redirect->{from},
        type => '',
        slug => '',
        description => 'This page has moved.',
        no_index => 1,
      ),
    });
  }
}

sub mk_sitemap($self) {
  warn "Building sitemap...\n";
  my $date = localtime->ymd;

  my $sitemap = $self->root . '/docs/sitemap.xml';

  open my $sitemap_fh, '>', $sitemap
    or die "[$sitemap] $!\n";

  print $sitemap_fh qq[<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n];

  for ( @{ $self->urls } ) {
    print $sitemap_fh <<EOF_URL;
  <url>
    <loc>https://readabooker.com$_</loc>
    <lastmod>$date</lastmod>
  </url>
EOF_URL
  }

  print $sitemap_fh "</urlset>\n";
}

sub build($self) {
  my $tt = $self->tt;
  my $rs = $self->rs;

  $self->mk_index_page;
  $self->mk_years_pages;
  $self->mk_authors_pages;
  $self->mk_titles_pages;
  $self->mk_redirects;
  $self->mk_sitemap;
}

1;
