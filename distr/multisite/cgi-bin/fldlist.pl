#!/usr/bin/perl -w
use strict;
use CGI;
use Digest::MD5 qw(md5_hex);
use modules::Settings;
use modules::DBfunctions;
use modules::AuthInfo;
use modules::NoSOAP;
use modules::Security;
use modules::Core;
use modules::Comfunctions qw(:DEFAULT :records :file :elements :downlist);
use modules::Debug;

$|++;
my $out;
my $q = new CGI;
$modules::DBfunctions::dbh = connectDB();
my $ent = $q->param('enttype');
my $sent;
if ($ent eq 'table') {
	$sent = $q->param('table');
} elsif ($ent eq 'object') {
	$sent = $q->param('objtype');
} else {
	$sent = ''
}
my $sid = $q->param('site');

print "Content-Type: text/html; charset=windows-1251\n\n";

unless ($sid) {
	print " ";
	exit
} else {
	my ($host,$cgiref,$al,$ap,$so,$local) = $modules::DBfunctions::dbh->selectrow_array("SELECT host_fld,cgiref_fld,
												authlogin_fld,authpass_fld,soap_fld,local_fld
												FROM site_tbl
												WHERE site_id=$sid");
	my $s;
	if ($local) {
		$s = modules::NoSOAP->new($sid)
	} else {
		$SOAP::Constants::DO_NOT_USE_XML_PARSER = 1;
		$s = SOAP::Lite
			->uri('http://'.$host.'/ServerAuth')
			->proxy('http://'.$host.$so,
					#options => {compress_threshold => 20000}
					);
		my $authInfo = $s->login($al,$ap);
		modules::Debug::dump($authInfo->faultstring,"authInfo Fault") if $authInfo->faultstring;
		$authInfo = SOAP::Header->name(authInfo => $authInfo);
		$modules::Core::soap = modules::AuthInfo->new($s,$authInfo);
	}
	if ($sent) {
		print start_table();
		if ($ent eq 'table') {
			my @r = $s->getQuery("SHOW FIELDS FROM $sent LIKE '%_fld'")->paramsout;
			my $i = 1;
			foreach (@r) {
				print qq{<tr class="tr_col}.($i % 2 +1).qq{"><td class="tal"><input type="checkbox" id="i$i" name="fld" value="$_->[0]" /></td><td class="tl" width="200"><label for="i$i">$_->[0]</label></td></tr>};
				$i++
			}
		} else {
			my $i = 1;
			my @r = $s->getQuery("SELECT opd.propertytype_id, propertytype_fld
								FROM objpropertydef_tbl as opd, propertytype_tbl as pt
								WHERE objtype_id=$sent
								AND pt.propertytype_id=opd.propertytype_id
								ORDER BY order_fld")->paramsout;
			foreach (@r) {
				print qq{<tr class="tr_col}.($i % 2 +1).qq{"><td class="tal"><input type="checkbox" id="i$i" name="fld" value="$_->[1]" /></td><td class="tl" width="200"><label for="i$i">$_->[1]</label></td></tr>};
				$i++
			}
		}
		print end_table()
	} else {
		print " "
	}


	print $out
}
