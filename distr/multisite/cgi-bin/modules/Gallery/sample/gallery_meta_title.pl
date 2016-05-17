#!/usr/bin/perl -w
# Вывод пути к сайту в заголовке
use strict;
use sitemodules::Settings;
use sitemodules::DBfunctions;
use sitemodules::ModSet;

# Вывод HTTP-заголовка
print "Content-type: text/html; charset=windows-1251\n\n";

# Подключение к базе
$sitemodules::DBfunctions::dbh = connectDB();

my $q = new CGI;

my $cat;
unless (defined $q->param('cat')) {
	my ($min,$cnt) = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT min(gallerycategory_id),COUNT(gallerycategory_id) FROM gallerycategory_tbl");
	my $cat = $min + int rand $cnt;
	while ($sitemodules::DBfunctions::dbh->selectrow_array("SELECT enabled_fld FROM gallerycategory_tbl WHERE gallerycategory_id=$cat")==0) {
		$cat = $min + int rand $cnt;
	}
	$sitemodules::DBfunctions::dbh->do("UPDATE gallery_settings_tbl SET value_fld='$cat' WHERE gallery_settings_fld='default'");
}
my %gal_set = %{get_setting_hash("gallery")};
my %menu_set = %{get_setting_hash("menu")};

$cat = $q->param('cat') || $gal_set{"default"};

my $curnum = $q->param('curnum') || 0;
my $lines = $q->param('lines') || $gal_set{"min_lines"};
my $per_line = $gal_set{"count_x"};

# Получение начальных значений
my $currenturl = $ENV{'DOCUMENT_URI'};

# Определение уровня текущей страницы и ее принадлежности разделам
my ($current_ID, $master, $label, $noindex) = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT page_id, master_page_id, fulllabel_fld, index_fld
                                                  FROM page_tbl
                                                  WHERE url_fld LIKE '$currenturl'");
my @tmp;

my $result;
my $global = $menu_set{"title_global"};
push @tmp,$global if $global;
push @tmp, $label if $label;
my $cat_fld = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT gallerycategory_fld FROM gallerycategory_tbl WHERE gallerycategory_id=$cat");
push @tmp, $cat_fld;
my $total = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT count(*) FROM gallery_tbl WHERE gallerycategory_id=$cat");
# Определение уровня текущей страницы и ее принадлежности разделам
my $ttt = qq{Фото&nbsp;}.($curnum+1);

if ($total - ($curnum+$per_line*$lines) > $per_line*$lines) {
	$ttt .= "-".($curnum+$per_line*$lines)
} elsif ($total - ($curnum+$per_line*$lines) < $per_line*$lines) {
	$ttt .= "-$total" if ($curnum+1)!=$total;
}
push @tmp, $ttt;

$result = join " - "=>reverse @tmp;
$result =~ s|</?nobr>||g;


$result = qq{<title>$result</title>};
$result .= qq{<meta name="description" content="$descr_fld">} if $descr_fld;

# Теперь берём ключевые слова...
my @other_kwd;
my $main_kwd = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT keywords_fld FROM page_tbl WHERE page_id=$current_ID");
push @other_kwd,$main_kwd unless ($main_kwd eq "");
my $sth = $sitemodules::DBfunctions::dbh->prepare("SELECT k.add_page_id, p.keywords_fld
                        FROM keywords_tbl as k, page_tbl as p
                        WHERE k.page_id=$current_ID AND k.add_page_id=p.page_id AND k.add_page_id!=0
						ORDER BY k.add_page_id DESC");
$sth->execute();
while (my @row = $sth->fetchrow_array) {
    push @other_kwd, $row[1];
}
push @other_kwd, $menu_set{"common_keywords"} if $sitemodules::DBfunctions::dbh->selectrow_array("SELECT keywords_id FROM keywords_tbl WHERE page_id=$current_ID AND add_page_id=0");
@other_kwd = grep { $_ } @other_kwd;
if ($noindex) {
	$result .= qq{<meta name="keywords" content="}.join(", ",@other_kwd).qq{">} if scalar @other_kwd;
}
unless ($noindex) {
    $result .= qq{<META NAME="robots" CONTENT="noindex">
<META NAME="allow-search" CONTENT="no">};
} else {
    $result .= qq{<META NAME="robots" CONTENT="all">
<META NAME="allow-search" CONTENT="yes">
};
}
print $result;
#print <<EOHT;
#<meta http-equiv="Expires" content="-1">
#<meta http-equiv="Pragma" content="no-cache">
#EOHT

# Отключение от БД
$sitemodules::DBfunctions::dbh->disconnect;

#exit;
