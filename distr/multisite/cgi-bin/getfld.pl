#!/usr/bin/perl -w
use strict;
use CGI;
use modules::Settings;
use modules::DBfunctions;
use modules::Debug;

$modules::DBfunctions::dbh = connectDB();
$|++;
print "Content-Type: text/html; charset=windows-1251\n\n";
my $q = new CGI;
my $t = $q->param('t');
my $td = $q->param('tid');
my $t2 = $q->param('t2');
my $sel = $q->param('sel');
my $db = $modules::DBfunctions::dbh->selectrow_array("SELECT dbname_fld FROM site_tbl WHERE site_id=".$q->param('site'));
my $out = qq{<select name="fldname_fld" onchange="getID(this.form.name,this.form.table_fld.value,this.value,'$t2','')"><option value="">-- Нет --</option>};
if ($t) {
	my ($cmn) = $t =~ /^(.+)_tbl$/;
	my $sth = $modules::DBfunctions::dbh->prepare("SHOW COLUMNS FROM $db.$t LIKE '%_fld'");
	$sth->execute();
	while (my ($r) = $sth->fetchrow_array) {
		$out .= qq{<option value="$r"}.($r eq $sel?' selected':'').qq{>$r</option>}
	}
}
$out .= qq{</select>};

print $out;
