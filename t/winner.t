use strict;
use warnings;
use Test::More;
use File::Temp qw(tempdir);
use FindBin;
use Cwd qw(abs_path getcwd);
use IPC::Open3;
use Symbol qw(gensym);
use DBI;

my $root = abs_path("$FindBin::Bin/..");
my $temp = tempdir(CLEANUP => 1);
my $db = "$temp/catalogue.db";
my $dbh = DBI->connect("dbi:SQLite:dbname=$db", '', '', { RaiseError => 1 });
open my $ddl, '<', "$root/booker.sql" or die $!;
{ local $/; local $dbh->{sqlite_allow_multiple_statements} = 1; $dbh->do(<$ddl>) }
$dbh->do("INSERT INTO person (id,name,sort_name) VALUES (1,'An Author','Author')");
$dbh->do("INSERT INTO event (id,year) VALUES (1,'2025'),(2,'2026'),(3,'2027')");
$dbh->do("INSERT INTO book (id,title,sort_title,author_id,asin,event_id,is_winner) VALUES (1,'Old winner','Old',1,'x',1,1),(2,'Alpha','Alpha',1,'y',2,0),(3,'Beta','Beta',1,'z',2,0)");
sub run {
    my ($input, @args) = @_;
    my $err = gensym;
    my $pid = open3(my $in, my $out, $err, $^X, "$root/bin/winner", '--database', $db, @args);
    print {$in} $input;
    close $in;
    my $stdout = do { local $/; <$out> } // '';
    my $stderr = do { local $/; <$err> } // '';
    waitpid $pid, 0;
    return ($? >> 8, $stdout . $stderr);
}
sub winners { $dbh->selectcol_arrayref('SELECT id FROM book WHERE is_winner = 1 ORDER BY id') }
my ($status, $output) = run('');
ok($status, 'empty newest event fails instead of changing an older year');
like($output, qr/No shortlist found for 2027/, 'empty event diagnostic');
$dbh->do('DELETE FROM event WHERE id = 3');
($status, $output) = run("2\nn\n");
is($status, 0, 'declined confirmation exits cleanly');
is_deeply(winners(), [1], 'declining leaves winners unchanged');
($status, $output) = run("99\n");
ok($status, 'invalid selection fails');
is_deeply(winners(), [1], 'invalid selection does not change database');
($status, $output) = run('');
is($status, 0, 'EOF cancels');
my $cwd = getcwd();
chdir $temp or die $!;
($status, $output) = run("2\ny\n");
chdir $cwd or die $!;
is($status, 0, 'command works outside repository');
like($output, qr/Recorded 2026 winner: Beta by An Author/, 'reports chosen book and year');
is_deeply(winners(), [1, 3], 'selects latest winner and preserves historical winner');
($status, $output) = run("2\n");
is($status, 0, 'selecting existing winner is a no-op');
like($output, qr/already the 2026 winner/, 'no-op explained');
($status, $output) = run("1\nyes\n", '--year', '2026');
is($status, 0, 'explicit year and correction supported');
like($output, qr/replaces the recorded winner\(s\): Beta/, 'warns before replacing winner');
is_deeply(winners(), [1, 2], 'correction clears previous winner only for selected year');
($status, $output) = run('', '--year', '1999');
ok($status, 'missing year fails');
($status, $output) = run('', '--database', "$temp/missing.db");
ok($status, 'missing database fails');
ok(!-e "$temp/missing.db", 'missing database is not created');
# Force failure after clearing the old winner, to verify txn_do rolls back both writes.
$dbh->do(q{CREATE TRIGGER reject_winner BEFORE UPDATE OF is_winner ON book
    WHEN NEW.id = 3 AND NEW.is_winner = 1
    BEGIN SELECT RAISE(ABORT, 'test winner failure'); END});
($status, $output) = run("2\ny\n");
ok($status, 'failed winner update exits with an error');
is_deeply(winners(), [1, 2], 'transaction restores previous winner when second update fails');
done_testing;
