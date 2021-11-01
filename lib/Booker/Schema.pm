use utf8;
package Booker::Schema;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use Moose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-11-01 11:07:10
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Vlx0FW7YXm2W5ctRCi7ldg


# You can replace this text with custom code or comments, and it will be preserved on regeneration

sub get_schema {
  my $class = shift;

  my $db = shift || 'booker.db';

  return $class->connect("dbi:SQLite:$db");
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);
1;
