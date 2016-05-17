#!/usr/bin/perl -w
use strict;

use modules::Settings;
use modules::DBfunctions;

$modules::DBfunctions::dbh = connectDB();

print "Content-Type: text/html; charset=windows-1251\n\n";

my $out;
my $sth = $modules::DBfunctions::dbh->prepare("SELECT site_id,site_fld FROM site_tbl ORDER BY site_fld");
$sth->execute();
my %site;
while (my @row = $sth->fetchrow_array) {
	$site{$row[1]} = $row[0]
}
my %s;
foreach (sort { (split ' ',$a)[-1] cmp (split ' ',$b)[-1] || (split ' ',$a)[0] cmp (split ' ',$b)[0]} keys %site) {
	my ($n,$sect) = $_ =~ /(.+)\s(.+)$/; #split ' ';
	$sect =~ s/\(([^)]+)\)/$1/;
	$s{$sect} .= qq{<option value="$site{$_}">$_</option>};
}
foreach (sort {$a cmp $b} keys %s) {
	$out .= qq{<optgroup label="$_">}.$s{$_}.qq{</optgroup>}
}
print $out;
exit;