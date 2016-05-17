#!/usr/bin/perl -W
use CGI;
use CGI(escapeHTML);
use CGI::Carp qw(fatalsToBrowser);
use CGI::Session;
use SOAP::Lite;
# use Benchmark qw(:hireswallclock);
use Digest::MD5 qw(md5_hex);
use modules::Settings;
use modules::DBfunctions;
use modules::AuthInfo;
use modules::NoSOAP;
use modules::Interface;
use modules::Security;
use modules::Core;
use modules::Debug;
use strict;

$|++;
my $out;
my $q = new CGI;
$modules::DBfunctions::dbh = connectDB();
my $id = $q->param('id') || undef;

print "Content-Type: text/html; charset=windows-1251\n\n";

#print qq{<tr><td>ooooo $id 000000</td></tr>};
#exit;

unless ($id) {
	exit
} else {
	my $sid = $q->cookie('_4SITESID') || $q->param('_4SITESID') || undef;
	$modules::Security::session = new CGI::Session("driver:File;serializer:Storable", $sid, {Directory=>$modules::Settings::c{dir}{cgi}.'_session'});
	$modules::Security::session->expires("+1d");
	$q->param('_4SITESID',$modules::Security::session->id);
	my $host = $q->param('host_fld') || $modules::Security::session->param('host_fld');
	%modules::Security::FORM = ();
	$modules::Security::FORM{host_fld} = $modules::Security::session->param('host_fld') || $host;
	$modules::Security::FORM{cgiref_fld} = $modules::Security::session->param('cgiref_fld');
	my $site_id = $modules::Security::session->param('site');
	$modules::Security::FORM{site_id} = $modules::Security::FORM{s}||$site_id unless $modules::Security::FORM{site_id};
	my $sth = $modules::DBfunctions::dbh->selectrow_hashref("SELECT host_fld,homedir_fld,cgidir_fld,cgiref_fld,local_fld FROM site_tbl WHERE site_id=$site_id");
	foreach (keys %$sth) { $modules::Security::session->param($_,$sth->{$_}) }
	my ($al,$ap) = $modules::DBfunctions::dbh->selectrow_array("SELECT authlogin_fld,authpass_fld FROM site_tbl WHERE site_id=$site_id");
	if ($modules::Security::session->param('host_fld')) {
		$host = $modules::Security::session->param('host_fld');
		if ($modules::Security::session->param('local_fld') eq '1') {
			$modules::Core::soap = modules::NoSOAP->new($site_id)
		} else {
			$modules::Core::s = SOAP::Lite
				->uri('http://'.$modules::Security::session->param('host_fld').'/ServerAuth')
				->proxy('http://'.$modules::Security::session->param('host_fld').$modules::Security::session->param('cgiref_fld').'/SOAP/ServerAuth.pm',
						options => {compress_threshold => 20000}
						);
			my $authInfo = $modules::Core::s->login($al,$ap);
			modules::Debug::dump($authInfo->faultstring,"authInfo Fault") if $authInfo->faultstring;
			$authInfo = SOAP::Header->name(authInfo => $authInfo);
			$modules::Core::soap = modules::AuthInfo->new($modules::Core::s,$authInfo);
		}
	} elsif ($modules::Security::FORM{start} eq '1') {
		$modules::Security::session->param('module','')
	} else {
		$modules::Security::session->param('module','System')
	}

	$modules::Security::session->flush();

	my $label = $modules::Core::soap->getQuery("SELECT label_fld FROM page_tbl WHERE page_id=$id")->result;
	$label =~ s/<img[^>]+>//;

	$out .= qq{<h2>Кэширование страницы <b>&laquo;$label&raquo;</b></h2>
<form method="post" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl">
<input type="hidden" name="spage_id" value="$id">
<table class="tab" border="0" cellpadding="0" cellspacing="0">
<tr><td valign="top">
<table class="tab2" border="0" cellpadding="0" cellspacing="0">
}.modules::Page::page_cache_list($id).qq{
<tr><td>&nbsp;</td><td class="tar" colspan="2"><input type="Image" src="/img/but/change1.gif" title="Изменить" class="but" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"></td></tr>
<input type="hidden" name="act" value="edit_cache">
<input type="hidden" name="returnact" value="cache_page"></tr></table></td></tr></table>
}.modules::Comfunctions::logpass().qq{</form>
};
	modules::Security::extract_act($out);
#	$out .= modules::Page::page_select_xml($id);
	print $out
}
