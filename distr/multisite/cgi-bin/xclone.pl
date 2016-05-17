#!/usr/bin/perl
use strict;

my $from = qq{/home/httpd/test2};
my $from_htdocs = qq{/home/httpd/4site/htdocs};
my $to_htdocs = qq{/home/httpd/test2/htdocs};
my $from_cgi = qq{/home/httpd/4site/pcgi};
my $to_cgi = qq{/home/httpd/test2/pcgi};

my $cmd = qq{rm -rfd $to_htdocs/*};
qx{$cmd};
$cmd = qq{cp -rfp $from_htdocs/* $to_htdocs};
qx{$cmd};
$cmd = qq{cp -rfp $from_cgi/* $to_cgi};
qx{$cmd};
$cmd = qq{cp -f $from/Settings.pm $from_cgi/sitemodules};

my $updstr = "mysqldump --opt -C --compatible=mysql40 -u root 4site_db 2>&1 |";
open(DUMP,$updstr);
my @d = <DUMP>;
close(DUMP);
open(D,">/home/httpd/multisite/pcgi/_session/_sql");
print D foreach (@d);
close(D);
my $str = "mysql -u root -e 'DROP DATABASE test2_db; CREATE DATABASE test2_db'";
qx{$str};
$str = "mysql -u root -D test2_db < /home/httpd/multisite/pcgi/_session/_sql";
qx{$str};
