#!/usr/bin/perl -W
# Вывод пути к сайту в заголовке
use strict;
use sitemodules::DBfunctions;
use sitemodules::ModSet;

# Вывод HTTP-заголовка
print "Content-type: text/html; charset=windows-1251\n\n";

# Подключение к базе
$sitemodules::DBfunctions::dbh = connectDB();

# Получение начальных значений
my @tmp;

my $result;
my ($current_ID, $master, $label, $noindex, $cache_fld, $expires_fld, $title_fld, $descr_fld);
my %menu_set = %{get_setting_hash("menu")};
my $currenturl = (split /\?/,$ENV{'DOCUMENT_URI'})[0];

if ($currenturl ne '/error/error.shtml') {
	# Определение уровня текущей страницы и ее принадлежности разделам
	($current_ID, $master, $label, $noindex, $cache_fld, $expires_fld, $title_fld, $descr_fld) = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT page_id, master_page_id,
													label_fld, index_fld,
													cache_fld, expires_fld, 
													title_fld, descr_fld
													FROM page_tbl
													WHERE url_fld LIKE '$currenturl'");
	if ($title_fld) {
		$result = $title_fld
	} else {
		push @tmp,"$label" if $label;
		while ($master != 0) {
			my $tempor = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT label_fld
												FROM page_tbl
												WHERE page_id=$master");
			push @tmp,$tempor if $tempor;
			$master = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT master_page_id
											FROM page_tbl
											WHERE page_id=$master");
		}
	}
}
# Получили общую для всех часть <title>
unless ($title_fld) {
	my $global = $menu_set{"title_global"};
	push @tmp,$global if $global;
	$result = join " - "=>@tmp;
	$result =~ s|</?nobr>||g;
}
$result = qq{<head><title>$result</title>};

if ($currenturl ne '/error/error.shtml') {
	# Теперь берём ключевые слова...
	my @other_kwd;
	my $main_kwd = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT keywords_fld FROM page_tbl WHERE page_id=$current_ID");
	push @other_kwd,$main_kwd unless ($main_kwd eq "");
	my $sth = $sitemodules::DBfunctions::dbh->prepare("SELECT k.add_page_id, p.keywords_fld
							FROM keywords_tbl as k, page_tbl as p
							WHERE k.page_id=$current_ID AND k.add_page_id=p.page_id AND k.add_page_id!=0
							ORDER BY k.add_page_id DESC");
	$sth->execute();
	if ($sth->rows) {
		while (my @row = $sth->fetchrow_array) {
			push @other_kwd, $row[1];
		}
	}
push @other_kwd, $menu_set{"common_keywords"} if $sitemodules::DBfunctions::dbh->selectrow_array("SELECT keywords_id FROM keywords_tbl WHERE page_id=$current_ID AND add_page_id=0");
	@other_kwd = grep { $_ } @other_kwd;
	if ($noindex) {
		$result .= qq{<meta name="keywords" content="}.join(", ",@other_kwd).qq{">} if scalar @other_kwd;
	}
} else {
	$noindex = 1;
}

$result .= qq{<meta name="description" content="$descr_fld">} if $descr_fld;

unless ($noindex) {
    $result .= qq{<META NAME="robots" CONTENT="noindex">
<META NAME="allow-search" CONTENT="no">}
} else {
    $result .= qq{<META NAME="robots" CONTENT="all">
<META NAME="allow-search" CONTENT="yes">}
}

if ($cache_fld) {
	$result .= qq{<META NAME="pragma" CONTENT="cache"><META NAME="expires" CONTENT="$expires_fld">}
} else {
	$result .= qq{<meta http-equiv="Cache-Control" content="no-cache"><META NAME="pragma" CONTENT="no-cache"><META NAME="expires" CONTENT="-1">}
}

print $result;

# Отключение от БД
$sitemodules::DBfunctions::dbh->disconnect;

#exit;
