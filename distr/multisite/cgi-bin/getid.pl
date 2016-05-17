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
my $f = $q->param('f');
my $sel = $q->param('sel');
my $db = $modules::DBfunctions::dbh->selectrow_array("SELECT dbname_fld FROM site_tbl WHERE site_id=".$q->param('site'));
my $out = qq{<select name="id_fld"><option value="">-- Нет --</option>};
if ($t) {
	my ($cmn) = $t =~ /^(.+)_tbl$/;
	my $sth = $modules::DBfunctions::dbh->prepare("SELECT ${cmn}_id,$f FROM $db.$t ORDER BY ${cmn}_id");
	$sth->execute();
	while (my ($d,$r) = $sth->fetchrow_array) {
		$out .= qq{<option value="$d"}.($d==$sel?' selected':'').qq{>[$d] $r</option>}
	}
}
$out .= qq{</select>};

print $out;
