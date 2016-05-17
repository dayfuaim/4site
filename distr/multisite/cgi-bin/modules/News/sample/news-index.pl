#!/usr/bin/perl
print "Content-type: text/html; charset=windows-1251\n\n";

use strict;
use CGI qw(:all);
use sitemodules::DBfunctions;
use sitemodules::ModSet;

$|++;
my $q = new CGI;

my @d = localtime;
$d[5] += 1900;
$d[4]++;
my $date = sprintf "%4d%02d%02d%02d%02d%02d",@d[5,4,3,2,1,0];

# Подключение к базе
$sitemodules::DBfunctions::dbh = connectDB();
my %news_set = %{get_setting_hash("news")};
my $templ = $news_set{template};
my $pix_templ = $news_set{news_pix_template};
my $pad = $news_set{pix_padding};
my $quant = $news_set{quant};
my $main = $news_set{mainpic_news};
my $sth = $sitemodules::DBfunctions::dbh->prepare("SELECT date_format(date_fld,'%Y%m%d%H%i%s'), head_fld,
												  news_id, body_fld
												  FROM news_tbl
												  WHERE date_fld<='$date'
												  ORDER BY date_fld DESC LIMIT $quant");
$sth->execute();
# Вывод результатов запроса
while (my @row = $sth->fetchrow_array) {
	my ($year,$month,$day,$h,$minute) = $row[0] =~ /(\d{4})(\d\d)(\d\d)(\d\d)(\d\d)/;
	my $head = $row[1];
	my $d = "$day.$month.$year";
	my $t = $templ;

	$t =~ s/{ID}/$row[2]/g;
	$t =~ s/{HEAD}/$head/g;
	$t =~ s/{DATE}/$d/g;
	$t =~ s/{TIME}/$h:$minute/g;
	$t =~ s/{BODY}/$row[3]/g;
	my $sth1 = $sitemodules::DBfunctions::dbh->prepare("SELECT * FROM news_pix_tbl WHERE news_id=$row[2] AND main_fld".($main?'':'!')."=1");
	$sth1->execute();
	if ($sth1->rows) {
		my ($top,$bottom);
		while (my @row1 = $sth1->fetchrow_array) {
			my $ti = $pix_templ;
			$ti =~ s/{ALIGN}/$row1[4]/g;
			$ti =~ s/{PAD}/$pad/g;
			$row1[5] = qq{/news/img/$row1[5]};
			$ti =~ s/{URL}/$row1[5]/g;
			$ti =~ s/{ALT}/$row1[2]/g;
			if ($row1[3] eq 'top') {
				$top .= $ti
			} elsif ($row1[3] eq 'bottom') {
				$bottom .= $ti
			}
		}
		$t =~ s/{TOP}/$top/g;
		$t =~ s/{BOTTOM}/$bottom/g
	} else {
		$t =~ s/{TOP}//g;
		$t =~ s/{BOTTOM}//g
	}
	print $t;
}
