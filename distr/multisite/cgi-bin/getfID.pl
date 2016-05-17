#!/usr/bin/perl -w
use strict;
use CGI;
use modules::Settings;
use modules::DBfunctions;
use modules::Debug;
use modules::Core qw(:DEFAULT);
use modules::Comfunctions qw(:DEFAULT);

$modules::DBfunctions::dbh = connectDB();

print "Content-Type: text/html; charset=windows-1251\n\n";

my $q = new CGI;
my $site = $q->param('site');
my $user = $q->param('user_id');
if ($user !~ /^\d+$/) {
	modules::Debug::notice("Not any user!");
	exit
}
my $form = $q->param('returnact');

my $mod;
my @modlist;
my $sth = $modules::DBfunctions::dbh->prepare("SELECT sm.module_id,m.module_fld,m.menuname_fld
					  FROM module_tbl as m, site_module_tbl as sm
					  WHERE m.module_id=sm.module_id
					  AND site_id=$site
					  ORDER BY sm.module_id");
$sth->execute();
while (my @row = $sth->fetchrow_array) {
	push @modlist, $row[1]
}
@modlist = sort { $a cmp $b } @modlist;
foreach my $m (@modlist) {
	if ($modules::DBfunctions::dbh->selectrow_array("SELECT COUNT(".lc($m)."_forms_fld) FROM ".lc($m)."_forms_tbl WHERE ".lc($m)."_forms_fld='$form'")>0) {
		$mod = $m;
		last
	}
}

my $out;
my $mid = $modules::DBfunctions::dbh->selectrow_array("SELECT module_id FROM module_tbl WHERE module_fld='$mod'");
my $fid = $modules::DBfunctions::dbh->selectrow_array("SELECT ".lc($mod)."_forms_id FROM ".lc($mod)."_forms_tbl WHERE ".lc($mod)."_forms_fld='$form'");
my $l;
$modules::DBfunctions::dbh->do("INSERT INTO formlink_tbl (user_id,site_id,module_id,form_id) VALUES ($user,$site,$mid,$fid)");
if (!$modules::DBfunctions::dbh->errstr) {
	$l = $modules::DBfunctions::dbh->selectrow_array("SELECT LAST_INSERT_ID()")
} else {
	$l = $modules::DBfunctions::dbh->selectrow_array("SELECT formlink_id FROM formlink_tbl WHERE user_id=$user AND site_id=$site AND module_id=$mid AND form_id=$fid")
}

$out = modules::Debug::notice($l);

print $out;
