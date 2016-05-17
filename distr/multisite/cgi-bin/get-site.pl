#!/usr/bin/perl -w
use strict;
use CGI;
use modules::Settings;
use modules::DBfunctions;

$modules::DBfunctions::dbh = connectDB();
my $q = new CGI;
my $uid = $q->param('uid');
print "Content-Type: text/html; charset=windows-1251\n\n";

my $out;
my $sql = "SELECT site_id,site_fld FROM site_tbl ".($modules::DBfunctions::dbh->selectrow_array("SELECT extperm_fld FROM user_tbl WHERE user_id=$uid")==1?'':'WHERE site_id<>256 ')."ORDER BY site_fld";
$out .= qq{<select name="site_id" onchange="if(this.value){if(document.forms.perms.user_id.value){submit('site')}}else{alert('Выберите сайт!')}"><option value="">-- Выберите сайт --</option>};
#$out .= qq{<option value="256">System</option>} if $modules::DBfunctions::dbh->selectrow_array("SELECT extperm_fld FROM user_tbl WHERE user_id=$uid")==1;
my $sth = $modules::DBfunctions::dbh->prepare($sql);
$sth->execute();
my %site;
while (my @row = $sth->fetchrow_array) {
	$site{$row[1]} = $row[0]
}
my %s;
foreach (sort { (split ' ',$a)[-1] cmp (split ' ',$b)[-1] || (split ' ',$a)[0] cmp (split ' ',$b)[0]} keys %site) {
	my ($n,$sect) = $_ =~ /(.+)\s(.+)$/; #split ' ';
	$sect =~ s/\(([^)]+)\)/$1/;
	$s{$sect} .= qq{<option value="$site{$_}">$_</option>};
}
foreach (sort {$a cmp $b} keys %s) {
	$out .= qq{<optgroup label="$_">}.$s{$_}.qq{</optgroup>}
}
print $out;
