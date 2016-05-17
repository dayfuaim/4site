#!/usr/bin/perl -W
use strict;
use modules::Settings;
use modules::DBfunctions;
use modules::Debug;

my $dbh = modules::DBfunctions::connectDB();

my $origpath = `cd ../..; pwd`;
my $frompath_cgi = $modules::Settings::c{dir}{cgi};
my $frompath_htdocs = $modules::Settings::c{dir}{htdocs};
my $pathto = qq{/home/httpd/__DISTRIB__};
my @files = qw{4site.pl 4site_popup.pl css.pl sitelist.pl xmlget.pl
			xmlget_cache.pl setdate.pl show_form.pl};
my @dirs = qw{News NoSOAP System Page};
my @modules = qw{AuthInfo Comfunctions DBfunctions Interface News Page Settings
				Tree Validate Calendar Core Debug ModSet NoSOAP Security System
				Users Validfunc};
my $yes = qq{-f };
my $str;

# Copying scripts
$str = qq(cp $yes).$frompath_cgi."{".(join ','=>@files).qq(} $pathto/multisite/cgi-bin);
print qq{$str\n};
qx($str);
# Copying dirs && modules && interface
$str = qq(cp $yes -r ).$frompath_cgi."modules/{".(join ','=>@dirs).qq(} $pathto/multisite/cgi-bin/modules);
print qq{$str\n};
qx($str);
$str = qq(cp $yes).$frompath_cgi."modules/{".(join ','=>@modules).qq(}.pm $pathto/multisite/cgi-bin/modules);
print qq{$str\n};
qx($str);
$str = qq(cp $yes).$frompath_cgi.qq(interface/*.htm $pathto/multisite/cgi-bin/interface);
print qq{$str\n};
qx($str);
# Copying HTML && images
$str = qq(cp $yes).$frompath_htdocs.qq(/* $pathto/multisite/htdocs);
print qq{$str\n};
qx($str);
$str = qq(cp $yes -r ).$frompath_htdocs.qq(/img $pathto/multisite/htdocs/img);
print qq{$str\n};
qx($str);
# Copying JavaScripts
$str = qq(cp $yes).$frompath_htdocs.qq(/js/*.js $pathto/multisite/htdocs/js);
print qq{$str\n};
qx($str);
$str = qq(cp $yes).$frompath_htdocs.qq(/js/yui/[!_]*.js $pathto/multisite/htdocs/js/yui);
print qq{$str\n};
qx($str);
$str = qq(cp $yes).$frompath_htdocs.qq(/js/yui/assets/* $pathto/multisite/htdocs/js/yui/assets);
print qq{$str\n};
qx($str);

# ---- MySQL dumps ----
#
my $sql = qq{mysqldump --opt -C --compatible=mysql40 demo_db > $pathto/SQL/demo_compat.sql};
print qq{$sql\n};
qx{$sql};

$sql = qq{mysqldump --opt -C demo_db > $pathto/SQL/demo.sql};
print qq{$sql\n};
qx{$sql};

$sql = qq{mysqldump --opt -C --compatible=mysql40 --no-data multisite favorites_tbl > $pathto/SQL/multisite.sql};
print qq{$sql\n};
qx{$sql};

$sql = qq{mysqldump --opt -C --compatible=mysql40 multisite gallery_forms_tbl news_forms_tbl page_forms_tbl tables_tbl >> $pathto/SQL/multisite.sql};
print qq{$sql\n};
qx{$sql};

my $sth = $dbh->prepare("SELECT table_fld,tables_fld FROM tables_tbl WHERE module_fld='System'");
$sth->execute();
$sql = '';
while (my ($t,$s) = $sth->fetchrow_array()) {
	$sql .= $s."\n" if $t ne 'system_forms_tbl' and $t ne 'tables_tbl'
}
open (SQL,'>>'.$pathto."/SQL/multisite.sql");
	print SQL $sql;

	my @u = $dbh->selectrow_array("SELECT * FROM user_tbl WHERE user_id=30");
	$sql = qq{INSERT INTO user_tbl VALUES ('}.(join "','"=>@u).qq{');\n};
	print SQL $sql;

	$sth = $dbh->prepare("SELECT * FROM module_tbl WHERE module_fld IN ('Page','News','Gallery')");
	$sth->execute();
	$sql = qq{INSERT INTO module_tbl VALUES};
	while (my @row = $sth->fetchrow_array) {
		$sql .= qq{ ('}.join("','"=>@row).qq{'),}
	}
	$sql =~ s/,$/;\n/;
	print SQL $sql;

	my @s = $dbh->selectrow_array("SELECT * FROM site_tbl WHERE site_id=303");
	grep { $_='' unless $_ } @s;
	$sql = qq{INSERT INTO site_tbl VALUES ('}.(join "','"=>@s).qq{');\n};
	print SQL $sql;

	$sth = $dbh->prepare("SELECT user_id,site_id,module_id,form_id,permission_fld FROM permission_tbl WHERE user_id=30 AND site_id=303");
	$sth->execute();
	$sql = qq{INSERT INTO permission_tbl (user_id,site_id,module_id,form_id,permission_fld) VALUES};
	while (my @row = $sth->fetchrow_array) {
		$sql .= qq{ ('}.join("','"=>@row).qq{'),}
	}
	$sql =~ s/,$/;\n/;
	print SQL $sql;

	$sth = $dbh->prepare("SELECT * FROM site_module_tbl WHERE site_id=303");
	$sth->execute();
	$sql = qq{INSERT INTO site_module_tbl VALUES};
	while (my @row = $sth->fetchrow_array) {
		$sql .= qq{ (}.join(","=>@row).qq{),}
	}
	$sql =~ s/,$/;\n/;
	print SQL $sql;

close(SQL);

$sql = qq{mysqldump --opt -C --compatible=mysql40 --no-create-info multisite actionmsg_tbl >> $pathto/SQL/multisite.sql};
print qq{$sql\n};
qx{$sql};



print qq{DONE!\n};
