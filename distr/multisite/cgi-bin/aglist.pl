#!/usr/bin/perl -w
use strict;
use CGI;
use modules::Settings;
use modules::DBfunctions;

$modules::DBfunctions::dbh = connectDB();
$|++;
print "Content-Type: text/html; charset=windows-1251\n\n";
my $q = new CGI;
my $l = $q->param('l');
my $u = $q->param('u');
my $out = qq{<select name="regnum_fld"><option value="">-- Выберите --</option>};
unless ($l) {
	$out .= qq{</select>};
	print $out;
	exit
}
my $sth = $modules::DBfunctions::dbh->prepare("SELECT interlot_contract_id,regnum_fld FROM interlot_db.interlot_contract_tbl WHERE lottery_id=$l AND user_id=$u ORDER BY interlot_contract_id");
$sth->execute();
while (my ($d,$r) = $sth->fetchrow_array) {
	$out .= qq{<option value="$r">$r</option>}
}
$out .= qq{</select>};
print $out;
