#!/usr/bin/perl
use strict;
use DBI;
use Data::Dumper;
use Text::Diff ();

my $s1 = {
	user => "root",
	pass => "",
	database => "dummy_db",
	host => 'localhost'
};
my $s2 = {
	user => "root",
	pass => "j78Hhj78h",
	database => "dummy_db",
	host => 'method.v.shared.ru'
};

my $dbh1 = connectDB($s1);
my $dbh2 = connectDB($s2);

# Text::Diff::Table
my @d1 = @{ $dbh1->selectall_arrayref("SHOW TABLES", { Slice => {} }) };
my @d2 = @{ $dbh2->selectall_arrayref("SHOW TABLES", { Slice => {} }) };
my $k1 = (keys %{$d1[0]})[0];
my $k2 = (keys %{$d2[0]})[0];
my @db1 = map { $_->{$k1} } @d1;
my @db2 = map { $_->{$k2} } @d2;
($k1,$k2) = map { s/Tables_in_//; $_ } ($k1,$k2);

print qq{Diff in DBs ($k1,$k2):\n};
my @d;
my $diff = Text::Diff::diff(\@db1,\@db2, { STYLE => 'Text::Diff::Table' }); #Table
print $diff."\n\n";

print qq{Diff in tables:\n};
my %db1 = map { $_ => 1 } @db1;
my %db2 = map { $_ => 1 } @db2;
my %db = (%db1,%db2);

foreach my $t (sort { $a cmp $b } keys %db) {
	my ($crt1,$crt2);
	(undef,$crt1) = $dbh1->selectrow_array("SHOW CREATE TABLE $t") if $db1{$t};
	(undef,$crt2) = $dbh2->selectrow_array("SHOW CREATE TABLE $t") if $db2{$t};
	if (($crt1 and $crt2) and $crt1 eq $crt2) {
		#print qq{'$t' are identical.\n\n}
	} elsif (!$crt2) {
		print qq{'$t' есть только в '$k1'\n\n}
	} elsif (!$crt1) {
		print qq{'$t' есть только в '$k2'\n\n}
	} else {
		my $diff = Text::Diff::diff(\$crt1,\$crt2, { STYLE => 'Text::Diff::Table' });
		print "'$t':\n".$diff."\n"
	}
}

#### Subroutines ####
##
sub connectDB {
	my $s = shift;
	my $dbi = sprintf "dbi:mysql:%s:%s",$s->{database},$s->{host};
	my $dbh = DBI->connect($dbi,$s->{user},$s->{pass});
	$dbh->do("SET NAMES 'cp1251'");
	return $dbh
} # connectDB
