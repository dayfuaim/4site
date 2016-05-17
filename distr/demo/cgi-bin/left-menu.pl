#!/usr/bin/perl
# Вывод меню в левой части сайта
use strict;
use sitemodules::DBfunctions;
use sitemodules::Tree;
use sitemodules::Debug;

# Подключение к базе
$sitemodules::DBfunctions::dbh = connectDB();

$|++;

# Вывод HTTP-заголовка
print "Content-type: text/html; charset=windows-1251\n\n";

# Получение начальных значений
my $currenturl = $ENV{'DOCUMENT_URI'};

my $head= "";

my $menu = qq{<li><a href="{URL}" class="news" alt="{TITLE}" title="{TITLE}">{LABEL}</a></li>};
my $menu_sel = qq{<li class="open{LEVEL}" alt="{LABEL}" title="{LABEL}">{LABEL}</li>};
my $menu_sel_act = qq{<li><a href="{URL}" class="news" alt="{TITLE}" title="{TITLE}">{LABEL}</a></li>};

my $parent = qq{};
my $out;

my $current_ID = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT page_id
										FROM page_tbl
										WHERE url_fld='$currenturl'");

# Определение уровня текущей страницы и ее принадлежности разделам
my $lev = &level($current_ID);
my @refers = &refers_ary($current_ID);
my $this = scalar @refers >=2?$refers[-2]:$current_ID;
my $t = get_tree($this);
my @tt = ($menu,$menu_sel,$menu_sel_act);

$sitemodules::Tree::all = 0;
$out = get_children($t,$current_ID,1,\@tt);

print qq{<h3 class="lhead">}.$sitemodules::DBfunctions::dbh->selectrow_array("SELECT label_fld FROM page_tbl WHERE page_id=$this").qq{</h3><ul class="menu2">}.$out.qq{</ul>};

#################################################################
####
####

sub level { # Определение уровня страницы
    my $page_id = $_[0];
    my $level = 1;
    my $mas = 1;
    until ($mas == 0) {
        if ($page_id) {
            $mas = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT master_page_id
                                          FROM page_tbl
                                          WHERE page_id=$page_id")
	    } else { $mas = 0 }
        $page_id = $mas;
        $level++ if $mas
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
    return @refers
} # refers_ary
