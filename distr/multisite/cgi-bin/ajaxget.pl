#!/usr/bin/perl -w
use CGI;
use CGI(escapeHTML);
use CGI::Carp qw(fatalsToBrowser);
use CGI::Session;
use Digest::MD5 qw(md5_hex);
use modules::Settings;
use modules::DBfunctions;
use modules::AuthInfo;
use modules::NoSOAP;
use modules::Security;
use modules::Core;
use modules::Debug;
use strict;

$|++;
my $out;
my $q = new CGI;
$modules::DBfunctions::dbh = connectDB();
my $fn = $q->param('fn');
my @param;
my %p = %{$q->Vars};

print "Content-Type: text/html; charset=windows-1251\n\n";

unless ($fn) {
	exit
} else {
	my $sid = $q->cookie('_4SITESID') || $q->param('_4SITESID') || undef;
	$modules::Security::session = new CGI::Session("driver:File;serializer:Storable", $sid, {Directory=>$modules::Settings::c{dir}{cgi}.'_session'});
	$modules::Security::session->expires("+1d");
	delete @p{qw{fn}};
	my $path = qq{$modules::Settings::c{dir}{cgi}/_session};
	# Retrieving $SOAP object...
	open(RESULT,"<$path/_4site_soap_$sid") or modules::Debug::dump("$path/_4site_soap_$sid: $!",'ERROR');
	my $old = $/;
	undef $/;
	eval <RESULT>;
	modules::Debug::dump($@,'Eval ERROR') if $@;
	$/ = $old;
	close(RESULT);

	# Now doing so for %modules::Security::FORM
	open(RESULT,"<$path/_4site_FORM_$sid") or modules::Debug::dump("$path/_4site_FORM_$sid: $!",'ERROR');
	my $old = $/;
	undef $/;
	eval <RESULT>;
	modules::Debug::dump($@,'Eval ERROR') if $@;
	$/ = $old;
	close(RESULT);
	if (ref $modules::Core::soap eq 'modules::NoSOAP') {
		$modules::Core::soap = modules::NoSOAP->new($modules::Security::FORM{site_id})
	} else {
		my ($host,$cgiref,$al,$ap,$so) = $modules::DBfunctions::dbh->selectrow_array("SELECT host_fld,cgiref_fld,
													authlogin_fld,authpass_fld,soap_fld
													FROM site_tbl
													WHERE site_id=$modules::Security::FORM{site_id}");
		$SOAP::Constants::DO_NOT_USE_XML_PARSER = 1;
		my $s = SOAP::Lite
			->uri('http://'.$host.'/ServerAuth')
			->proxy('http://'.$host.$so,
					#options => {compress_threshold => 20000}
					);
		my $authInfo = $s->login($al,$ap);
		modules::Debug::dump($authInfo->faultstring,"authInfo Fault") if $authInfo->faultstring;
		$authInfo = SOAP::Header->name(authInfo => $authInfo);
		$modules::Core::soap = modules::AuthInfo->new($s,$authInfo);
	}
	my @fn = split '::'=>$fn;
	my $mod = shift @fn;
	$p{_session} = $modules::Security::session;
	eval qq{use modules::}.$mod.qq{; \$out .= modules::}.$fn.qq{(\$modules::Core::soap,(\%p))};
	modules::Debug::notice($@) if $@;
	print $out
}
