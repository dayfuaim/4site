#!/usr/bin/perl -W
# Вывод меню в левой части сайта
use strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use sitemodules::DBfunctions;
use sitemodules::Tree;
use sitemodules::ModSet;
use sitemodules::Debug;

# Подключение к базе
$sitemodules::DBfunctions::dbh = connectDB();

my @bullets = ('',
	qq{<img src="/img/menu.gif" width="18" height="13" border="0">},qq{<img src="/img/menu.gif" width="18" height="13" border="0">},qq{<img src="/img/menu.gif" width="18" height="13" border="0">}
);
# Вывод HTTP-заголовка
print "Content-type: text/html\n\n";

my $q = new CGI;
my $out;

my %gal_set = %{get_setting_hash("gallery")};
my $currenturl = $ENV{'DOCUMENT_URI'};
my $current_ID = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT page_id
										FROM page_tbl
										WHERE url_fld LIKE '$currenturl'");
my $cat = $q->param('cat') || $gal_set{"default"};
my $curnum = $q->param('curnum') || 0;

my $parent = qq{<img src="/img/bullet.gif" width="10" height="8" border="0">};

my $menu = qq(<tr><td width="18">{BULLET}</td><td><nobr><p class="menu{LEVEL}p"><a href="{URL}" class="menu{LEVEL}p">{LABEL}{PARENT}</a></p></nobr></td></tr>);

my $menu_sel = qq(<tr><td width="18">{BULLET}</td><td><nobr><p class="menu{LEVEL}p">{LABEL}</p></nobr></td></tr>);

my $cat_menu = qq(<tr><td width="18">{BULLET}</td><td><nobr><p class="menu{LEVEL}p"><a href="{URL}" class="menu{LEVEL}p">{LABEL}</a></p></nobr></td></tr>);

my $cat_menu_sel = qq(<tr><td width="18">{BULLET}</td><td><nobr><p class="menu{LEVEL}p">{LABEL}</p></nobr></td></tr>);

# Получение начальных значений

print qq{<tr><td valign="top" height="100%">
<table border="0" cellpadding="0" cellspacing="0" width="90%" height="100%">
<tr><td width="25%" valign="top"><br>};

print qq{
<table border="0" width="100%" cellpadding="0" cellspacing="0">
};

my $current_ID = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT page_id
										FROM page_tbl
										WHERE url_fld LIKE '$currenturl'");

# Определение уровня текущей страницы и ее принадлежности разделам
my $lev = &level($current_ID);
my @refers = &refers_ary($current_ID);

my $parent_ID = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT master_page_id
										FROM page_tbl
										WHERE page_id=$current_ID");
my $tree;
$tree = get_tree(0);

$out .= get_children($tree,$current_ID,1,$menu,$menu_sel,$parent,\@bullets);

print $out;
# sitemodules::Debug::dump($out);
#show_children($tree,$cat,1,$menu,$menu_sel,\@bullets);

$sitemodules::DBfunctions::dbh->disconnect;

#################################################################
####
####

sub level { # Определение уровня страницы
    my $page_id = $_[0];
    my $level = 1;
    my $mas = 1;
    until ($mas == 0)
        {
        if ($page_id)
	        {
            $mas = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT master_page_id
                                          FROM page_tbl
                                          WHERE page_id=$page_id");
	        }
        else { $mas = 0 }
        $page_id = $mas;
        $level++ if $mas;
        }
    return $level
    } # level

sub refers_ary {
    my $id = shift;
    my $master = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT master_page_id
                                        FROM page_tbl
                                        WHERE page_id=$id");
    push (my @refers, $master);
    while ($master != 0) {
        $master = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT master_page_id
                                         FROM page_tbl
                                         WHERE page_id=$master");
    	push (@refers, $master)
		}
    return @refers;
	} # refers_ary

sub show_cats {
	use POSIX;
	my ($cat,$curnum,$level) = @_;
	my $tt;
	my $min_lines = $gal_set{"min_lines"};
	my $lines = $q->param('lines') || $min_lines;
	my $per_line = $gal_set{"count_x"};
	#
	my $total = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT COUNT(*) FROM gallery_tbl
									  WHERE gallerycategory_id=$cat");
	my $next = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT *
									  FROM gallery_tbl
									  WHERE gallerycategory_id=$cat
									  LIMIT ".($curnum+$lines*$per_line).",".($lines*$per_line));
	my $prev = 0;
	unless ($curnum == 0 || $curnum-$lines*$per_line < 0) {
    	$prev = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT *
									  FROM gallery_tbl
									  WHERE gallerycategory_id=$cat
									  LIMIT ".($curnum-$lines*$per_line).",".($lines*$per_line));
	}
	for (0..POSIX::ceil($total/($min_lines*$per_line))-1) {
		my $start = $min_lines*$per_line*$_;
		my $end   = ($min_lines*$per_line*($_+1)-1 > $total-1)?($total-1):($min_lines*$per_line*($_+1)-1);
		my $url = "$ENV{'DOCUMENT_URI'}?curnum=$start&cat=$cat";
		my ($a_st,$a_end)=qw();
		my $t = ($start==$curnum)?$cat_menu_sel:$cat_menu;
    	$t =~ s/{LEVEL}/$level/g;
     	$t =~ s/{BULLET}//gx;
    	$t =~ s/{URL}/$url/gx;
		$start++; $end++;
		my $se = ($start<$end)?qq{-$end}:"";
    	$t =~ s/{LABEL}/Фото $start$se/gx;
		$t =~ s/{PARENT}//g;
    	$tt .= $t;
	}
	return $tt
}
