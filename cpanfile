# Language baseline declared by the application modules (including signatures).
# The build is verified on Perl 5.42.3; dependencies may require a newer Perl
# than this source-level minimum.
requires 'perl', '5.020';

# Object system and shared roles.
requires 'Moo';
requires 'Moose';
requires 'MooseX::MarkAsMethods';
requires 'MooseX::NonMoose';
requires 'Types::Standard';
requires 'namespace::autoclean';

# Database mapping and SQLite driver.
requires 'DBIx::Class';
requires 'DBIx::Class::Schema::ResultSetNames';
requires 'DBD::SQLite';

# Rendering and page metadata.
requires 'Template';
requires 'MooX::Role::JSON_LD';
# 1.2.2 fixes the missing test helper in the 1.2.1 CPAN archive.
requires 'MooX::Role::SEOTags', 'v1.2.2';
requires 'Text::Unidecode';

# Historical imports and optional enrichment tools are not build dependencies.
# See CODEBASE.md for their additional requirements.
