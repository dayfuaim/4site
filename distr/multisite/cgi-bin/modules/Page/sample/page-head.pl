#!/usr/bin/perl -W

# Вывод пути к сайту в заголовке

use strict;
use sitemodules::DBfunctions;

$|++;

# Подключение к базе
$sitemodules::DBfunctions::dbh = connectDB();

# Вывод HTTP-заголовка
print "Content-type: text/html\n\n";

# Получение начальных значений
my $currenturl = $ENV{'DOCUMENT_URI'};

my $label = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT fulllabel_fld
                                   FROM page_tbl
                                   WHERE url_fld LIKE '$currenturl'");
print "$label";

