#!/usr/bin/perl -w
# Вывод крошек вверху страницы
use strict;
use sitemodules::DBfunctions;

$|++;
# Вывод HTTP-заголовка
print "Content-type: text/html; charset=windows-1251\n\n";

# Подключение к базе
$sitemodules::DBfunctions::dbh = connectDB();

# Получение начальных значений
my $currenturl = $ENV{'DOCUMENT_URI'};
my $crumb = '<img src="/img/crumbs.gif" border="0" align="absmiddle">';
my ($current_ID, $label) = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT page_id, label_fld
												  FROM page_tbl
												  WHERE url_fld LIKE '$currenturl'");
my $result = "<b>$label</b>";
# Определение уровня текущей страницы и ее принадлежности разделам
my $master = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT master_page_id
									FROM page_tbl
									WHERE page_id=$current_ID");
while ($master!=0) {
	my @tempor = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT label_fld, url_fld, fulllabel_fld
										FROM page_tbl
										WHERE page_id=$master");
	$result = qq{<a href="$tempor[1]" title="$tempor[2]"><nobr>$tempor[0]</nobr></a>&nbsp;$crumb}." $result";
	$master = $sitemodules::DBfunctions::dbh->selectrow_array ("SELECT master_page_id
									  FROM page_tbl
									  WHERE page_id=$master");
}
print qq{<p class="crumbs">$result</p>};
