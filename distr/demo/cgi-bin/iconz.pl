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

open (ICO,$sitemodules::Settings::c{dir}{pagetemplate}.'/Ticonz.htm');
my @ico = <ICO>;
close(ICO);

my $ico = join ''=>@ico;
$ico =~ s!(<a\shref="$url"[^>]*><img\ssrc=".+?)\.gif!$1-active.gif!;
$ico =~ s!<a\shref="$url"[^>]*>(<img\s[^>]+>)</a>!$1!;
print $ico;
