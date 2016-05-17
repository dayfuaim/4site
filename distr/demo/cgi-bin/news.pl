#!/usr/bin/perl -W
#
use CGI;
use strict;
use sitemodules::DBfunctions;
use sitemodules::ModSet;

# Подключение к базе
$sitemodules::DBfunctions::dbh = connectDB();
$|++;
print "Content-type: text/html; charset=windows-1251\n\n";

my $templ;
my $q = new CGI;
my $id = $q->param('id');
$id =~ s/\D//g;

unless ($id) {
    my @n = $sitemodules::DBfunctions::dbh->prepare("SELECT date_format(date_fld,'%Y%m%d%H%i%s'), head_fld,
														body_fld
														FROM news_tbl
														WHERE news_id=$id");
    if (scalar @n) {
		$templ = get_setting("news","template_one");
		my ($year,$month,$day,$h,$minute) = $n[0] =~ /(\d{4})(\d\d)(\d\d)(\d\d)(\d\d).+/;
		$n[2] =~ s!(\n\r)+!</p><p class="txt">!g;
		$templ =~ s/{DATE}/$day.$month.$year/g;
		$templ =~ s/{HEAD}/$n[1]/;
		$templ =~ s/{BODY}/$n[2]/
	}
}

print $templ;
