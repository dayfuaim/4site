#!/usr/bin/perl -W
# Вывод пути к сайту в заголовке
use strict;
use sitemodules::DBfunctions;
use sitemodules::ModSet;
use sitemodules::Debug;

# Вывод HTTP-заголовка
print "Content-type: text/html; charset=windows-1251\n\n";

# Подключение к базе
$sitemodules::DBfunctions::dbh = connectDB();

# Получение начальных значений

my $currenturl = $ENV{'DOCUMENT_URI'};
my %menu_set = %{get_setting_hash("menu")};
my ($current_ID,$master) = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT page_id, master_page_id
                                        FROM page_tbl
                                        WHERE url_fld='$currenturl'");
my $sth = $sitemodules::DBfunctions::dbh->prepare("SELECT page_id, url_fld,
													label_fld,title_fld,
													fulllabel_fld,
													master_page_id
													FROM page_tbl
													WHERE (master_page_id=0)
													AND (enabled_fld=1)
													AND (mainmenu_fld='1')
													ORDER BY order_fld ASC");
$sth->execute();
my $result;
my $out;
my %p;
my %par;
my $sth1 = $sitemodules::DBfunctions::dbh->prepare("SELECT page_id,master_page_id
													FROM page_tbl
													WHERE enabled_fld=1
													ORDER BY master_page_id,order_fld");
$sth1->execute();
while (my @row = $sth1->fetchrow_array) {
	$p{$row[0]} = $row[1]?1:0;
	$par{$row[1]}++ unless exists $par{$row[1]}
}
#$sth1->execute();
foreach (keys %par) {
	my $sth2 = $sitemodules::DBfunctions::dbh->prepare("SELECT page_id
												FROM page_tbl
												WHERE master_page_id=$_
												AND enabled_fld=1
												ORDER BY order_fld");
	$sth2->execute();
	while (my $pp = $sth2->fetchrow_array) {
		$p{$pp}++
	}
}
#sitemodules::Debug::dump(\%par);
#sitemodules::Debug::dump(\%p);
my @s;

$out .= qq{<ul class="map">};
while (my @row = $sth->fetchrow_array) {
	push @s=>qq{<li><a href="$row[1]" alt="$row[3]" title="$row[3]">$row[2]</a></li>};
	push @s=>qq{<ul>}._pl($row[0],1).qq{</ul>} if exists $par{$row[0]}
}
$out .= join ''=>@s;
$out .= qq{</ul>};
print $out;


#### Subroutines ####
##
##
sub _pl {
	my ($par,$lev) = @_;
	my @ps;
	my $sth = $sitemodules::DBfunctions::dbh->prepare("SELECT page_id, url_fld,
													label_fld,title_fld,
													fulllabel_fld
													FROM page_tbl
													WHERE (master_page_id=$par)
													AND (enabled_fld=1)
													ORDER BY order_fld ASC");
	$sth->execute();
	my $out;
	my $last = $sth->rows;
	my $i = 1;
	while (my @p = $sth->fetchrow_array) {
		$out .= qq{<li><a href="$p[1]" alt="$p[3]" title="$p[3]">$p[2]</a></li>};
		$out .= qq{<ul>}._pl($p[0],$lev+1).qq{</ul>} if exists $par{$p[0]}
	}
	return $out
}