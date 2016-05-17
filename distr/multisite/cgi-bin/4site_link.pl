#!/usr/bin/perl
#
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use CGI::Session;
use SOAP::Lite;
use Digest::MD5 qw(md5_hex);
use strict;
use modules::Settings;
use modules::DBfunctions;
use modules::AuthInfo;
use modules::NoSOAP;
use modules::Interface;
use modules::Security;
use modules::Core;
use modules::Debug;
use vars qw($q $sth $SHOW @INSTALLED);

# Раздел констант

#### ACL ####
use constant READ_ONLY => 1;
use constant EXEC => 2;
use constant ADMIN => 4;

$|++;
$q = new CGI;
$modules::DBfunctions::dbh = connectDB();
#$modules::Security::SOAP_error = "";
undef $modules::Validate::err_msg;
undef $modules::Validate::error;

# Вывод HTTP-заголовка
print "Content-Type: text/html; charset=windows-1251\n\n";

$q->delete('start','x','y');
my $login = $q->param('login');
my $pass = $q->param('password');
my $flink_id = $q->param('formlink_id');
my ($uid,$stid,$mid,$fid) = $modules::DBfunctions::dbh->selectrow_array("SELECT fl.user_id,site_id,module_id,form_id
														FROM formlink_tbl as fl, user_tbl as u
														WHERE login_fld='$login'
														AND pass_fld='$pass'
														AND fl.user_id=u.user_id
														AND formlink_id=$flink_id");
#print qq{<link rel="stylesheet" href="/style-4site.css" type="text/css">};

modules::Security::clean_session();

my $sid = $q->cookie('_4SITESID') || $q->param('_4SITESID') || undef;
$modules::Security::session = new CGI::Session("driver:File;serializer:Storable", $sid, {Directory=>$modules::Settings::c{dir}{cgi}.'_session'});

$modules::Security::session->expires("+1d");

$q->param('_4SITESID',$modules::Security::session->id);

my %k = %{$modules::Security::session->param_hashref()};
my @clean_list = grep { !/^(_4SITESID|login|password|_.+)/ || /(_id|_fld)$/ } keys %k;

# Заполнение %FORM
my $host = $q->param('host_fld') || $modules::Security::session->param('host_fld');
%modules::Security::FORM = ();
$modules::Security::FORM{host_fld} = $modules::Security::session->param('host_fld') || $host;
$modules::Security::FORM{cgiref_fld} = $modules::Security::session->param('cgiref_fld');
$modules::Security::session->clear([@clean_list]);
$modules::Security::session->save_param($q);
%k = %{$modules::Security::session->param_hashref()};
foreach (keys %k) { $modules::Security::FORM{$_} = $k{$_} }

# Adjust dates (if any)
my $st = $modules::Security::FORM{stdate};
my $end = $modules::Security::FORM{enddate};
if ($st or $end) {
	$st = sprintf "%4d-%02d-%02d",reverse split /\./=>$st;
	$end = sprintf "%4d-%02d-%02d",reverse split /\./=>$end;
	if ($end le $st) {
		($st,$end) = ($end,$st);
	}
	$modules::Security::FORM{stdate} = $st;
	$modules::Security::FORM{stdate} =~ s/^(\d+)-(\d+)-(\d+)$/$3.$2.$1/;
	$modules::Security::FORM{enddate} = $end;
	$modules::Security::FORM{enddate} =~ s/^(\d+)-(\d+)-(\d+)$/$3.$2.$1/;
}

$::SHOW = $modules::Security::FORM{show};

#modules::Debug::dump([$uid,$stid,$mid,$fid],"FORM");

unless ($uid && $stid && $mid && $fid) {
	push @{$modules::Security::ERROR{user}}, qq{Формы с такими параметрами нет!};
	modules::Interface::showForm('error');
	exit
} else {
	$modules::Security::FORM{site_id} = $stid;
	$modules::Security::FORM{site} = $stid;
	$modules::Security::FORM{user} = $uid;
	$modules::Security::session->param('site',$stid);
	$modules::Security::session->param('user',$uid);
	my $site_id = $stid;
	my $sth = $modules::DBfunctions::dbh->selectrow_hashref("SELECT host_fld,homedir_fld,cgidir_fld,cgiref_fld,local_fld FROM site_tbl WHERE site_id=$site_id");
	foreach (keys %$sth) { $modules::Security::session->param($_,$sth->{$_}) }
	my ($al,$ap) = $modules::DBfunctions::dbh->selectrow_array("SELECT authlogin_fld,authpass_fld FROM site_tbl WHERE site_id=$site_id");
	$modules::Security::FORM{host_fld} = $modules::Security::session->param('host_fld');
	my $mod = $modules::DBfunctions::dbh->selectrow_array("SELECT module_fld FROM module_tbl WHERE module_id=$mid");
	$modules::Security::FORM{module} = $mod;
	$modules::Security::session->param('module',$mod);
	my $sql = sprintf "SELECT %s_forms_fld FROM %s_forms_tbl WHERE %s_forms_id=%d",lc($mod),lc($mod),lc($mod),$fid;
	$modules::Security::FORM{returnact} = $modules::DBfunctions::dbh->selectrow_array($sql);

	my $sth = $modules::DBfunctions::dbh->prepare("SELECT module_fld FROM site_module_tbl as sm, module_tbl as m WHERE site_id=$modules::Security::FORM{site_id} AND m.module_id=sm.module_id");
	$sth->execute();
	while (my $m = $sth->fetchrow_array) {
		push @::INSTALLED=>$m
	}

	if ($modules::Security::session->param('host_fld')) {
		$host = $modules::Security::session->param('host_fld');
		if ($modules::Security::session->param('local_fld') eq '1') {
			$modules::Core::soap = modules::NoSOAP->new($site_id)
		} else {
			$modules::Core::s = SOAP::Lite
				->uri('http://'.$modules::Security::session->param('host_fld').'/ServerAuth')
				->proxy('http://'.$modules::Security::session->param('host_fld').$modules::Security::session->param('cgiref_fld').'/SOAP/ServerAuth.pm',
						options => {compress_threshold => 10000}
						);
			my $authInfo = $modules::Core::s->login($al,$ap);
			modules::Debug::dump($authInfo->faultstring,"authInfo Fault") if ($authInfo->faultstring or !$authInfo);
			$authInfo = SOAP::Header->name(authInfo => $authInfo);
			$modules::Core::soap = modules::AuthInfo->new($modules::Core::s,$authInfo);
		}
	}
	unless ($modules::Security::permission) {
		$modules::Security::session->param('enabled',$modules::DBfunctions::dbh->selectrow_array("SELECT menuenable_fld FROM ".lc($mod)."_forms_tbl WHERE ".lc($mod)."_forms_fld='$modules::Security::FORM{returnact}'"));

		my $module_id = $mid;
		my $form_id = $fid;
		$modules::Security::permission = $modules::DBfunctions::dbh->selectrow_array("SELECT permission_fld FROM permission_tbl WHERE user_id=$uid AND site_id=$site_id AND module_id=$module_id AND form_id=$form_id");
	}
	unless (defined $modules::Security::permission) {
		push @{$modules::Security::ERROR{act}}, qq{У Вас нет прав на просмотр данной формы!}
	}
	$modules::Security::session->param('host_fld',$host) if $host;
	$modules::Security::FORM{host_fld} = $modules::Security::session->param('host_fld');
	my $sid = $modules::Security::session->id;
	$modules::Security::session->flush();

	#modules::Debug::dump(\%modules::Security::FORM);
	#modules::Debug::dump($modules::Security::session);


	insertStat(site => $modules::DBfunctions::dbh->selectrow_array("SELECT site_fld FROM site_tbl WHERE host_fld='$modules::Security::FORM{host_fld}'"),
			   hostfrom => $modules::Security::FORM{_SESSION_REMOTE_ADDR},
			   module => $modules::Security::FORM{module},
			   form => $modules::Security::FORM{returnact},
			   user => $modules::Security::FORM{login},
			   act => $modules::Security::FORM{act},
			   _form => $modules::Security::FORM{act}?\%modules::Security::FORM:'');

	if (scalar(keys %modules::Security::ERROR)==0) {
		if (defined $modules::Security::permission) {
			if ($modules::Security::permission ne 'START') {
				if ($modules::Security::FORM{module} eq 'System') {
					#modules::Debug::notice("System form, eh?..",$modules::Security::FORM{'returnact'});
					modules::Interface::showForm($modules::Security::FORM{'returnact'},'system')
				} elsif ($modules::Security::permission eq 'SITESTART') {
					modules::Interface::showForm('','site_start')
				} else {
					modules::Interface::showForm($modules::Security::FORM{'returnact'})
				}
			} else {
				modules::Interface::showForm('','start')
			}
			$Data::Dumper::Purity = 1;
			open(RESULT,">$modules::Settings::c{dir}{cgi}/_session/_4site_soap_$sid");
			print RESULT Data::Dumper->Dump([$modules::Core::soap],['$modules::Core::soap']);
			close(RESULT);
			open(RESULT,">$modules::Settings::c{dir}{cgi}/_session/_4site_FORM_$sid");
			print RESULT Data::Dumper->Dump([\%modules::Security::FORM],['*modules::Security::FORM']);
			close(RESULT);
		} else {
			modules::Interface::showForm('error')
		}
	} else {
		modules::Interface::showForm('error')
	}

}

######## Subs ########
##
sub insertStat {
	#return unless scalar @_;
	#return unless (scalar @_ % 2)==1;
	use Data::Dumper;
	my %p = @_;
	my $f;
	if (ref $p{_form} eq 'HASH') {
		my %_f = %{$p{_form}};
		foreach (keys %_f) {
			$_f{$_} = substr $_f{$_},0,100 if length $_f{$_}>100
		}
		$f = Data::Dumper->Dump([\%_f],['*f']);
		$f =~ s/'/\\'/g
	}
	delete $p{_form};
	delete $p{site} if $p{module} eq 'System';
	my ($m,$ff);
	$ff = $modules::DBfunctions::dbh->selectrow_array("SELECT menuname_fld FROM ".lc($p{module})."_forms_tbl WHERE ".lc($p{module})."_forms_fld='$p{form}'");
	$p{form} = $ff if $ff;
	$m = $modules::DBfunctions::dbh->selectrow_array("SELECT menuname_fld FROM module_tbl WHERE module_fld='$p{module}'");
	$p{module} = $m if $m;
	my $sql = "INSERT INTO actionstat_tbl SET ";
	my @sql;
	foreach (keys %p) {
		push @sql=>$_."_fld='$p{$_}'"
	}
	push @sql=>"formhash_fld='$f'";
	$sql .= join ', '=>@sql;
	$sql .= ", datetime_fld=NOW()";
	#modules::Debug::notice($sql); return;
	$modules::DBfunctions::dbh->do($sql);
}

exit;
