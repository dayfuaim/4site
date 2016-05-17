#!/usr/bin/perl -W
use strict;
use CGI qw(fatalsToBrowser);
use sitemodules::Debug;

$|++;
print "Content-Type: text/html; charset=windows-1251\n\n";
print 'http://'.($ENV{HTTP_X_FORWARDED_HOST}||$ENV{HTTP_HOST});
