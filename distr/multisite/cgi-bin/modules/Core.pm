#!/usr/bin/perl
#
#

# Модуль
package modules::Core;
use Exporter;
our @ISA=qw(Exporter);
our @EXPORT=qw(getRights getAct getUID getForm module_list getRights filterByPerm getResult
				getModule getReturnAct get_actions getModuleRA getModuleSite fileselect
				add_setting del_setting edit_setting xModCall);
our %EXPORT_TAGS = (
				actions => [qw(add_function edit_function del_function
							add_favorites del_favorites add_setting
							del_setting edit_setting xModCall)],
				elements => [qw(template cgi_ref date_now now_datetime date
							stdate_find enddate_find
							user_id
							forms_feature_list
							user_list function_list
							function_downlist
							idfield tab_list sys_backup
							iso2date date2iso site_id fileselect now_time date_sql
							setting_add _4SITESID
							stdate_hidden enddate_hidden lag_hidden)],
					);
our @EXPORT_OK = (get_actions, @{$EXPORT_TAGS{elements}}, @{$EXPORT_TAGS{actions}});
our $VERSION=1.9;
use strict;
use POSIX qw(strftime);
use modules::Settings;
use modules::DBfunctions;
use modules::Debug;
use vars qw($host $soap $result %idfields $s);

sub get_actions {
	return $EXPORT_TAGS{actions}
}

################################################################################
################################## Elements ####################################
################################################################################

# Определение обработки элементов

sub cgi_ref { $modules::Settings::c{dir}{cgi_ref} }

sub _4SITESID { $modules::Security::FORM{_4SITESID} }

sub user_id { $modules::Security::FORM{user_id} }

sub site_id { $modules::Security::FORM{site_id} }

sub module_id { $modules::Security::FORM{module_id} }

sub date_now { date() }

sub iso2date {
	my $d = shift;
	$d =~ s/(\d{2,4})-(\d\d?)-(\d\d?)/$3.$2.$1/;
	return $d
}

sub date2iso {
	my $d = shift;
	$d =~ s/(\d\d?)\.(\d\d?)\.(\d{2,4})/$3-$2-$1/;
	return $d
}

sub now_datetime {
	date()
} # now_datetime

sub date {
	my $t = strftime "%d.%m.%Y", localtime;
	$t =~ s/^\s(\d)/0$1/;
	return $t
}

sub now_time {
	my $t = strftime "%H:%M:%S", localtime;
	$t =~ s/^\s(\d)/0$1/;
	return $t
}

sub date_sql {
	my ($y,$m,$d) = (localtime)[5,4,3];
	$m++; $y += 1900;
	my $t = sprintf "%4d%02d%02d",$y,$m,$d;
	return $t
}

sub _get_stdate {
	my $d = $modules::Security::FORM{stdate};
	$d ||= date();
	return $d
}

sub _get_enddate {
	my $d = $modules::Security::FORM{enddate};
	$d ||= date();
	return $d
}

sub stdate_find {
	my $d = _get_stdate();
	return qq{<input type="text"  name="stdate" id="_stdate" size="10" maxlength="10" value="$d">}
} # stdate_find

sub enddate_find {
	my $d = _get_enddate();
	return qq{<input type="text"  name="enddate" id="_enddate" size="10" maxlength="10" value="$d">}
} # enddate_find

sub stdate_hidden {
	my $d = _get_stdate();
	return qq{<input type="hidden" name="stdate" value="$d">}
} # stdate_find

sub enddate_hidden {
	my $d = _get_enddate();
	return qq{<input type="hidden" name="enddate" value="$d">}
} # enddate_find

sub wysiwyg {
	my $mod = lc $modules::Security::FORM{module};
	$mod = 'menu' if $mod eq 'page';
	my $fld = modules::ModSet::get_setting($mod,"WYSIWYG_fld");
	return (modules::ModSet::get_setting($mod,"WYSIWYG"))?<<EOJS:''
var oFCKeditor = new FCKeditor('$fld','700',500, 'Default');
// oFCKeditor.BasePath = "/fckeditor/";
oFCKeditor.ReplaceTextarea();
EOJS
}

sub tab_list {
	my $out;
	my @r = $modules::Core::soap->getQuery("SHOW TABLES LIKE '%_tbl%'")->paramsout;
	my $i = 1;
	my @tabs;
	foreach (@r) {
		next if $_->[0] =~ /^xlog_/;
		$out .= qq{<tr class="}.(($i++ % 2)?"tr_col1":"tr_col2").qq{">};
		$out .= qq{<td class="tb"><input type="checkbox" name="tab_$_->[0]" id="tab$_->[0]" value="1"></td><td class="tl"><label for="tab$_->[0]">$_->[0]</label></td>};
   		$out .= qq{</tr>};
	}
	return $out;
} # tab_list

sub function_downlist {
	my $out;
	my @r = $modules::Core::soap->getQuery("SELECT function_tbl.function_id, function_tbl.menuname_fld,
							 funcgroup_tbl.funcgroup_fld
							 FROM function_tbl, funcgroup_tbl
							 WHERE function_tbl.funcgroup_id=funcgroup_tbl.funcgroup_id
							 ORDER BY funcgroup_tbl.funcgroup_fld, function_tbl.menuname_fld ASC")->paramsout;
	foreach (@r) {
		$out .= qq{<option value="$_->[0]">$_->[2] | $_->[1]</option>}
	}
	return $out
} # function_downlist

sub lag_hidden {
	return qq{<input type="hidden" name="lag" value="$modules::Security::FORM{lag}">}
}

sub function_list { # список форм
	my $logpass = logpass();
	my @r = $modules::Core::soap->getQuery("SELECT function_tbl.function_id, function_tbl.function_fld, function_tbl.menuname_fld,
							 function_tbl.funcgroup_id, funcgroup_tbl.funcgroup_fld, function_tbl.menuenable_fld
							 FROM function_tbl, funcgroup_tbl
							 WHERE function_tbl.funcgroup_id=funcgroup_tbl.funcgroup_id
							 ORDER BY function_tbl.funcgroup_id ASC")->paramsout;
	my $out;
	my $i = 1;
	foreach (@r) {
		my $funcgroup = downlist("funcgroup","funcgroup_fld","$_->[3]");
		$out .= qq{<tr class="}.(($i++ % 2)?"tr_col1":"tr_col2").qq{">}
		.qq{<form method="POST" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl" name="p$_->[0]">}
		.qq{<td><input type="checkbox" name="menuenable_fld" value="1"}.($_->[5]==1?" checked":"").qq{></td>}
		.qq{<td><input type="text"  name="menuname_fld" size="20" value="$_->[2]"></td>}
		.qq{<td><input type="text"  name="function_fld" size="20" value="$_->[1]"></td>}
		.qq{<td><select name="funcgroup_id"><option value="$_->[3]">$_->[4]</option>$funcgroup</select></td>}
		.qq{<td><input type="submit" class="but" value="Изменить"></td>}
		.qq{<input type="hidden" name="act" value="edit_function">}
		.qq{<input type="hidden" name="function_id" value="$_->[0]">}
		.qq{<input type="hidden" name="returnact" value="function">$logpass}
		.qq{<td><input type="button" class="del-but" value="Удалить" onclick="javascript:sub_del('p$_->[0]','del_function')"></td></tr></form>};
	}
	return $out
} # function_list

sub forms_feature_list { # список прав доступа к формам
	if ($modules::Security::session->param('user_id')) {
		my $out = feature_down_sep("user","function","userfunction_tbl","funcgroup","funcgroup_fld","menuname_fld","function_fld");
		my $login = $modules::DBfunctions::dbh->selectrow_array("SELECT login_fld
								 FROM user_tbl
								 WHERE user_id=$modules::Security::session->param('user_id')");
		$out = "<h2>Редактирование прав пользователя $login</h2>"."$out".qq{<p><input type="submit" class="but" value="Применить">};
		return $out
	}
	else { return "" }
} # forms_feature_list

sub setting_add {
	my ($mod) = $modules::Security::FORM{returnact} =~ /^(\w+?)_settings/;
	if ($modules::DBfunctions::dbh->selectrow_array("SELECT extperm_fld FROM user_tbl WHERE user_id=$modules::Security::FORM{user}") eq '1') {
		my $out .= qq{<br/><br/>
		<form method="POST" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl">
		<input type="hidden" name="tbl" value="${mod}_settings_tbl">
		<table class="tab" border="0" cellpadding="0" cellspacing="0">
			<tr><td>
			<table class="tab2" border="0" cellpadding="0" cellspacing="0">
			<tr><th>&nbsp;</th><th>Добавление настройки</th></tr>
			<tr class="tr_col1"><td class="tl">Название</td><td class="tal"><input type="text" name="${mod}_settings_fld" size="40"></td></tr>
			<tr class="tr_col2"><td class="tl">Тип</td><td class="tal"><input type="text" name="type_fld" size="40" value="TEXT"></td></tr>
			<tr class="tr_col1"><td class="tl">Описание</td><td class="tal"><textarea name="description_fld" cols="42" rows="5"></textarea></td></tr>
			<tr><td>&nbsp;</td><td class="tal"><input type="Image" src="/img/but/add1.gif" title="Добавить" class="but" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"></td></tr>
		</table></td></tr></table>}.logpass().returnact().qq{
		<input type="hidden" name="act" value="add_setting">
		</form>};
		return $out
	}
}

################################################################################
################################### Actions ####################################
################################################################################

######################### Юзеры, группы, функции ###############################

sub add_function {
	$modules::Comfunctions::FORM{menuenable_fld} = 0 if !defined $modules::Security::FORM{menuenable_fld};
	&add_record("function_tbl")
} # add_function

sub edit_function {
	$modules::Comfunctions::FORM{menuenable_fld} = 0 if !defined $modules::Security::FORM{menuenable_fld};
	&edit_record("function_tbl")
} # edit_function

sub del_function {
	$modules::Validate::result_msg = modules::DBfunctions::get_erased_msg_text("function_tbl",$modules::Security::FORM{function_id})."<br/>";
	&del_record("function_tbl");
	$modules::Core::soap->doQuery("DELETE FROM userfunction_tbl WHERE function_id=$modules::Security::FORM{function_id}");
	} # del_function

################################# Избранное ####################################

sub add_favorites {
	my $mod = lc $modules::Security::FORM{module};
	my $modid = $modules::DBfunctions::dbh->selectrow_array("SELECT module_id FROM module_tbl WHERE module_fld='$modules::Security::FORM{module}'");
	my $frm_id = $modules::DBfunctions::dbh->selectrow_array("SELECT ${mod}_forms_id FROM ${mod}_forms_tbl WHERE ${mod}_forms_fld='$modules::Security::FORM{function_fld}'");
	return if $modules::DBfunctions::dbh->selectrow_array("SELECT favorites_id FROM favorites_tbl WHERE user_id=$modules::Security::FORM{user} AND site_id=$modules::Security::FORM{site} AND module_id=$modid AND form_id=$frm_id");
	$modules::Security::FORM{user_id} = $modules::Security::FORM{user};
	$modules::Security::FORM{site_id} = $modules::Security::FORM{site};
	$modules::Security::FORM{module_id} = $modid;
	$modules::Security::FORM{form_id} = $frm_id;
	Madd_record('favorites_tbl');
} # add_favorites

sub del_favorites {
 	$modules::Validate::result_msg = modules::DBfunctions::get_erased_msg_text("favorites_tbl",$modules::Security::FORM{favorites_id})."<br/>";
	del_record("favorites_tbl")
} # del_favorites

sub getUID {
	my $site_id = shift;
	my $l = $modules::Security::session->param('login');
	my $p = $modules::Security::session->param('password');
	my $sql = "SELECT user_id FROM user_tbl WHERE login_fld=".$modules::DBfunctions::dbh->quote($l)." AND pass_fld='$p'";
	#my $st = $modules::DBfunctions::dbh->selectrow_array("SELECT CURTIME(); SELECT module_fld FROM module_tbl WHERE module_id=1");
	#modules::Debug::dump($st || $DBI::error);
	#print $sql; return;
	my $uid = $modules::DBfunctions::dbh->selectrow_array($sql);
	return undef unless $uid;
	my $blocked = $modules::DBfunctions::dbh->selectrow_array("SELECT block_fld FROM user_tbl WHERE user_id=$uid");
	return ($blocked eq 'N')?$uid:undef
}

sub getReturnAct {
	my $first = shift || (module_list())[0];
	my $mid = $modules::DBfunctions::dbh->selectrow_array("SELECT module_id FROM module_tbl WHERE module_fld='$first'");
	my $uid = $modules::Security::FORM{user} || $modules::DBfunctions::dbh->selectrow_array("SELECT user_id
																							FROM user_tbl
																							WHERE login_fld=".$modules::DBfunctions::dbh->quote($modules::Security::FORM{login})."
																							AND pass_fld='$modules::Security::FORM{password}'");
	return undef unless $uid;
	my $f = $modules::DBfunctions::dbh->selectrow_array("SELECT mf.".lc($first)."_forms_fld
						   FROM ".lc($first)."_forms_tbl as mf, permission_tbl as p
							WHERE user_id=$uid
							AND site_id=$modules::Security::FORM{site_id}
							AND module_id=$mid
							AND p.form_id=mf.".lc($first)."_forms_id
							AND menuenable_fld='1'
						   ORDER BY order_fld
						   LIMIT 1");
}

sub getForm {
	my $form = shift;
	my $mod;
	my @uses = module_list();
	push @uses=>'System' if $form eq 'bugreport';
	return undef unless defined $uses[0];
	use modules::Page qw(:elements);
	use modules::Comfunctions qw(:DEFAULT :downlist :records :elements :file);
	use modules::System qw(:elements);
	foreach my $m (@uses) {
		eval "use modules::$m qw(:elements)";
		print "$@<br/>" if $@;
	}

	my $_m = getModuleRA($form);
	unless ($_m) {
		$mod = $modules::Settings::c{dir}{cgi}.'template/'
	} else {
		$mod = $modules::Settings::c{dir}{cgi}."modules/".$_m.'/'
	}
	my $out;
	open (IN, "<".$mod.$form.'.htm') or die "ERROR: ($mod$form.htm) $! !!!";
	my @file = <IN>;
	close(IN);
	$|++;
	my %h;
	foreach (@file) {
		if (/\<\!--\#include\svirtual="([^"]+)"--\>/) {
			my $fff = $1;
			my ($m,$f) = $fff =~ /(?:(\w+)::)?(\w+)/;
			#$m ||= 'Core';
			#modules::Debug::dump([$m,$f],'getForm');
			if ($m) {
				s~\<\!--\#include\svirtual="([^"]+)"--\>~
				my $remove;
				eval "use modules::".$m." qw(:elements)" unless $h{$m}++;
				(($remove = eval "modules::$m"."::"."$f()") or !$@)?$remove:qq{<p style="color: Red"><i>getForm:</i> <b>Вызов неизвестной функции "$m}.qq{::}.qq{$f" в строке $. !!!</b><br/>($@)<br/> Проверьте исходный код.</p>}
				~gex
			} else {
				s|\<\!--\#include\svirtual="([^"]+)"--\>|
				my $remove;
				(($remove = eval "$f()") or !$@)?$remove:qq{<p style="color: Red"><i>getForm:</i> <b>Вызов неизвестной функции "$f" в строке $. !!!</b><br/>($@)<br/> Проверьте исходный код.</p>}
				|gex
			}
		}
		$out .= $_;
		#print $_;
	}
	return $out;
}

sub module_list {
	my @modlist;
	#modules::Debug::notice("SELECT sm.module_id,m.module_fld,m.menuname_fld
	#					  FROM module_tbl as m, site_module_tbl as sm
	#					  WHERE m.module_id=sm.module_id AND
	#					  site_id=".$modules::Security::FORM{'site'}."
	#					  ORDER BY sm.module_id",'module_list',2);
	my $sth = $modules::DBfunctions::dbh->prepare("SELECT sm.module_id,m.module_fld,m.menuname_fld
						  FROM module_tbl as m, site_module_tbl as sm
						  WHERE m.module_id=sm.module_id AND
						  site_id=".$modules::Security::FORM{site}."
						  ORDER BY sm.module_id");
	$sth->execute();
	while (my @row = $sth->fetchrow_array) {
		push @modlist, $row[1]
	}
	@modlist = sort { $a cmp $b } @modlist;
	#modules::Debug::dump(\@modlist);
	return @modlist
}

sub filterByPerm {
	my ($content,$perm) = @_;
	if ($perm eq 'READ_ONLY') {
		# Rip off every "act" field
		# DISABLE out every field
		my @c = split /\n/, $content;
		foreach (@c) {
			s{(type="(submit|radio|reset|checkbox|file|password)")}{$1 disabled="disabled"}gi;
			s{<input\s(type="hidden"\sname="act"|name="act"\stype="hidden")[^>]*>}{}gi;
			s{(type="text"|<textarea)}{$1 readonly="readonly"}gi;
		}
		$content = join "\n",@c
	}
	return $content
}

sub getResult {
	my $act = shift;
	my $result;
	my $module = getModule($act);
	return undef unless $module;
	if (my $res = eval 'use modules::'.$module.' qw(:actions); modules::'.$module.'::'.$act.'()') {
		$result = $res
	} else {
		push @{$modules::Security::ERROR{'act'}}, qq{<b>Ошибка на действии '$act'</b>:<br/><i>$@</i>};
	}
	return $result
}

sub getModule {
	my $act = shift;
	my $mod;
	my @uses = module_list();
	#push @uses=>"Core";
	@uses = reverse @uses;
	my @a;
	return undef unless scalar @uses;
	foreach my $m (@uses) {
		#my $m = $uses[$i];
		my $res = eval 'use modules::'.$m.'; modules::'.$m.'::get_actions()';
		#modules::Debug::dump($res,'getModule',3);
		next unless $res;
		if (scalar grep { $_ eq $act } @$res) {
			$mod = $m;
			last
		}
	}
	$mod ||= 'Core';
	return $mod
}

sub getModuleRA {
	my $act = shift;
	my $mod;
	my @uses = module_list();
	push @uses=>'System' if $act eq 'bugreport';
	return undef unless defined $uses[0];
	foreach my $m (@uses) {
		if ($modules::DBfunctions::dbh->selectrow_array("SELECT COUNT(".lc($m)."_forms_fld) FROM ".lc($m)."_forms_tbl WHERE ".lc($m)."_forms_fld='$act'")>0) {
			$mod = $m;
			last
		}
	}
	return $mod
}

sub getModuleSite {
	my $site = shift;
	my $uid = $modules::Security::session->param('user');
	my $mod = $modules::DBfunctions::dbh->selectrow_array("SELECT DISTINCT module_id FROM permission_tbl WHERE user_id=$uid AND site_id=$site ORDER BY module_id LIMIT 1");
	return undef unless $mod;
 	my $m = $modules::DBfunctions::dbh->selectrow_array("SELECT module_fld FROM module_tbl WHERE module_id=$mod");
	return $m
}

sub error {
	my $out;
	return "" unless scalar keys %modules::Security::ERROR;
	while (my ($k,$v) = each %modules::Security::ERROR) {
		$out .= join '<br/>',@$v;
		$out .= qq{<br/>}
	}
	return $out
}

sub add_setting {
	my ($fld) = $modules::Security::FORM{tbl} =~ /^(\w+?)_settings_tbl/;
	$fld = qq{${fld}_settings_fld};
	$modules::Core::soap->doQuery("INSERT INTO $modules::Security::FORM{tbl}
								  ($fld,description_fld,type_fld)
								  VALUES
									('$modules::Security::FORM{$fld}',
									'$modules::Security::FORM{description_fld}',
									'$modules::Security::FORM{type_fld}')");
}

sub del_setting {
	my $module = lc $modules::Security::FORM{module};
	my $tbl = $modules::Security::FORM{tbl};
	my ($t) = $tbl =~ /^(\w+?)_settings_/;
	my $id = $t."_settings_id";
	$modules::Core::soap->getQuery("DELETE FROM $tbl
								   WHERE $id=".$modules::Security::FORM{$id})
}

sub edit_setting {
	#modules::Debug::dump(\%modules::Security::FORM);
	my @chlang = grep { /^chlang/ } keys %modules::Security::FORM;
	#my @usedef = grep { /^usedef/ } keys %modules::Security::FORM;
	#modules::Debug::dump(\@chlang,'chlang');
	#modules::Debug::dump(\@usedef);
	my $module = lc $modules::Security::FORM{module};
	my $tbl = $modules::Security::FORM{tbl};
	my ($t) = $tbl =~ /^(\w+?)_settings_/;
	my $sid = $t."_settings_id";
	my @del = get_array($modules::Security::FORM{del});
	my @dellang = get_array($modules::Security::FORM{dlang});
	@dellang = grep { defined $_ and $_ } @dellang;
	@del = grep { defined } @del;
	#modules::Debug::dump(\@dellang,"dellang");
	my @id = get_array($modules::Security::FORM{$sid});
	my @val = grep { /^value/ } keys %modules::Security::FORM;
	my @lang = get_array($modules::Security::FORM{language_id});
	#modules::Debug::dump(\@id,"ID");
	#modules::Debug::dump(\@lang,"language_id");
	#modules::Debug::dump(\@val,"value");
	my @type = get_array($modules::Security::FORM{type_fld});
	my @name = get_array($modules::Security::FORM{name});
	#modules::Debug::dump(\@name,'name');

	#return;

	# Deleting custom language settings
	if (scalar @dellang) {
		foreach (@dellang) {
			my $sql = "DELETE FROM $tbl WHERE $sid=$_";
			#modules::Debug::notice($sql,"DELETE lang");
			$modules::Core::soap->doQuery($sql)
		}
	}
	# Deleting the rest of...
	if (scalar @del) {
		for my $i (0..$#del) {
			my $id = $del[$i];
			my $sql = "DELETE FROM $tbl WHERE $sid=$id";
			#modules::Debug::notice($sql,"DELETE");
			$modules::Core::soap->doQuery($sql)
		}
	}
	#modules::Debug::dump(\@type,'type');
	foreach my $i (0..@id) {
		next if scalar grep { $_==$id[$i] } (@del,@dellang);
		next unless exists $modules::Security::FORM{'value'.$id[$i]};
		#modules::Debug::notice($id[$i],'get in');
		my $val = $modules::Security::FORM{'value'.$id[$i]};
		$val =~ s!'!\\'!g;
		#modules::Debug::dump($val,$id[$i]); next;
		#modules::Debug::notice("SELECT $sid FROM $tbl WHERE ${t}_settings_fld='$name[$i]' AND language_id=$lang[$i]",'CHECK');
		my $sql;
		if ($lang[$i] ne '' && !$modules::Core::soap->getQuery("SELECT $sid FROM $tbl WHERE ${t}_settings_fld='$name[$i]' AND language_id=$lang[$i]")->result) {
			$sql = "INSERT INTO $tbl SET
								   ${t}_settings_fld='$name[$i]',
								   language_id=$lang[$i],
								   type_fld='$type[$i]',
								   value_fld='$val'";
			#modules::Debug::dump($sql);
			$modules::Core::soap->doQuery($sql)
		} else {
			$sql = "UPDATE $tbl
								SET
								value_fld='$val',
								type_fld='$type[$i]'
								WHERE $sid=$id[$i]";
			#modules::Debug::dump($sql);
			$modules::Core::soap->doQuery($sql)
		}
	}
	return;
}

sub xModCall {
	my ($mod,$meth,$type,@params) = @_;
	#modules::Debug::dump(\@params,'xModCall',1);
	my $type = ($type eq 'a')?'qw(:actions)':(($type eq 'e')?'qw(:elements)':'');
	unless ($mod) {
		modules::Debug::notice(qq{No MODULE given},'xModCall')
	}
	unless ($mod) {
		modules::Debug::notice(qq{MODULE w/o METHOD given},'xModCall')
	}
	return undef unless ($mod and $meth);
	my ($res,@res);
	if (wantarray()) {
		my @res = eval "use modules::$mod $type; my \@res = $meth(\@params)";
		if ($@) {
			modules::Debug::dump($@,qq{LIST $mod::$meth()})
		} else {
			return @res
		}
	} elsif (defined wantarray()) {
		my $res = eval "use modules::$mod $type; my \$res = $meth(\@params)";
		if ($@) {
			modules::Debug::dump($@,qq{SCALAR $mod::$meth()})
		} else {
			return $res
		}
	} else {
		eval "use modules::".$mod." $type; modules::".$mod."::".$meth."(\@params)";
		modules::Debug::dump($@,qq{$mod::$meth()}) if $@;
	}
}

1;
__END__

=head1 NAME

B<Core.pm> — Модуль ядра Системы.

=head1 SYNOPSIS

Модуль ядра Системы.

=head1 DESCRIPTION

Модуль ядра Системы. Включает в себя объекты и функции, нужные любому другому модулю.

=head2 cgi_ref

Возвращает путь к CGI-директории от корня сайта.

=over 4

=item Вызов:

C<< <!--#include virtual="cgi_ref"--> >>

=item Пример вызова:

C<< <!--#include virtual="cgi_ref"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 date_now

Возвращает текущую дату в формате MySQL.

=over 4

=item Вызов:

C<< <!--#include virtual="date_now"--> >>

=item Пример вызова:

C<< <!--#include virtual="date_now"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 iso2date

Возвращает текущую дату в формате "ДД.ММ.ГГГГ".

=over 4

=item Вызов:

C<< <!--#include virtual="iso2date"--> >>

=item Пример вызова:

C<< <!--#include virtual="iso2date"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 date2iso

Возвращает текущую дату в формате "ГГГГ-ММ-ДД".

=over 4

=item Вызов:

C<< <!--#include virtual="date2iso"--> >>

=item Пример вызова:

C<< <!--#include virtual="date2iso"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 now_datetime

Возвращает текущую дату и время в формате 'DD.MM.YYYY hh:mm:ss'.

=over 4

=item Вызов:

C<< <!--#include virtual="now_datetime"--> >>

=item Пример вызова:

C<< <!--#include virtual="now_datetime"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 date

Возвращает текущую дату в формате 'DD.MM.YYYY'.

=over 4

=item Вызов:

C<< <!--#include virtual="date"--> >>

=item Пример вызова:

C<< <!--#include virtual="date"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 stdate_(find|hidden)

Возвращает поле с текущей начальной датой в формате 'DD.MM.YYYY' для операций поиска. Hidden делает то же, но в скрытом поле.

=over 4

=item Вызов:

C<< <!--#include virtual="stdate_(find|hidden)"--> >>

=item Пример вызова:

C<< <!--#include virtual="stdate_(find|hidden)"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 enddate_(find|hidden)

Возвращает поле с текущей конечной датой в формате 'DD.MM.YYYY' для операций поиска. Hidden делает то же, но в скрытом поле.

=over 4

=item Вызов:

C<< <!--#include virtual="enddate_(find|hidden)"--> >>

=item Пример вызова:

C<< <!--#include virtual="enddate_(find|hidden)"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 tab_list

Выводит список таблиц Системы для дампа БД.

=over 4

=item Вызов:

C<< <!--#include virtual="tab_list"--> >>

=item Пример вызова:

C<< <!--#include virtual="tab_list"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 function_downlist

Выпадающий список функций Системы.

=over 4

=item Вызов:

C<< <!--#include virtual="function_downlist"--> >>

=item Пример вызова:

C<< <!--#include virtual="function_downlist"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 lag_downlist_sel

Выпадающий список временнЫх периодов для поиска.

=over 4

=item Вызов:

C<< <!--#include virtual="lag_downlist_sel"--> >>

=item Пример вызова:

C<< <!--#include virtual="lag_downlist_sel"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 function_list

Список пользователей для редактирования.

=over 4

=item Вызов:

C<< <!--#include virtual="function_list"--> >>

=item Пример вызова:

C<< <!--#include virtual="function_list"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

L<downlist|::Comfunctions/"downlist">, L<logpass|::Comfunctions/"logpass">.

=back

=head2 forms_feature_list

Список прав доступа к формам.

=over 4

=item Вызов:

C<< <!--#include virtual="forms_feature_list"--> >>

=item Пример вызова:

C<< <!--#include virtual="forms_feature_list"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

L<feature_down_sep|::Comfunctions/"feature_down_sep">.

=back

=head2 (add|del|edit)_function

Добавление/удаление/изменение формы в системе.

=over 2

=item Примечания:

Напрямую не вызывается. Передаётся только через поле B<act> вызывающей HTML-формы.

=item Зависимости:

L<add_record|::Comfunctions/"add_record">, L<edit_record|::Comfunctions/"edit_record">, L<del_record|::Comfunctions/"del_record"> соответственно.

=back

=head2 (add|del)_favorites

Добавление/удаление формы в/из "Favorites".

=over 2

=item Примечания:

Напрямую не вызывается. Передаётся только через поле B<act> вызывающей HTML-формы.

=item Зависимости:

L<Madd_record|::Comfunctions/"Madd_record">, L<del_record|::Comfunctions/"del_record"> соответственно.

=back

=head2 setting_add

Выводит форму добавления настройки.

=over 4

=item Вызов:

C<< <!--#include virtual="setting_add"--> >>

=item Пример вызова:

C<< <!--#include virtual="setting_add"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head1 AUTHOR

DAY, Method Lab.

=head1 BUGS

No known ones yet. ;))

=head1 SEE ALSO

=head1 COPYRIGHT

E<copy> Copyright 2004, Method Lab

=cut
