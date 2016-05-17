#!/usr/bin/perl -w
use strict;
use Time::localtime;
use CGI qw(:standard);
use modules::Calendar;

$|=1;

print "Content-type: text/html; charset=windows-1251\n\n";

my $frm=new CGI;

my $currMonth=$frm->param('currMonth');
my $currYear=$frm->param('currYear');
my $elnum=$frm->param('elnum');
my $formname=$frm->param('formname');

my $dt=localtime;
if (!defined $currMonth) {
	$currMonth=$dt->mon();
}
if (!defined $currYear) {
	$currYear=$dt->year()+1900;
}

#* CREATE CALENDAR OBJECT **/
my $calendar = Calendar->new($elnum, $formname);
#* WRITE CALENDAR **/
$calendar->mkCalendar($currYear, $currMonth, $dt->mday());

