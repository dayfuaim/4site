#!/usr/bin/perl -w

use strict;

use SOAP::Transport::HTTP;
use sitemodules::Settings;
use sitemodules::DBfunctions;

$sitemodules::DBfunctions::dbh = connectDB();

$SOAP::Constants::DO_NOT_USE_XML_PARSER = 1;
SOAP::Transport::HTTP::CGI
	->dispatch_to('/usr/local/lib/perl5/site_perl/5.8.4/SOAP/4Site','ServerAuth')
	->handle;

1;
