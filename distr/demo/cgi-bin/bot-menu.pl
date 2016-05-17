#!/usr/bin/perl
# Вывод нижнего меню
use strict;
use sitemodules::DBfunctions;
use vars qw($sth);

# Подключение к базе и страниц первого уровня
$sitemodules::DBfunctions::dbh = connectDB();

my $out;

$|++;

# Вывод HTTP-заголовка
print "Content-type: text/html; charset=windows-1251\n\n";

# Получение начальных значений
my $currenturl = $ENV{'DOCUMENT_URI'};
	my $current_ID = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT page_id
											FROM page_tbl
											WHERE url_fld LIKE '$currenturl'");

	$sth = $sitemodules::DBfunctions::dbh->prepare("SELECT page_id, url_fld,
						  label_fld, fulllabel_fld
						  FROM page_tbl
						  WHERE (master_page_id=0)
						  AND (enabled_fld=1)
						  AND (mainmenu_fld='1')
						  ORDER BY order_fld ASC");
	$sth->execute();
	my $result;
	my @pg;
	while (my @pages = $sth->fetchrow_array) {
	$pages[2] =~ s!<?img[^>]*?>!!g;
		if ( $pages[0] != $current_ID) {
		push @pg, qq{<a class="menu-bot" href="$pages[1]" title="$pages[3]">$pages[2]</a>}
		} else {
			push @pg, qq{<b>$pages[2]</b>}
		}
	}

	$out = join(qq{ | }=>@pg);
	print $out;

