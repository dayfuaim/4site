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
my $dr = $q->param('d');
my $out = qq{<select name="drawnum_fld" id="drawnum"><option value="">-- Выберите --</option>};
unless ($l) {
	$out .= qq{</select>};
	print $out;
	exit
}
my $sth = $modules::DBfunctions::dbh->prepare("SELECT drawnum_fld FROM interlot_db.jackpot_tbl WHERE lottery_id=$l ORDER BY drawnum_fld DESC");
$sth->execute();
while (my $d = $sth->fetchrow_array) {
	$out .= qq{<option value="$d"}.($d==$dr?' selected':'').qq{>$d</option>}
}
$out .= qq{</select>};
print $out;
