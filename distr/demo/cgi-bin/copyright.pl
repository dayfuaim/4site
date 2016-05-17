#!/usr/bin/perl -w
use strict;
use sitemodules::Settings;
use sitemodules::DBfunctions;
$sitemodules::DBfunctions::dbh = connectDB();
$|++;
print "Content-Type: text/html; charset=windows-1251\n\n";

my $url = $ENV{DOCUMENT_URI};
$url = ($url eq '/')?qq{/index.shtml}:$url;
my $out;

open (CP,$sitemodules::Settings::c{dir}{pagetemplate}.'/Tcopyrgt.htm');
my @c = <CP>;
close(CP);

my $c = join ''=>@c;
$c =~ s!<a href="$url" class="copy">([^<]+)</a>!$1!;
print $c;

