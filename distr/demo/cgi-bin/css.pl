#!/usr/bin/perl
use strict;
use sitemodules::Settings;
#use sitemodules::Debug;

$|++;
print "Content-Type: text/html; charset=windows-1251\n\n";

my $path = $sitemodules::Settings::c{dir}{htdocs};
my $css;
my $ua = $ENV{HTTP_USER_AGENT};
if ($ua =~ /Opera/) {
	$css = 'opera'
} elsif ($ua =~ /Gecko/) {
	$css = 'mozilla'
} else {
	$css = 'ie'
}
print qq{<link href="/$css.css" rel="stylesheet" type="text/css" />} if -e $sitemodules::Settings::c{dir}{htdocs}.qq{/$css.css}
