#!/usr/bin/perl
# ����� ������ ������ ��������
use CGI;
use strict;
use sitemodules::Settings;
use sitemodules::DBfunctions;
use sitemodules::ModSet;

# ����� HTTP-���������
print "Content-type: text/html\n\n";
$sitemodules::DBfunctions::dbh = connectDB();

my $q = new CGI;

my $cat;
my %gal_set;
%gal_set = %{get_setting_hash("gallery")};
$cat = $q->param('cat') || $gal_set{"default"};

my $curnum = $q->param('curnum') || 0;
my $lines = $q->param('lines') || $gal_set{"min_lines"};
my $per_line = $gal_set{"count_x"};

my $result = qq{<td class="menu-crumbs" valign="top"><nobr>};

# ��������� ��������� ��������
my $currenturl = $ENV{'DOCUMENT_URI'};
my $crumb = '<img src="/img/arrow.gif" border="0" align="absmiddle" hspace="5" width="9">';
my ($current_ID, $label) = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT page_id, label_fld
                                                  FROM page_tbl
                                                  WHERE url_fld LIKE '$currenturl'");

my $total = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT count(*) FROM gallery_tbl WHERE gallerycategory_id=$cat");
$result .= qq{<b><a class="menu-crumbs" href="/gallery/index.shtml">$label</a></b>};
# ����������� ������ ������� �������� � �� �������������� ��������
my $cat_fld = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT gallerycategory_fld FROM gallerycategory_tbl WHERE gallerycategory_id=$cat");
$result .= qq{$crumb<b>$cat_fld</b>$crumb<b>����&nbsp;}.($curnum+1);

if ($total - ($curnum+$per_line*$lines) > $per_line*$lines) {
	$result .= "-".($curnum+$per_line*$lines)
} elsif ($total - ($curnum+$per_line*$lines) < $per_line*$lines) {
	$result .= "-$total" if ($curnum+1)!=$total;
}
$result .= qq{</b>};

$result .= qq{</nobr></td>
</tr></table></td></tr>};

print $result;

