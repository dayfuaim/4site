#!/usr/bin/perl -w
use strict;
use CGI;
use modules::Settings;
use modules::DBfunctions;

$modules::DBfunctions::dbh = connectDB();
$|++;
print "Content-Type: text/html; charset=windows-1251\n\n";
my $q = new CGI;
my $hid = $q->param('hid');
my $out = qq{<select id="hotelmeal_id" name="hotelmeal_id"><option value="">-- Выберите --</option>};
unless ($hid) {
	$out .= qq{</select>};
	print $out;
	exit
}
my $sth = $modules::DBfunctions::dbh->prepare("SELECT hm.hotelmeal_id, hotelmeal_fld
FROM continent_ru_db.hotel_meal_tbl as hm, continent_ru_db.hotelmeal_tbl as m
WHERE m.hotelmeal_id=hm.hotelmeal_id
AND hm.hotel_id=$hid
ORDER BY hotelmeal_fld");
$sth->execute();
my $i = 1;
while (my @row = $sth->fetchrow_array) {
	$out .= qq{<option value="$row[0]"}.($i++==1?' selected':'').qq{>$row[1]</option>}
}
$out .= qq{</select>};
print $out;
