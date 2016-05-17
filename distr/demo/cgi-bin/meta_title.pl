#!/usr/bin/perl
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
my ($current_ID, $master, $label, $noindex, $cache_fld, $expires_fld, $title_fld, $descr_fld, $kwd);
my %menu_set = %{get_setting_hash("menu")};
my $currenturl = $ENV{'DOCUMENT_URI'};

if ($currenturl ne '/error/error.shtml') {
	# Определение уровня текущей страницы и ее принадлежности разделам
	($current_ID, $master, $label, $noindex, $cache_fld, $expires_fld, $title_fld, $descr_fld, $kwd) =
	$sitemodules::DBfunctions::dbh->selectrow_array("SELECT page_id, master_page_id,
													fulllabel_fld, index_fld, cache_fld,
													expires_fld, title_fld, descr_fld, keywords_fld
													FROM page_tbl
													WHERE url_fld='$currenturl'");
	if ($title_fld) {
		$result = $title_fld
	} else {
		push @tmp,"$label" if $label;
		while ($master != 0) {
			my $tempor = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT fulllabel_fld
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
	$result =~ s|</?[^>]+>||g;
}
$result = qq{<head><title>$result</title>};
#$result .= qq{<meta name="description" content="$descr_fld">} if $descr_fld;

if ($currenturl ne '/error/error.shtml') {
	# Теперь берём ключевые слова...
	my @other_kwd;
	my $main_kwd = $descr_fld;
	push @other_kwd,$main_kwd unless ($main_kwd eq "");
	my $sth = $sitemodules::DBfunctions::dbh->prepare("SELECT k.add_page_id, p.descr_fld
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
		$result .= qq{<meta name="description" content="}.join(", ",@other_kwd).qq{" />} if scalar @other_kwd;
	}
} else {
	$noindex = 1;
}

$result .= qq{<meta name="keywords" content="$kwd" />} if $kwd;

unless ($noindex) {
    $result .= qq{<meta name="robots" content="noindex" />
<meta name="allow-search" content="no" />}
}

if ($cache_fld) {
	$result .= qq{<meta name="pragma" content="cache" /><meta name="expires" content="$expires_fld" />}
} else {
	$result .= qq{<meta http-equiv="Cache-Control" content="no-cache" /><meta name="pragma" content="no-cache" /><meta name="expires" content="-1" />}
}

# $result .= qq{</head>};

print $result;

# Отключение от БД
#print qq{
#<script type="text/javascript">
#//<![CDATA[
#var d = document;
#var str = '<'+'img src="';
#str +='/pcgi/ua.pl?x='+screen.width+'&amp;y='+screen.height+'&amp;c='+screen.colorDepth+'&amp;ref='+escape('$ENV{HTTP_REFERER}')+'&amp;url='+escape('$ENV{DOCUMENT_URI}')+'&amp;err=$ENV{REDIRECT_STATUS}';
#str += '" height="1" width="1" border="0" style="position: absolute;" />';
#d.write(str);
#//]]>
#</script>
#};


#exit;
