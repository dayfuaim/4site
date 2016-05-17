#!/usr/bin/perl

$|++;
print "Content-type: text/html; charset=windows-1251\n\n";

use strict;
use sitemodules::DBfunctions;
use sitemodules::ModSet;

# Подключение к базе
$sitemodules::DBfunctions::dbh = connectDB();

my %news_set = %{get_setting_hash("news")};
my $quant = $news_set{"digest_quant"};
my $w = $news_set{"digest_width"};
my $templ = $news_set{"template_digest"};
my $sth = $sitemodules::DBfunctions::dbh->prepare("SELECT date_format(date_fld,'%Y%m%d%H%i%s'), head_fld,
												  news_id
												  FROM news_tbl
												  WHERE date_fld<=NOW()
												  ORDER BY date_fld DESC
												  LIMIT $quant");
$sth->execute();
# Вывод результатов запроса
while (my @row = $sth->fetchrow_array) {
	my ($mp,$a) = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT url_fld,alt_fld FROM news_pix_tbl WHERE news_id=$row[2] AND main_fld=1");
	my ($year,$month,$day,$h,$minute) = $row[0] =~ /\d\d(\d\d)(\d\d)(\d\d)(\d\d)(\d\d).+/;
	my ($head,$rest) = $row[1] =~ /^(.{1,$w})(.*)/;
	$head .= qq{...} if $rest;
	my $d = "$day.$month.$year";
	my $t = $templ;

	$mp = qq{<img src="/news/img/$mp" border="0" align="left" hspace="2" alt="$a" title="$a">} if $mp;
	$t =~ s/{ID}/$row[2]/g;
	$t =~ s/{HEAD}/$head/g;
	$t =~ s/{DATE}/$d/g;
	$t =~ s/{MAIN_PIC}/$mp/g;

    print $t;
}

