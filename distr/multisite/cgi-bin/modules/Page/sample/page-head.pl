#!/usr/bin/perl -W

# ����� ���� � ����� � ���������

use strict;
use sitemodules::DBfunctions;

$|++;

# ����������� � ����
$sitemodules::DBfunctions::dbh = connectDB();

# ����� HTTP-���������
print "Content-type: text/html\n\n";

# ��������� ��������� ��������
my $currenturl = $ENV{'DOCUMENT_URI'};

my $label = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT fulllabel_fld
                                   FROM page_tbl
                                   WHERE url_fld LIKE '$currenturl'");
print "$label";

