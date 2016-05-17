#!/usr/bin/perl
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

my $menu = qq{<a href="{URL}" alt="{TITLE}" title="{TITLE}">{LABEL}</a>};
my $menu_sel = qq{<b>{LABEL}</b>};
my $menu_par = qq{<a href="{URL}" alt="{TITLE}" title="{TITLE}"><b>{LABEL}</b></a>};
my $div = qq{ | };

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
my @ref = refers_ary($current_ID);

my @m;
while (my @p = $sth->fetchrow_array) {
	my $t = ($p[0]==$current_ID)?$menu_sel:((scalar grep { $_==$p[0] } @ref)?$menu_par:$menu);
	$t =~ s/{LABEL}/$p[2]/g;
	$t =~ s/{TITLE}/$p[4]/g;
	$t =~ s/{URL}/$p[1]/g;
	push @m=> $t
}

#print $div;
print join $div=>@m;
#print $div;

#### Subroutines ####
##
##
sub refers_ary {
    my $id = shift;
    my $master = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT master_page_id
                                        FROM page_tbl
                                        WHERE page_id=$id");
    push (my @refers, $master);
    while ($master!=0) {
        $master = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT master_page_id
                                         FROM page_tbl
                                         WHERE page_id=$master");
    	push (@refers, $master)
	}
    return @refers
} # refers_ary
