#!/usr/bin/perl -W
# $Revision: 1.1.2.9 $
# ����� �������
use strict;
use CGI;
use sitemodules::DBfunctions;
use sitemodules::PageRender;

# ����� HTTP-���������
print "Content-type: text/html; charset=windows-1251\n\n";

# ����������� � ����
$sitemodules::DBfunctions::dbh = connectDB();
my $q = new CGI;
print open_file_templ("gallery");
