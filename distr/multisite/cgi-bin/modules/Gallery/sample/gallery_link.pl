#!/usr/bin/perl -w
# $Revision: 1.1.2.7 $
# ����� �������
use strict;
use CGI;
use sitemodules::DBfunctions;
use sitemodules::PageRender;

# ����� HTTP-���������
print "Content-type: text/html\n\n";

# ����������� � ����
$sitemodules::DBfunctions::dbh = connectDB();
my $q = new CGI;
print open_file_templ("gallery_link");
