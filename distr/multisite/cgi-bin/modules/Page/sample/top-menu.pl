#!/usr/bin/perl -w
# ����� ������ ������ ��������
use strict;
use sitemodules::DBfunctions;

$|++;
# ����� HTTP-���������
print "Content-type: text/html\n\n";

# ����������� � ����
$sitemodules::DBfunctions::dbh = connectDB();

# ��������� ��������� ��������
my $currenturl = $ENV{'DOCUMENT_URI'};
my $crumb = '<span class="slash">/</span>';
my ($current_ID, $label) = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT page_id, label_fld
												  FROM page_tbl
												  WHERE url_fld LIKE '$currenturl'");
my $result = "<b>$label</b>";
# ����������� ������ ������� �������� � �� �������������� ��������
my $master = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT master_page_id
									FROM page_tbl
									WHERE page_id=$current_ID");
while ($master != 0)
	{
	my @tempor = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT label_fld, url_fld, fulllabel_fld
										FROM page_tbl
										WHERE page_id=$master");
	$result = qq{<a class="menu-crumbs" href="$tempor[1]" title="$tempor[2]"><nobr>$tempor[0]</nobr></a>&nbsp;$crumb}." $result";
	$master = $sitemodules::DBfunctions::dbh->selectrow_array ("SELECT master_page_id
									  FROM page_tbl
									  WHERE page_id=$master");
	}
print qq{<p class="menu-crumbs"><nobr>}.$result.qq{</nobr></p>};

