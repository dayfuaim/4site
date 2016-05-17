#!/usr/bin/perl -w
use strict;
use CGI;
use modules::Settings;
use modules::DBfunctions;
use modules::Debug;
use modules::Comfunctions qw(:DEFAULT);

$modules::DBfunctions::dbh = connectDB();

print "Content-Type: text/html; charset=windows-1251\n\n";

my $q = new CGI;
my $id = $q->param('id');

my $out;
my $f = $modules::DBfunctions::dbh->selectrow_array("SELECT formhash_fld FROM actionstat_tbl WHERE actionstat_id=$id");
$out .= start_table().head_table('Параметр','Значение');
my @f = split /\n/=>$f;
shift @f; pop @f;
my $i = 1;
foreach my $s (@f) {
	my ($k,$v) = split /\s+=>\s+/=>$s;
	($k,$v) = grep {
		$_ =~ s/^\s+// if /^\s/;
		if (/^'/) {
			$_ =~ s/^'//;
			$_ =~ s/',?$//
		} else {
			if (/,$/) {
				$_ =~ s/,$//
			} else {
				$_
			}
		}
	} ($k,$v);
	$out .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{"><td class="tl"><b>$k</b></td><td class="tl">$v</td></tr>}
}
$out .= end_table();

print $out;
