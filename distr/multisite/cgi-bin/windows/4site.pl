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
use vars qw($q $sth $SHOW);

# Раздел констант
#### SOAP ####
# use constant LOCAL => 0;
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

# Here comes UPLOAD hack!
if ($ENV{'CONTENT_TYPE'} =~ m!^multipart/form-data;!) {
	my $fl;
	my @upload_flds = split /,/=>$q->param('upload');
	last unless scalar @upload_flds;
	foreach my $fld (@upload_flds) {
		my $fh = $q->upload($fld) or next;
		if ($fh =~ m!\\!) {
			my @_f = split m!\\!,$fh;
			$fl = pop @_f;
		} else {
			$fl = $fh
		}
		open (OUTFILE,">$modules::Settings::c{dir}{cgi}__tmp_${fld},${fl}");
		binmode(OUTFILE);
		while (<$fh>) {
			print OUTFILE $_;
		}
		$q->param($fld,"__tmp_${fld},${fl}");
		close(OUTFILE);
		close($fh);
	}
}

#print qq{<link rel="stylesheet" href="/style-4site.css" type="text/css">};

modules::Security::clean_session();

my $sid = $q->cookie('CGISESSID') || $q->param('CGISESSID') || undef;
$modules::Security::session = new CGI::Session("driver:File;serializer:Storable", $sid, {Directory=>$modules::Settings::c{dir}{cgi}.'_session'});

$modules::Security::session->expires("+1d");

$q->param('CGISESSID',$modules::Security::session->id);

my %k = %{$modules::Security::session->param_hashref()};
my @clean_list = grep { !/^(CGISESSID|login|password|_.+)/ || /(_id|_fld)$/ } keys %k;

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

# modules::Debug::dump(\%modules::Security::FORM,"FORM");

delete $modules::Security::FORM{returnact} if $modules::Security::FORM{start} eq '1';

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
			->proxy('http://'.$modules::Security::session->param('host_fld').$modules::Security::session->param('cgiref_fld').'/SOAP/ServerAuth.pl'
					, options => {compress_threshold => 10000}
					);
		my $authInfo = $modules::Core::s->login($al,$ap);
		modules::Debug::dump($authInfo->faultstring,"authInfo Fault") if ($authInfo->faultstring or !$authInfo);
		$authInfo = SOAP::Header->name(authInfo => $authInfo);
		$modules::Core::soap = modules::AuthInfo->new($modules::Core::s,$authInfo);
	}
} elsif ($modules::Security::FORM{start} eq '1') {
	$modules::Security::session->param('module','')
} else {
	$modules::Security::session->param('module','System')
}

my $uid = $modules::Security::session->param('user') || modules::Core::getUID($site_id);
if (defined $uid) {
	$modules::Security::session->param('user',$uid) unless $modules::Security::session->param('user');

	my $returnact;
	if ($modules::Security::FORM{'returnact'}) {
		$returnact = $modules::Security::FORM{'returnact'};
		$modules::Security::session->param('module',modules::Core::getModuleRA($returnact));
		$modules::Security::FORM{module} = $modules::Security::session->param('module');
	} else {
		unless ($modules::Security::session->param('module') eq 'System') {
			$modules::Security::permission = 'START';
			unless (defined $modules::Security::session->param('module')) {
				$modules::Security::permission = 'SITESTART';
			}
		} else {
			my $mod = modules::Core::getModuleSite($modules::Security::FORM{'site'});
			if (defined $mod) {
				$modules::Security::session->param('module',$mod) unless $modules::Security::session->param('module');
				$modules::Security::FORM{module} = $modules::Security::session->param('module');
				$returnact = $modules::Security::FORM{'returnact'} || modules::Core::getReturnAct($modules::Security::session->param('module'));
				$modules::Security::FORM{'returnact'} = $returnact;
			} else {
				push @{$modules::Security::ERROR{module}}, qq{Нет модулей, разрешённых для доступа!}
			}
		}
	}

	unless ($modules::Security::permission) {
		$modules::Security::session->param('enabled',$modules::DBfunctions::dbh->selectrow_array("SELECT menuenable_fld FROM ".lc($modules::Security::session->param('module'))."_forms_tbl WHERE ".lc($modules::Security::session->param('module'))."_forms_fld='$modules::Security::FORM{'returnact'}'"));

		my $module_id = $modules::DBfunctions::dbh->selectrow_array("SELECT module_id FROM module_tbl WHERE module_fld='".$modules::Security::session->param('module')."'");
		my $form_id = $modules::DBfunctions::dbh->selectrow_array("SELECT ".lc($modules::Security::session->param('module'))."_forms_id FROM ".lc($modules::Security::session->param('module'))."_forms_tbl WHERE ".lc($modules::Security::session->param('module'))."_forms_fld='$modules::Security::FORM{'returnact'}'");
		if ($modules::Security::FORM{'returnact'} eq 'bugreport') {
			$modules::Security::FORM{module} ='System';
			#modules::Debug::notice("Cuckoo!!",$modules::Security::FORM{module});
			$modules::Security::permission = 'READ_ONLY'
		} else {

		$modules::Security::permission = $modules::DBfunctions::dbh->selectrow_array("SELECT permission_fld FROM permission_tbl WHERE user_id=$uid AND site_id=$site_id AND module_id=$module_id AND form_id=$form_id");
		}
	}
} else {
	push @{$modules::Security::ERROR{user}}, qq{Вы &#0151; неправильный пользователь!}
}

# Go in there even if we got PERMISSION
if (defined $modules::Security::permission) {
	if ($modules::Security::FORM{'act'} eq 'add_favorites') {
		eval "modules::Core::add_favorites()"
	} elsif ($modules::Security::FORM{'act'} and $modules::Security::permission eq 'EXEC') {
		my $action = $modules::Security::FORM{'act'};
		my $module = modules::Core::getModule($action);
		if ($module) {
			my $key = md5_hex($modules::Security::session->id.$action);
			my $k = $modules::DBfunctions::dbh->selectrow_array("SELECT sessionactkey_fld FROM sessionactkey_tbl WHERE session_fld='".$modules::Security::session->id."' AND sessionactkey_fld='$key'");
			#modules::Debug::notice("Calculated Key... <b>$k</b>",'',2);
			if ($key eq $modules::DBfunctions::dbh->selectrow_array("SELECT sessionactkey_fld FROM sessionactkey_tbl WHERE session_fld='".$modules::Security::session->id."' AND sessionactkey_fld='$key'")) {
				eval "use modules::".$module." qw(:actions); modules::".$module."::".$action."()";
				if ($modules::Validate::error) {
					push @{$modules::Security::ERROR{act}}, $modules::Validate::err_msg;
				} elsif ($@) {
					push @{$modules::Security::ERROR{act}}, qq{<b>Вызов неизвестной функции "$action"!!!</b><br>($@)<br>Проверьте исходный код.};
				}
			} else {
				push @{$modules::Security::ERROR{act}}, qq{Вызов недопустимой функции "<b>$action</b>"!!!<br>Проверьте исходный код.}
			}
		} else {
			if ($modules::DBfunctions::dbh->selectrow_array("SELECT extperm_fld FROM user_tbl WHERE user_id=$modules::Security::FORM{user}") eq '1') {
				eval $action."()"
			}
			# NO MODULE NO CRY
		}
	} elsif ($modules::Security::permission eq 'READ_ONLY') {
		1
	}
} else {
	push @{$modules::Security::ERROR{act}}, qq{У Вас нет прав на просмотр данной формы!}
}

$modules::Security::session->param('host_fld',$host) if $host;
$modules::Security::FORM{host_fld} = $modules::Security::session->param('host_fld');
my $sid = $modules::Security::session->id;
$modules::Security::session->flush();
insertStat(site => $modules::DBfunctions::dbh->selectrow_array("SELECT site_fld FROM site_tbl WHERE host_fld='$modules::Security::FORM{host_fld}'"),
		   hostfrom => $modules::Security::FORM{_SESSION_REMOTE_ADDR},
		   module => $modules::Security::FORM{module},
		   form => $modules::Security::FORM{returnact},
		   user => $modules::Security::FORM{login},
		   act => $modules::Security::FORM{act});


if (scalar(keys %modules::Security::ERROR)==0) {
	if (defined $modules::Security::permission) {
		if ($modules::Security::permission ne 'START') {
			if ($modules::Security::FORM{module} eq 'System') {
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

######## Subs ########
##
sub insertStat {
	#return unless scalar @_;
	#return unless (scalar @_ % 2)==1;
	my %p = @_;
	delete $p{site} if $p{module} eq 'System';
	my $sql = "INSERT INTO actionstat_tbl SET ";
	my @sql;
	foreach (keys %p) {
		push @sql=>$_."_fld='$p{$_}'"
	}
	$sql .= join ', '=>@sql;
	$sql .= ", datetime_fld=NOW()";
	#modules::Debug::notice($sql);
	$modules::DBfunctions::dbh->do($sql);
}

exit;

__END__

=head1 NAME

B<4site.pl> — Главный скрипт.

=head1 SYNOPSIS

Главный скрипт Системы.

=head1 DESCRIPTION

Главный скрипт, осуществляющий сборку страниц Системы.

Используется, когда нужно показать форму.

=head2 Принцип действия

Получает из вызывающей формы множество полей: C<act>, C<returnact>, C<login>, C<password> (если пользователь только что пришел, то C<login> и C<password>).
После чего:

=over 3

=item 1

Проверяет, тот ли пользователь (по значениям, сохранённым в сессии) пришёл.
Если не тот или истекла (или не существует) сессия, то выводит соответствующее сообщение об ошибке и заканчивает работу.
Если пользователь только что вошел в систему, то выводится его стартовая форма со списком доступных сайтов.

=item 2

Происходит запрос прав доступа к форме данного пользователя. Определяется интерфейс пользователя.
Если прав доступа нет (нет такой формы, доступ не разрешен и т.д.), то выводит соответствующее сообщение и заканчивает работу.

=item 3

Показывает форму по полю C<returnact>.

=back

=cut
