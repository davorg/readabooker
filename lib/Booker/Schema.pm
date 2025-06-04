use utf8;
package Booker::Schema;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use Moose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Schema';

__PACKAGE__->load_components("Schema::ResultSetNames");

__PACKAGE__->load_namespaces;


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2024-10-17 09:55:17
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:DXy4S9jtLRS6mfQTS2Rn/A


# You can replace this text with custom code or comments, and it will be preserved on regeneration

use DBD::SQLite::Constants ':dbd_sqlite_string_mode';

sub get_schema {
  my $class = shift;

  my $db = shift || 'booker.db';

  my $schema =  $class->connect("dbi:SQLite:$db");

  my $dbh = $schema->storage->dbh;

  $dbh->{sqlite_string_mode} = DBD_SQLITE_STRING_MODE_UNICODE_FALLBACK;

  return $schema;
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);
1;
