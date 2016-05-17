#!/usr/bin/perl -W
# $Revision: 1.1.2.9 $
# Вывод галереи
use strict;
use CGI;
use sitemodules::DBfunctions;
use sitemodules::PageRender;

# Вывод HTTP-заголовка
print "Content-type: text/html; charset=windows-1251\n\n";

# Подключение к базе
$sitemodules::DBfunctions::dbh = connectDB();
my $q = new CGI;
print open_file_templ("gallery");
