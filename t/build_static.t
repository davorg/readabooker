use strict;
use warnings;
use Test::More;
use File::Copy qw(copy);
use File::Find qw(find);
use File::Path qw(make_path);
use File::Spec;
use File::Temp qw(tempdir);
use FindBin;
use Cwd qw(abs_path getcwd);
use Time::Piece;

my $root = abs_path("$FindBin::Bin/..");
my $temp = tempdir(CLEANUP => 1);

for my $tree (qw(bin lib src tt_lib static)) {
    find({
        no_chdir => 1,
        wanted => sub {
            my $source = $File::Find::name;
            my $target = File::Spec->catfile(
                $temp, File::Spec->abs2rel($source, $root),
            );
            if (-d $source) {
                make_path($target);
            } elsif (-f $source) {
                copy($source, $target) or die "copy $source: $!";
            }
        },
    }, "$root/$tree");
}
copy("$root/booker.db", "$temp/booker.db") or die "copy database: $!";

sub read_file {
    my ($path) = @_;
    open my $fh, '<:raw', $path or die "open $path: $!";
    local $/;
    return <$fh> // '';
}

sub build {
    my $cwd = getcwd();
    chdir $temp or die "chdir $temp: $!";
    my $status = system($^X, 'bin/build');
    chdir $cwd or die "chdir $cwd: $!";
    return $status;
}

# Fixed source timestamps make cache-version checks independent of test timing.
my $mtime = 1_700_000_000;
utime($mtime, $mtime, "$temp/static/css/style.css") or die "utime: $!";
make_path("$temp/static/nested/deeper");
open my $extra, '>:raw', "$temp/static/nested/deeper/.asset" or die $!;
print {$extra} "nested\0asset\n";
close $extra or die $!;

ok(!-e "$temp/docs", 'no output directory before build');
is(build(), 0, 'build succeeds without existing output') or BAIL_OUT('Build failed');

find({
    no_chdir => 1,
    wanted => sub {
        my $source = $File::Find::name;
        return unless -f $source;
        my $relative = File::Spec->abs2rel($source, "$temp/static");
        my $target = "$temp/docs/$relative";
        ok(-f $target, "$relative copied") or return;
        is(read_file($target), read_file($source), "$relative content preserved");
        is((stat $target)[9], (stat $source)[9], "$relative timestamp preserved");
    },
}, "$temp/static");

for my $page (qw(index.html about/index.html author/index.html title/index.html
                 year/index.html contact/index.html privacy/index.html sitemap.xml)) {
    ok(-s "$temp/docs/$page", "$page generated");
}
my $version = localtime($mtime)->strftime('%Y%m%d%H%M%S');
like(read_file("$temp/docs/index.html"), qr{/css/style\.css\?v=$version},
    'stylesheet version comes from source timestamp');

open my $css, '>>:raw', "$temp/static/css/style.css" or die $!;
print {$css} "\n/* regression test update */\n";
close $css or die $!;
$mtime += 60;
utime($mtime, $mtime, "$temp/static/css/style.css") or die "utime: $!";
is(build(), 0, 'rebuild succeeds after source CSS changes') or BAIL_OUT('Rebuild failed');
is(read_file("$temp/docs/css/style.css"), read_file("$temp/static/css/style.css"),
    'rebuild refreshes copied CSS');
$version = localtime($mtime)->strftime('%Y%m%d%H%M%S');
like(read_file("$temp/docs/index.html"), qr{/css/style\.css\?v=$version},
    'rebuild refreshes stylesheet version');

done_testing;
