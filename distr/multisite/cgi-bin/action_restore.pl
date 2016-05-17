#!/usr/bin/perl -w

use strict;
use DBI;
use modules::DBfunctions;
use modules::AuthInfo;
use modules::NoSOAP;
use modules::Settings;
use modules::Security;
use modules::Core;
use modules::Debug;

print "Content-Type: text/html; charset=windows-1251\n\n";
print qq{<link href="/style-4site.css" rel="stylesheet" type="text/css" />};

my $dbh = _connectDB();
$modules::DBfunctions::dbh = connectDB();

my $site = 340;
my $site_id = 319;
my $user = 27;
my %f;

my $se = $modules::DBfunctions::dbh->selectrow_hashref("SELECT host_fld,homedir_fld,cgidir_fld,cgiref_fld,local_fld,soap_fld FROM site_tbl WHERE site_id=$site_id");
%modules::Security::FORM = %$se;
#foreach (keys %$site) { $modules::Security::FORM{$_} = $site->{$_} }
my ($al,$ap) = $modules::DBfunctions::dbh->selectrow_array("SELECT authlogin_fld,authpass_fld FROM site_tbl WHERE site_id=$site_id");

modules::Debug::dump(\%modules::Security::FORM);

if ($modules::Security::FORM{'host_fld'}) {
	my $host = $modules::Security::FORM{'host_fld'};
	if ($modules::Security::FORM{'local_fld'} eq '1') {
		$modules::Core::soap = modules::NoSOAP->new($site_id)
	} else {
		$modules::Core::s = SOAP::Lite
			->uri('http://'.$modules::Security::FORM{'host_fld'}.'/ServerAuth')
			->proxy('http://'.$modules::Security::FORM{'host_fld'}.$modules::Security::FORM{'soap_fld'},
					#options => {compress_threshold => 10000}
					);
		$SOAP::Constants::DO_NOT_USE_XML_PARSER = 1;
		my $delay = 8;
		my $retries = 10;
		my $attempt = 0;
		#modules::Debug::dump($modules::Core::s);
		my $authInfo = undef;
		while ( (!eval { $authInfo = $modules::Core::s->login($al,$ap) }) && (++$attempt <= $retries) ) {
			modules::Debug::notice(sprintf("Attempt %d of %d failed. Retry in %d seconds", $attempt, $retries, $delay));
			sleep($delay)
		}
		#modules::Debug::dump($authInfo);
		modules::Debug::dump($authInfo->faultstring,"authInfo Fault") if ($authInfo->faultstring or !$authInfo);
		$authInfo = SOAP::Header->name(authInfo => $authInfo);
		$modules::Core::soap = modules::AuthInfo->new($modules::Core::s,$authInfo);
		#modules::Debug::dump($modules::Core::soap);
	}

	print qq{<h2>Recovering actions of '$user' @ '$site'</h2>};

	my $sth = $dbh->prepare("SELECT *
							FROM actionstat_tbl
							WHERE user_fld=$user
							AND site_fld=$site
							AND formhash_fld!=''
							ORDER BY datetime_fld ASC");
	$sth->execute();
	if ($sth->rows) {
		while (my $a = $sth->fetchrow_hashref) {
			modules::Debug::notice('',$a->{datetime_fld});
			eval $a->{formhash_fld};
			$f{act} = $a->{act_fld};
			#modules::Debug::dump(\%f,'',1);
			%modules::Security::FORM = (%modules::Security::FORM, %f);
			my $action = $modules::Security::FORM{act};
			my $module = modules::Core::getModule($action);
			if ($module) {
				my $actstr = "use modules::".$module." qw(:actions); modules::".$module."::".$action."()";
				modules::Debug::notice($actstr,'',1);
				#eval $str;
				#if ($modules::Validate::error) {
				#	push @{$modules::Security::ERROR{act}}, $modules::Validate::err_msg;
				#} elsif ($@) {
				#	push @{$modules::Security::ERROR{act}}, qq{<b>Вызов неизвестной функции "$action"!!!</b><br>($@)<br>Проверьте исходный код.};
				#}
			}
		}
	} else {
		print qq{<h3>No actions there.</h3>}
	}
} else {
	print qq{<h2>Oops!.. No host...</h2>}
}

#### Subroutines ####
##
sub _connectDB {
	my $dbi = "dbi:mysql:tmp_db:localhost";
	$dbh = DBI->connect($dbi, 'root', '');
	$dbh->do("SET NAMES 'cp1251'");
	return $dbh
} # connectDB
