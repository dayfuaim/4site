#!/usr/bin/perl -W
# Вывод пути к сайту в заголовке

use strict;
use sitemodules::DBfunctions;

# Вывод HTTP-заголовка
print "Content-type: text/html\n\n";

# Подключение к базе
$sitemodules::DBfunctions::dbh = connectDB();

my $res;
# Получение начальных значений
my $currenturl = $ENV{'DOCUMENT_URI'};

my $current_ID = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT page_id
                                        FROM page_tbl
                                        WHERE url_fld LIKE '$currenturl'");
my @result = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT menupix_fld,menupixurl_fld
                                    FROM menupix_tbl
                                    WHERE page_id=$current_ID");
my $url = $result[1];
unless ($result[0]) {
	foreach my $p (&refers_ary($current_ID)) {
		@result = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT menupix_fld,menupixurl_fld FROM menupix_tbl WHERE page_id=$p");
		last if $result[0];
	}
}
if ($result[0]) {
	$res = qq{<img border="0" src="$result[0]">};
   	$res = qq{<a href="}.($url?$url:$result[1]).qq{">}.$res.qq{</a>} if ($result[1] || $url);
}

print $res;

#exit;
#################################################################
####
####

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

