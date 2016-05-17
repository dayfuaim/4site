#!/usr/bin/perl -w
use strict;
use CGI;
use modules::Settings;
use modules::DBfunctions;

$modules::DBfunctions::dbh = connectDB();
$|++;
print "Content-Type: text/html; charset=windows-1251\n\n";
my $q = new CGI;
my $p = $q->param('p');
my $sid = $q->param('sid');
my $s = $modules::DBfunctions::dbh->selectrow_array("SELECT dbname_fld FROM site_tbl WHERE site_id=$sid");
if ($s) {
	my $out;
	$p =~ s/^hp//;
	my @ch = children($p,$s);
	$out .= join '|'=>@ch;
	print $out
}

sub children {
	my ($id,$s) = @_;
	my $sth = $modules::DBfunctions::dbh->prepare("SELECT page_id FROM ".$s.".page_tbl WHERE master_page_id=$id");
	$sth->execute();
	my @ch;
	if ($sth->rows) {
		while (my $pp = $sth->fetchrow_array) {
			push @ch=>$pp;
			my @c = children($pp,$s);
			push @ch=>@c if scalar @c
		}
	}
	return @ch
} # refers_ary
