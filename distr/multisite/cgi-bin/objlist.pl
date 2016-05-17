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
my $ent = $q->param('moder_entity_id');
my $sid = $q->param('site');

print "Content-Type: text/html; charset=windows-1251\n\n";
#modules::Debug::dump($q,"Q");

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
	print qq{<select name="moder_objself_id"><option value="">-- Выберите --</option>};
	my @r1 = $s->getQuery("SELECT moder_object_fld,name_fld FROM moder_entity_tbl WHERE moder_entity_id=$ent")->paramsout;
	my ($type,$sent) = @{$r1[0]};
	if ($type eq 'table') {
		my ($cmn) = $sent =~ /(.+?)_tbl$/;
		my @r = $s->getQuery("SELECT ${cmn}_id,${cmn}_fld FROM $sent")->paramsout;
		foreach (@r) {
			print qq{<option value="$_->[0]">$_->[1]</option>}
		}
	} else {
		my @r = $s->getQuery("SELECT obj_id, obj_fld
							 FROM obj_tbl as o, objtype_tbl as ot
							 WHERE objtype_fld='$sent'
							 AND o.objtype_id=ot.objtype_id")->paramsout;
		foreach (@r) {
			print qq{<option value="$_->[0]">$_->[1]</option>}
		}
	}
	print qq{</select>}
}
