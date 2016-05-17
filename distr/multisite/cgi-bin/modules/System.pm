#!/usr/bin/perl
#
#
# Модуль
package modules::System;
use Exporter;
our @ISA=qw(Exporter);
our @EXPORT=qw();
our %EXPORT_TAGS = (
				actions => [qw(add_sysuser edit_sysuser del_sysuser
							add_action_message edit_action_message del_action_message
							edit_perms edit_module
							add_site edit_site del_site edit_modbysite order_form
							add_module edit_module_forms order_modules
							edit_help edit_perms_overall create_site)],
				elements => [qw(action_downlist actionmsg_list
							check_db check_table check_field
							tab_downlist user_downlist
							db_dump idfield
							user_list site_list site_edit mod_list
							site_downlist mod_by_site_list form_by_module_list
							forms_list fileselect module_downlist
							table_select site_downlist1 site1_downlist site2_downlist
							table_compare db_table_select modname module_conf module_conf2
							module_download table_validate modbysite_downlist
							modpic modid modheadpic module_order_drag
							form_order_drag mirror_downlist sitemirror_downlist
							action_by_mod_downlist form_by_mod_downlist se_list
							module_check forms_overall_list actionstat_list
							clone_progress fileselect_ms clone_downlist
							module_test modbysite_list)],
					);
our @EXPORT_OK = (get_actions, @{$EXPORT_TAGS{elements}}, @{$EXPORT_TAGS{actions}});
our $VERSION=1.9;
use strict;
use CGI qw(escapeHTML);
use POSIX qw(strftime);
use Archive::Zip qw(:ERROR_CODES :CONSTANTS);
use modules::Settings;
use modules::DBfunctions;
use modules::Comfunctions qw(:DEFAULT :downlist :records :elements :file);
use modules::Core;
use modules::ModSet;

use vars qw(%idfields);

sub get_actions {
	return $EXPORT_TAGS{actions}
}

################################################################################
################################## Elements ####################################
################################################################################

sub modname {
	my ($mod,$name) = $modules::DBfunctions::dbh->selectrow_array("SELECT module_fld,menuname_fld FROM module_tbl WHERE module_id=$modules::Security::FORM{module_id}");
	return qq{$name ($mod)}
}

sub modid {
	return $modules::Security::FORM{module_id}
}

sub modpic {
	return $modules::DBfunctions::dbh->selectrow_array("SELECT pic_fld FROM module_tbl WHERE module_id=$modules::Security::FORM{module_id}")
}

sub modheadpic {
	return $modules::DBfunctions::dbh->selectrow_array("SELECT headpic_fld FROM module_tbl WHERE module_id=$modules::Security::FORM{module_id}")
}

sub user_list { # список пользователей
	my $logpass = logpass();
	my $sth = $modules::DBfunctions::dbh->prepare("SELECT user_id, login_fld,
							 pass_fld, block_fld,
							 extperm_fld
							 FROM user_tbl
							 ORDER BY login_fld ASC");
	$sth->execute();
	my $out;
	my $i = 1;
	while (my @row = $sth->fetchrow_array) {
		my $self = ($row[0]==$modules::Security::FORM{user});
		$out .= qq{<form method="POST" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl">
		<tr class="tr_col}.($i++ % 2 +1).qq{">
			<td class="tal"><input type="text"  name="login_fld" size="10" value="$row[1]"></td>
			<td class="tal"><input type="password"  name="pass_fld" size="10" value="$row[2]"></td>
			<td class="tal"}.($self?' style="border: 2px solid Red; background-color: #FFE1E1" title="Вы не можете сделать это сами"':'').qq{><input type="checkbox" name="block_fld" value="Y"}.(($row[3] eq 'Y')?' checked':'').($self?' disabled':'').qq{></td>
			<td class="tal"}.($self?' style="border: 2px solid Red; background-color: #FFE1E1" title="Вы не можете сделать это сами"':'').qq{><input type="checkbox" name="extperm_fld" value="1"}.(($row[4]==1)?' checked':'').($self?' disabled':'').qq{></td>
			<td class="tal"><input type="Image" src="/img/but/change1.gif" title="Изменить" class="but" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"}.($self?' onclick="return checkSelf()"':'').qq{></td>
			<input type="hidden" name="act" value="edit_sysuser">
			<input type="hidden" name="self" value="$self">
			<input type="hidden" name="user_id" value="$row[0]">
			<input type="hidden" name="returnact" value="users">$logpass</form>
			<form method="POST" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl">
			<td class="tal"}.($self?' style="border: 2px solid Red; background-color: #FFE1E1" title="Вы не можете сделать это сами"':'').qq{><input type="Image" src="/img/but/delete}.($self?'3.gif" disabled title="Удалить нельзя"':qq{1.gif" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)" title="Удалить"}).qq{></td>
			<input type="hidden" name="act" value="del_sysuser">
			<input type="hidden" name="user_id" value="$row[0]">
			<input type="hidden" name="returnact" value="users">$logpass
		</tr>
		</form>};
	}
	return $out
}

sub se_list {
	my $out;
	$out .= start_table().head_table('Название','&nbsp;');
	my $sth = $modules::DBfunctions::dbh->prepare("SELECT * FROM searchengines_tbl");
	$sth->execute();
	my $i = 1;
	while (my @row = $sth->fetchrow_array) {
		$out .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{">
		<td class="tl">$row[1]</td>
		<td class="tal"><input type="Image" src="/img/but/delete_s1.gif" title="Удалить" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"></td>
		</tr>}
	}
	$out .= end_table();
	return $out
}

sub site_list {
	my $logpass = logpass();
	my $sth = $modules::DBfunctions::dbh->prepare("SELECT site_id,site_fld,host_fld
							 FROM site_tbl
							 WHERE site_fld<>'System'
							 ORDER BY site_fld");
	$sth->execute();
	my $out;
	my $i = 1;
	my %site;
	while (my @row = $sth->fetchrow_array) {
		$site{$row[1]} = "$row[0]|$row[2]"
	}
	my %s;
	foreach (sort { (split ' ',$a)[-1] cmp (split ' ',$b)[-1] || (split ' ',$a)[0] cmp (split ' ',$b)[0]} keys %site) {
		my ($n,$sect) = $_ =~ /(.+)\s(.+)$/; # split ' ';
		$sect =~ s/\(([^)]+?)\)$/$1/;
		my ($id,$host) = split /\|/=>$site{$_};
		$s{$sect} .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{">
		<form method="POST" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl" name="ff$id">
		<td class="tl"><b><a href="#" onclick="document.forms.ff$id.submit(); return false" title="Редактировать свойства сайта">$_</a></b>&nbsp;(http://<b><i>$host</i></b>)
		</td>
		<input type="hidden" name="returnact" value="site_edit">
		<input type="hidden" name="site_id" value="$id">$logpass</form>
		<form method="POST" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl">
		<td class="tal"><input type="Image" src="/img/but/delete_s1.gif" title="Удалить" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)" onclick="return checkYes();"></td>
		<input type="hidden" name="act" value="del_site">
		<input type="hidden" name="site_id" value="$id">
		<input type="hidden" name="returnact" value="sites">$logpass</form></tr>};
	}
	foreach (sort {$a cmp $b} keys %s) {
		$out .= qq{<tr class="tr_col3"><td colspan="2" class="tl"><b>$_</b></td></tr>}.$s{$_}
	}
	return $out
}

sub site_edit {
	my $logpass = logpass();
	my @row = $modules::DBfunctions::dbh->selectrow_array("SELECT *
							 FROM site_tbl
							 WHERE site_id=$modules::Security::FORM{site_id}");
	my $sth = $modules::DBfunctions::dbh->prepare("SELECT *
							 FROM site_domain_tbl
							 WHERE site_id=$modules::Security::FORM{site_id}");
	$sth->execute();
	my @doms;
	while (my $d = $sth->fetchrow_array) {
		push @doms,$d
	}
	my $doms = join "\n",@doms;
	my $out;
	$out .= qq{<form method="post" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl" name="site">
<table class="tab">
<tr>
	<td class="tl">Название</td>
	<td class="tal"><input type="text"  name="site_fld" size="32" value="$row[1]"></td>
</tr>
<tr>
	<td class="tl">URL</td>
	<td class="tal"><input type="text"  name="host_fld" size="32" value="$row[2]"></td>
</tr>
<tr>
	<td class="tl">Домены<br/>(каждый на новой строке)</td>
	<td class="tal"><textarea  name="domains" cols="32" rows="5">$doms</textarea></td>
</tr>
<tr>
	<td class="tl">Зеркало</td>
	<td class="tal"><select name="mirror_id"><option value="0">< без зеркала ></option>}.mirror_downlist($row[14]).qq{</select></td>
</tr>
<tr>
	<td class="tl"><label for="l">Локальный</label></td>
	<td class="tal"><input type="checkbox" name="local_fld" id="l" value="1"}.(($row[13] eq '1')?" checked":"").qq{></td>
</tr>
<tr>
	<td class="tl"><label for="cl">Тест (клон)</label></td>
	<td class="tal"><input type="checkbox" name="clone_fld" value="1"}.(($row[-2] eq '1')?" checked":"").qq{ id="cl"></td>
</tr>
<tr style="background-color: #FFE1E1">
	<td class="tl">SOAP-Auth login</td>
	<td class="tal"><input type="text"  name="authlogin_fld" size="16" maxlength="16" value="$row[11]"></td>
</tr>
<tr style="background-color: #FFE1E1">
	<td class="tl">SOAP-Auth password</td>
	<td class="tal"><input type="text"  name="authpass_fld" size="32" maxlength="64" value="$row[12]"></td>
</tr>
<tr class="tr_col1">
	<td class="tl">DB host</td>
	<td class="tal"><input type="text"  name="dbhost_fld" size="32" value="$row[3]"></td>
</tr>
<tr class="tr_col1">
	<td class="tl">DB name</td>
	<td class="tal"><input type="text"  name="dbname_fld" size="32" value="$row[4]"></td>
</tr>
<tr class="tr_col1">
	<td class="tl">DB user</td>
	<td class="tal"><input type="text"  name="dbuser_fld" size="32" value="$row[5]"></td>
</tr>
<tr class="tr_col1">
	<td class="tl">DB pass</td>
	<td class="tal"><input type="text"  name="dbpass_fld" size="10" value="$row[6]"></td>
</tr>
<tr class="tr_col2" style="border-top: 2px solid Red; border-left: 2px solid Red; border-right: 2px solid Red">
	<td class="tl">Home DIR</td>
	<td class="tal"><input type="text"  name="homedir_fld" size="32" value="$row[7]"></td>
</tr>
<tr class="tr_col2" style="border-left: 2px solid Red; border-right: 2px solid Red">
	<td class="tl">htdocs DIR</td>
	<td class="tal"><input type="text"  name="htdocs_fld" size="32" value="$row[8]"></td>
</tr>
<tr class="tr_col2" style="border-left: 2px solid Red; border-right: 2px solid Red">
	<td class="tl">CGI DIR</td>
	<td class="tal"><input type="text"  name="cgidir_fld" size="32" value="$row[9]"></td>
</tr>
<tr class="tr_col2" style="border-bottom: 2px solid Red; border-left: 2px solid Red; border-right: 2px solid Red">
	<td class="tl">CGI_ref DIR</td>
	<td class="tal"><input type="text"  name="cgiref_fld" size="32" value="$row[10]"></td>
</tr>
<tr class="tr_col2" style="border-bottom: 2px solid Red; border-left: 2px solid Red; border-right: 2px solid Red">
	<td class="tl" title="Точный путь к ServerAuth">SOAP_ref PATH</td>
	<td class="tal"><input type="text"  name="soap_fld" size="32" value="$row[-1]"></td>
</tr>
<tr>
	<td>&nbsp;</td>
	<td><input type="Image" src="/img/but/change1.gif" title="Изменить" class="but" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"></td>
</tr>
</table>
$logpass
<input type="hidden" name="site_id" value="$row[0]">
<input type="hidden" name="act" value="edit_site">
<input type="hidden" name="returnact" value="sites">
</form>
};
	return $out
}

sub mod_list {
	my $logpass = logpass();
	my $sth = $modules::DBfunctions::dbh->prepare("SELECT module_id,menuname_fld,
												  descr_fld,module_fld
												  FROM module_tbl
												  ORDER BY menuname_fld");
	$sth->execute();
	my $out;
	my $i = 1;
	while (my @row = $sth->fetchrow_array) {
		my $ver = qq{[нет]};
		my @f = glob $modules::Settings::c{dir}{htdocs}."/_DISTRIB_/".$row[3]."*";
		if (-e $f[0]) {
			my $zip = Archive::Zip->new($f[0]);
			my $stamp = $zip->contents('module.stamp');
			$stamp =~ /\s'\w+\-(.+?)'/;
			$ver = $1 if $1;
		}
$out .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{">
		<form method="POST" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl" name="md$row[0]">
		<td class="tl"><a href="#" onclick="submit('md$row[0]')"><b>$row[1]</b> ($row[3])</a><br/>$row[2]</td>
		<td class="tl">$ver</td>
		<td class="del-red">}.($row[3] ne 'System'?qq{<input type="Image" src="/img/but/delete_s1.gif" title="Удалить" class="but" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)">}:qq{<img src="/img/error.gif" width="16" border="0" align="absmiddle" alt="Удалить нельзя" title="Удалить нельзя">}).qq{</td>
		<input type="hidden" name="returnact" value="module_edit">
		<input type="hidden" name="module_id" value="$row[0]">$logpass</form>
		</tr>};
	}
	return $out
}

sub module_downlist {
	my $out;
	my $sth = $modules::DBfunctions::dbh->prepare("SELECT module_id,module_fld,menuname_fld
							 FROM module_tbl
							 ".($modules::Security::FORM{returnact} ne 'perms_overall'?'':"WHERE module_id!=19 ")."ORDER BY menuname_fld");
	$sth->execute();
	while (my @row = $sth->fetchrow_array) {
		$out .= qq{<option value="$row[0]"}.(($row[0]==$modules::Security::FORM{module_id})?" selected":"").qq{>$row[2] ($row[1])</option>};
	}
	return $out
}

sub form_order_drag {
    my $out;
    if ($modules::Security::FORM{show}) {
		my ($m,$mn) = $modules::DBfunctions::dbh->selectrow_array("SELECT module_fld,menuname_fld FROM module_tbl WHERE module_id=$modules::Security::FORM{module_id}");
         $out .= qq{<form name="fo" method="post" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl">
                    <input type="hidden" name="show" value="1">
                    <input type="hidden" name="module_id" value="$modules::Security::FORM{module_id}">
		<h2>Формы модуля &laquo;$m ($mn)&raquo;</h3>
		<p class="note"><b>Примечание:</b> чтобы поменять местами формы, необходимо навести мышку на&nbsp;блок с&nbsp;формой и&nbsp;перетащить в&nbsp;нужное место. После всех действий нажать кнопку &laquo;Изменить&raquo;.</p>
		<table class="tab_gal" border="0" cellpadding="0" cellspacing="0"><tr><td>};
		my $sth = $modules::DBfunctions::dbh->prepare("SELECT * FROM ".lc($m)."_forms_tbl ORDER BY order_fld");
		$sth->execute();
		$out .= qq{<ul id="gpix" class="gpic">
		};
		my $i = 1;
    	while (my @row = $sth->fetchrow_array) {
            $out .= qq{<li id="gpix_$i"><table class="tab" width="98%"><tr class="tr_col}.($i++ % 2 +1).qq{" id="pp$row[0]">};
            $out .= qq{<td class="tl" height="24" nowrap><b>$row[2]</b> ($row[1])</td>
            </tr></table></li>
            };
        }
        $out .= qq{</ul></td></tr>
		<tr><td class="tar"><input type="Image" src="/img/but/change1.gif" title="Изменить" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)" onclick="this.form.order.value=Sortable.serialize('gpix');"></td></tr>
		</table>};
    }
    return $out
}

sub order_form {
	my @order = grep { s/^gpix\[\]=// } split /&/=>$modules::Security::FORM{order};
	my %o;
	@o{@order} = (1..scalar @order);
	unshift @order=>0;
	$o{'0'} = '_';
	my $m = $modules::DBfunctions::dbh->selectrow_array("SELECT module_fld FROM module_tbl WHERE module_id=$modules::Security::FORM{module_id}");
	$m = lc($m).'_forms';
	my $sth = $modules::DBfunctions::dbh->prepare("SELECT ${m}_id,order_fld FROM ${m}_tbl ORDER BY order_fld");
	$sth->execute();
	my $i = 0;
	while (my @row = $sth->fetchrow_array) {
		$modules::DBfunctions::dbh->do("UPDATE ${m}_tbl
									  SET order_fld=".$o{$i+1}."
									  WHERE ${m}_id=".$row[0]);
		$i++;
	}
}

sub forms_list {
	my $out;
	$out .= qq{<input type="hidden" name="module_id" value="$modules::Security::FORM{module_id}">};
	my $m = $modules::DBfunctions::dbh->selectrow_array("SELECT module_fld FROM module_tbl WHERE module_id=$modules::Security::FORM{module_id}");
	my $sth = $modules::DBfunctions::dbh->prepare("SELECT * FROM ".lc($m)."_forms_tbl");
	$sth->execute();
	my $i = 1;
	my @files = glob $modules::Settings::c{dir}{cgi}.'modules/'.$m.'/*.htm';
	@files = grep { s!$modules::Settings::c{dir}{cgi}modules/$m/!!; s/\.htm$// } @files;
	my @ex;
	while (my @row = $sth->fetchrow_array) {
		push @ex, $row[1];
		#modules::Debug::dump(\@row);
		my $plugged = -e $modules::Settings::c{dir}{cgi}.'modules/'.$m.'/'.$row[1].'.htm';
		$out .= qq{<tr class="}.(($plugged)?("tr_col".($i++ % 2 +1)):"tr_error").qq{">
		<td><input type="text"  size="20" value="$row[2]" name="ni$row[0]"></td>
		<td><input type="text"  size="20" value="$row[5]" name="nh$row[0]"></td>
		<td class="tl"><b>$row[1].htm</b></td>
		<td class="tal"><input type="checkbox" name="e$row[0]" value="1"}.(($row[3] eq '1')?" checked":"").qq{></td>
		<td class="tal"><input type="checkbox" name="p$row[0]" value="1"}.(($plugged)?" checked":"").qq{></td>
		<td class="tal"><input type="Image" src="/img/but/delete_s1.gif" title="Удалить" class="but" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"></td>
		<input type="hidden" name="x$row[0]" value="1">
		</tr>}
	}
	my %seen;
	@seen{@files} = ();
	delete @seen{@ex};
	my @only = keys %seen;
	if (scalar keys %seen) {
		foreach (keys %seen) {
			$out .= qq{<tr class="tr_file">
			<td><input type="text"  size="20" name="nn$_"></td>
			<td><input type="text"  size="20" name="nhn$_"></td>
			<td class="tl">$_.htm</td>
			<td class="tal"><input type="checkbox" name="ne$_"></td>
			<td class="tal"><input type="checkbox" name="np$_"></td>
			<td></td>
			</tr>}
		}
	}
	return $out
}

sub site_downlist {
	my $out;
	my $sel = shift || $modules::Security::FORM{site_id};
	my $sth = $modules::DBfunctions::dbh->prepare("SELECT site_id,site_fld
							 FROM site_tbl
							 ORDER BY site_fld");
	$sth->execute();
	my %site;
	while (my @row = $sth->fetchrow_array) {
		$site{$row[1]} = $row[0]
	}
	my %s;
	foreach (sort { (split ' ',$a)[-1] cmp (split ' ',$b)[-1] || (split ' ',$a)[0] cmp (split ' ',$b)[0]} keys %site) {
		my ($n,$sect) = $_ =~ /(.+)\s(.+)$/;
		$sect =~ s/\(([^)]+)\)/$1/;
		if ($sect) {
			$s{$sect} .= qq{<option value="$site{$_}"}.(($site{$_}==$sel)?" selected":"").qq{>$_</option>};
		} else {
			$out .= qq{<option value="$site{$_}"}.(($site{$_}==$sel)?" selected":"").qq{>$_</option>}
		}
	}
	foreach (sort {$a cmp $b} keys %s) {
		$out .= qq{<optgroup label="$_">}.$s{$_}.qq{</optgroup>}
	}
	return $out
}

sub clone_downlist {
	my $out;
	my $sel = shift || $modules::Security::FORM{clone_id};
	my $sth = $modules::DBfunctions::dbh->prepare("SELECT site_id,site_fld
							 FROM site_tbl
							 WHERE site_fld<>'System'
							 AND clone_fld='1'
							 ORDER BY site_fld");
	$sth->execute();
	my %site;
	while (my @row = $sth->fetchrow_array) {
		$site{$row[1]} = $row[0]
	}
	my %s;
	foreach (sort { (split ' ',$a)[-1] cmp (split ' ',$b)[-1] || (split ' ',$a)[0] cmp (split ' ',$b)[0]} keys %site) {
		my ($n,$sect) = $_ =~ /(.+)\s(.+)$/;
		$sect =~ s/\(([^)]+)\)/$1/;
		$s{$sect} .= qq{<option value="$site{$_}"}.(($site{$_}==$sel)?" selected":"").qq{>$_</option>};
	}
	foreach (sort {$a cmp $b} keys %s) {
		$out .= qq{<optgroup label="$_">}.$s{$_}.qq{</optgroup>}
	}
	return $out
}

sub sitemirror_downlist {
	my $out;
	my $sel = shift || $modules::Security::FORM{site_id};
	my $sth = $modules::DBfunctions::dbh->prepare("SELECT site_id,site_fld
							 FROM site_tbl
							 WHERE site_fld<>'System'
							 AND mirror_id!=0
							 ORDER BY site_fld");
	$sth->execute();
	my %site;
	while (my @row = $sth->fetchrow_array) {
		$site{$row[1]} = $row[0]
	}
	my %s;
	foreach (sort { (split ' ',$a)[-1] cmp (split ' ',$b)[-1] || (split ' ',$a)[0] cmp (split ' ',$b)[0]} keys %site) {
		my ($n,$sect) = $_ =~ /(.+)\s(.+)$/;
		$sect =~ s/\(([^)]+)\)/$1/;
		$s{$sect} .= qq{<option value="$site{$_}"}.(($site{$_}==$sel)?" selected":"").qq{>$_</option>};
	}
	foreach (sort {$a cmp $b} keys %s) {
		$out .= qq{<optgroup label="$_">}.$s{$_}.qq{</optgroup>}
	}
	return $out
}

sub user_shortlist {
	my $out;
	$out .= qq{<h3>Пользователи<h3>};
	$out .= start_table().head_table('Login','&nbsp;');
	my $sth = $modules::DBfunctions::dbh->prepare("SELECT user_id,login_fld,extperm_fld
												FROM user_tbl
												WHERE block_fld='N'
												ORDER BY extperm_fld DESC");
	$sth->execute();
	my $i = 1;
	while (my $u = $sth->fetchrow_hashref) {
		$out .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{"}.($u->{extperm_fld}?qq{ title="Расширенные права"}:'').qq{>
		<td class="tl" width="200"><label for="u$u->{user_id}">}.($u->{extperm_fld}?qq{<b>$u->{login_fld}</b>}:$u->{login_fld}).qq{</label></td>
		<td class="tal"><input type="checkbox" id="u$u->{user_id}" name="user_id" value="$u->{user_id}"/></td>
		</tr>}
	}
	$out .= end_table();
	return $out
}

sub module_list {
	my $out;
	$out .= qq{<h3>Модули<h3>};
	$out .= start_table().head_table('Название','&nbsp;');
	my $sth = $modules::DBfunctions::dbh->prepare("SELECT * FROM module_tbl WHERE module_id<>19 ORDER BY menuname_fld");
	$sth->execute();
	my $i = 1;
	while (my $m = $sth->fetchrow_hashref) {
		$out .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{" title="$m->{descr_fld}">
		<td class="tl"><label for="m$m->{module_id}"><b>$m->{menuname_fld}</b> ($m->{module_fld})</label></td>
		<td class="tal"><input type="checkbox" id="m$m->{module_id}" name="module_id" value="$m->{module_id}"/></td>
		</tr>}
	}
	$out .= end_table();
	return $out
}

sub modbysite_list {
	my $out;
	return unless $::SHOW;
	$out .= start_table().head_table('Модуль');
	my $sth = $modules::DBfunctions::dbh->prepare("SELECT sm.site_id, site_fld, host_fld
FROM site_module_tbl as sm LEFT JOIN site_tbl as s ON (s.site_id=sm.site_id)
WHERE module_id=$modules::Security::FORM{module_id}
ORDER BY host_fld");
	$sth->execute();
	my %s;
	while (my @r = $sth->fetchrow_array) {
		my ($sn,$srv) = $r[1] =~ /^(.+?)\s\(([^)]+)\)$/;
		push @{$s{$srv}}=>$sn
	}
	#modules::Debug::dump(\%s);
	my $i = 1;
	foreach my $srv (sort {$a cmp $b} keys %s) {
		$out .= qq{<tr class="tr_col4"><td class="tl" width="200"><b>$srv</b></td></tr>};
		foreach my $sn (sort {$a cmp $b} @{$s{$srv}}) {
			$out .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{"><td class="tl">&nbsp;&nbsp;$sn</td></tr>}
		}
	}
	$out .= end_table();
	return $out
}

sub mod_by_site_list {
	my $out;
	return unless $::SHOW;
	my $logpass = logpass();

	$out .= qq{<input type="checkbox" name="forcecreate" id="fc" value="1"> <label for="fc" class="tl"><b>Принудительно создавать таблицы</b></label><br/>
	<table border="0" cellpadding="0" cellspacing="0" class="warning" height="32" style="margin-top: 4px;">
<tr><td class="tl-big" rowspan="2" valign="top"><img src="/img/warning.gif" width="32" height="27" border="0" align="absmiddle" hspace="5"></td>
<td class="tl-big" valign="top"><span class="alert">Внимание!</span></td></tr><tr><td class="tl-big" valign="top">При отключенном переключателе таблицы в модуля будут создаваться только в том случае, если они отсутствуют.<br/>В противном случае, все таблицы создадутся принудительно.</td></tr></table>
<br/>}.start_table().head_table('Название','v','+','<img src="/img/del.gif" border="0" alt="Удалять таблицы при отключении модуля" title="Удалять таблицы при отключении модуля">');
	my $sth = $modules::DBfunctions::dbh->prepare("SELECT * FROM module_tbl WHERE module_id<>19 ORDER BY menuname_fld");
	$sth->execute();
		my $i = 1;
		my $m;
		while (my @row = $sth->fetchrow_array) {
			my $in = $modules::DBfunctions::dbh->selectrow_array("SELECT site_module_id FROM site_module_tbl WHERE site_id=$modules::Security::FORM{site_id} AND module_id=$row[0]");
 			$m++ if $in;
			$out .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{">
		<td class="tl"><label for="c$row[0]"><b>$row[2]</b></label></td>
		<td class="tal">}.(($in)?qq{<input type="checkbox" id="c$row[0]" name="c$row[0]" checked value="1" onclick="c($row[0])">}:"").qq{
		<input type="hidden" name="m" value="$row[0]"></td>
		<td class="tal">}.(($in)?"":qq{<input type="checkbox" name="cs$row[0]" value="1">}).qq{</td>
		<td class="del-red">}.(($in)?qq{<input type="checkbox" name="del" value="$row[0]" id="del$row[0]" disabled>}:'').qq{</td>
		</tr>}
		}
		$out .= qq{<tr>
		<td class="tar" colspan="4" align="right"><input type="Image" src="/img/but/change1.gif" title="Изменить" class="but" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"></td>
		<input type="hidden" name="act" value="edit_modbysite">
		<input type="hidden" name="site_id" value="$modules::Security::FORM{site_id}">};
	$out .= qq{</table></td></tr></table>
	<script type="text/javascript">
	function c(id) {
		var d = document;
		var ch = d.getElementById('c'+id);
		var del = d.getElementById('del'+id);
		if (ch.checked!=true) {
			del.disabled = false
		} else {
			del.disabled = true
		}
	}
	</script>
	};
	return $out
}

sub form_by_module_list {
	my $out;
	#modules::Debug::dump(\%modules::Security::FORM);
	if ($::SHOW && $modules::Security::FORM{site_id} && $modules::Security::FORM{user_id}) {
		$out .= qq{<input type="hidden" name="user_id" value="$modules::Security::FORM{user_id}"><input type="hidden" name="site_id" value="$modules::Security::FORM{site_id}">};
		$out .= start_table().head_table('Модуль / Формы','&nbsp;','R','X');
		my $extperm = $modules::DBfunctions::dbh->selectrow_array("SELECT extperm_fld FROM user_tbl WHERE user_id=$modules::Security::FORM{user_id}");
		$out .= qq{<tr class="tr_col4"><td colspan="3" class="tl"><b>Все модули</b></td><td class="tar"><input type="checkbox" value="1" title="Права на все модули" onclick="toggleAll(this)"></td></tr>};
		my @m;
		my $sql = "SELECT sm.module_id, module_fld, menuname_fld
														FROM module_tbl as m, site_module_tbl as sm
														WHERE sm.module_id=m.module_id".
														#($extperm?'':" AND module_fld<>'System'").
														" AND site_id=$modules::Security::FORM{site_id}
														ORDER BY sm.module_id";
		#modules::Debug::notice($sql);
		my $sth = $modules::DBfunctions::dbh->prepare($sql);
		$sth->execute();
		if ($sth->rows) {
			my $i = 1;
			while (my @row = $sth->fetchrow_array) {
				$out .= qq{<tr class="tr_col1">
					<td class="tl"><img src="/img/4site/menu/open.gif" border="0" align="absmiddle" hspace="2"><b>$row[2]</b></td><td colspan="3" class="tar"><input type="checkbox" id="c$row[1]"  name="c$row[1]" value="EXEC" onclick="exec('$row[1]')"></td></tr>};
				my $sth2 = $modules::DBfunctions::dbh->prepare("SELECT ".lc($row[1])."_forms_id,".lc($row[1])."_forms_fld,
															   menuname_fld,order_fld
															   FROM ".lc($row[1])."_forms_tbl
															   ORDER BY order_fld");
				$sth2->execute();
				my %frm;
				while (my @row = $sth2->fetchrow_array) {
					$frm{$row[0]} = [ @row[1,2,3] ]
				}
				foreach my $i (sort { $frm{$a}->[2] <=> $frm{$b}->[2] } keys %frm) {
					my $perm = $modules::DBfunctions::dbh->selectrow_array("SELECT permission_fld
																   FROM permission_tbl
																   WHERE site_id=$modules::Security::FORM{site_id}
														 AND user_id=$modules::Security::FORM{user_id}
														 AND module_id=$row[0]
														 AND form_id=$i");
					$out .= qq{<tr class="tr_col2">
					<td class="tr nbr"><b>$frm{$i}[1]</b> ($frm{$i}[0])</td><td class="tal"><input type="radio" name="c$row[1]$i"}.((!$perm)?" checked":"").qq{ value="_"/></td><td class="tal"><input type="radio" name="c$row[1]$i"}.(($perm eq "READ_ONLY")?" checked":"").qq{ value="READ_ONLY"/></td><td class="tal"><input type="radio" name="c$row[1]$i"}.(($perm eq "EXEC")?" checked":"").qq{ value="EXEC"/></td>};
					$out .= qq{</td></tr>}
				}
			}
			$out .= qq{<tr class="tr_col3"><td colspan="4" class="tar"><input type="Image" src="/img/but/apply1.gif" title="Применить" class="but" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"></td></tr>}
		} else {
			$out .= qq{<tr class="tr_col1"><td colspan="4" class="tl"><b color="Red">У данного пользователя<br/> на данном сайте<br/>ни к одной форме<br/>НЕТ ПРАВ ДОСТУПА</b></td></tr>}
		}
		$out .= qq{</table></td></tr></table>}
	}
	return $out
}

sub idfield {
	my @r = $modules::Core::soap->getQuery("SHOW TABLES")->paramsout;
	foreach (@r) {
		my @tablelist = @$_;
		my @r1 = $modules::Core::soap->getQuery("SHOW COLUMNS FROM $tablelist[0]")->paramsout;
		foreach (@r1) {
			my @fields = @$_;
			if ($fields[5] eq "auto_increment") {$idfields{$fields[0]} = "$fields[1]"}
		}
	}
} # idfield

sub user_downlist {
	my $out;
	my $sth = $modules::DBfunctions::dbh->prepare("SELECT user_id, login_fld
			   FROM user_tbl
			   ORDER BY login_fld ASC");
	$sth->execute();
	while (my @row = $sth->fetchrow_array) {
		$out .= qq{<option value="$row[0]"}.(($row[0]==$modules::Security::FORM{user_id})?" selected":"").qq{>$row[1]</option>};
	}
	return $out
} # user_downlist

sub action_downlist {
	my $act = shift || "";
	my @actions = @{$modules::Security::FORM{act_dnlist}} if $modules::Security::FORM{act_dnlist};
	unless (scalar @actions) {
		my @selfact = @{modules::System::get_actions()};
		my $sth = $modules::DBfunctions::dbh->prepare("SELECT module_fld
													FROM module_tbl
													WHERE module_fld<>'System'
													ORDER BY module_fld");
		$sth->execute();
		my $out;
		my @uses;
		while (my $mod = $sth->fetchrow_array) {
			push @uses, $mod
		}
		push @actions, @{eval "modules::Core::get_actions()"};
		foreach (@uses) {
			eval "use modules::".$_;
			my @act = @{eval "modules::".$_."::get_actions()"};
 			push @actions, @act;
			print $@."<br/>" if $@;
		}
		push @actions, @selfact;
		return "" if $@;
		@actions = sort {
						(split /_/,$a)[1] cmp (split /_/,$b)[1]
						|| (split /_/,$a)[0] cmp (split /_/,$b)[0]
						} @actions;
		## Конец обработки
		$modules::Security::FORM{act_dnlist} = [@actions]
	}
	my $out;
	foreach (@actions) {
		$out .= qq{<option value="$_"}.(($_ eq $act)?" selected":"").qq{>$_</option>}
	}
	return $out
} # action_downlist

sub action_by_mod_downlist {
	return unless $::SHOW;
	my $out = qq{<table class="tab_nobord"><tr><td class="tl">Действие</td><td class="tal"><select name="action_fld" onchange="if(this.value!=0){this.form.act.value='';this.form.submit()}"><option value="0">-- Выберите --</option>};
	my $act = $modules::Security::FORM{action_fld};
	my @actions = @{$modules::Security::FORM{act_dnlist}} if $modules::Security::FORM{act_dnlist};
	unless (scalar @actions) {
		my $mod = $modules::DBfunctions::dbh->selectrow_array("SELECT module_fld
													FROM module_tbl
													WHERE module_id=$modules::Security::FORM{module_id}");
		eval "use modules::".$mod;
		my @act = @{eval "modules::".$mod."::get_actions()"};
		push @actions, @act;
		print $@."<br/>" if $@;
		return "" if $@;
		@actions = sort {
						(split /_/,$a)[1] cmp (split /_/,$b)[1]
						|| (split /_/,$a)[0] cmp (split /_/,$b)[0]
						} @actions;
		## Конец обработки
		$modules::Security::FORM{act_dnlist} = [@actions]
	}
	foreach (@actions) {
		$out .= qq{<option value="$_"}.(($_ eq $act)?" selected":"").qq{>$_</option>}
	}
	$act ||= $actions[0];
	my ($am,$msg) = $modules::DBfunctions::dbh->selectrow_array("SELECT actionmsg_id,message_fld
																		FROM actionmsg_tbl
																		WHERE action_fld='$act'");
	$out .= qq{</tr><tr><td class="tl">Сообщение</td>
<td class="tal"><textarea rows="8" name="message_fld" cols="60">}.escapeHTML($msg).qq{</textarea></td></tr>
<tr><td class="tar" colspan="2"><input type="Image" src="/img/but/apply1.gif" title="Применить" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"></td>
<input type="hidden" name="act" value="add_action_message">
<input type="hidden" name="actionmsg_id" value="$am">
<input type="hidden" name="module_id" value="$modules::Security::FORM{module_id}">
</tr></table>};
	return $out
}

sub form_by_mod_downlist {
	return unless $::SHOW;
	my $form = $modules::Security::FORM{form_fld};
	my $out = qq{<table class="tab_nobord"><tr><td class="tl">Форма</td><td class="tal"><select name="form_fld"}.(!$form?qq{ onchange="if(this.value!=0)this.form.submit()"><option value="0">-- Выберите --</option>}:' onchange="this.form.submit()">');
	my $mod = $modules::DBfunctions::dbh->selectrow_array("SELECT module_fld
												FROM module_tbl
												WHERE module_id=$modules::Security::FORM{module_id}");
	my $h = $modules::DBfunctions::dbh->selectrow_array("SELECT help_fld
														FROM ".(lc $mod)."_forms_tbl
														WHERE ".(lc $mod)."_forms_fld='$form'");
	my $mm = lc $mod;
	my $sth1 = $modules::DBfunctions::dbh->prepare("SELECT ${mm}_forms_fld,menuname_fld,
												   help_fld
												   FROM ${mm}_forms_tbl
												   ORDER BY order_fld");
	$sth1->execute();
	while (my ($f,$menuname,$help) = $sth1->fetchrow_array) {
		$out .= qq{<option value="$f"}.($form eq $f?' selected':'').(!$menuname?qq{ style="color: Silver"}:'').qq{>$f}.($menuname?" ($menuname)":'').qq{</option>}
	}
	$out .= qq{</td></tr><tr><td class="tl">Справка</td>
<td class="tal"><textarea rows="8" name="help_fld" cols="60"}.(!$form?' disabled':'').qq{>}.(!$form?'Сначала выберите форму':escapeHTML($h)).qq{</textarea></td></tr>
<tr><td class="tar" colspan="2"><input type="Image" src="/img/but/apply1.gif" title="Применить" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)" onclick="this.form.act.value='edit_help'"></td>
<input type="hidden" name="act" value="">
<input type="hidden" name="module_id" value="$modules::Security::FORM{module_id}">
</tr></table>};
	return $out
}

sub actionmsg_list {
	my $logpass = logpass();
	my $sth = $modules::DBfunctions::dbh->prepare("SELECT actionmsg_id,message_fld,action_fld
			 				 FROM actionmsg_tbl
							 ORDER BY actionmsg_id");
	$sth->execute();
	my $out = "";
	my $i = 1;
	while (my @row = $sth->fetchrow_array) {
		$out .= qq{<tr class="}.(($i++ % 2)?"tr_col1":"tr_col2").qq{">
		<form method="POST" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl">
		<td><select name="action_fld">}.action_downlist($row[2]).qq{</select></td>
		<td><textarea name="message_fld" rows="5" cols="30">$row[1]</textarea></td>
		<td><input type="Image" src="/img/but/change1.gif" title="Изменить" class="but" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"></td>
		<input type="hidden" name="act" value="edit_action_message">
		<input type="hidden" name="actionmsg_id" value="$row[0]">
		<input type="hidden" name="returnact" value="add_message">$logpass</form>
		<form method="POST" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl">
		<td><input type="Image" src="/img/but/delete1.gif" title="Удалить" class="but" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"></td>
		<input type="hidden" name="act" value="del_action_message">
		<input type="hidden" name="actionmsg_id" value="$row[0]">
		<input type="hidden" name="returnact" value="add_message">$logpass</form></tr>};
		}
	return $out
} # actionmsg_list

sub check_db {
	my $out = "";
	idfield();
	my $i = 1;
	my @r = $modules::DBfunctions::dbh->prepare("SHOW TABLES")->paramsout;
	foreach (@r) {
		my @tables = @$_;
		next if $tables[0] =~ /^xlog/;
		$out .= qq{<tr><td class="tl">Таблица '<b>$tables[0]</b>'</td>};
		$out .= check_table($tables[0]);
		$out .= qq{</tr>};
		my @r = $modules::DBfunctions::dbh->prepare("SHOW COLUMNS FROM $tables[0]")->paramsout;
		foreach (@r) {
			$out .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{">};
			$out .= check_field(@$_);
			$out .= qq{</tr>};
		}
		$out .= qq{<tr><td colspan="2" class="tl">&nbsp;</td></tr>};
	}
	return $out
} # check_db

sub check_table {
	my $out;
	$out .= qq{<td class="tl">};
	if (!($_[0] =~ /^\w+(_tbl)$/)) {$out .= qq{<font color="#FF0000"> !!! имя таблицы <b>$_[0]</b><br/>некорректно</font>}}
	else {$out .= qq{<font color="#006600"><b>OK</b></font>}}
	$out .= qq{</td>};
	return $out
	} # check_table

sub check_field {
	my $out;
	$out .= qq{<td class="tr">поле <b>$_[0]</b></td><td class="tl">};
	if (!($_[0] =~ /^\w+(_fld|_id)$/)) {$out .= qq{<font color="#FF0000">имя поля <b>$_[0]</b><br/>некорректно</font>}}
	elsif  ( ($_[0] =~ /([a-zA-Z0-9]+_id)$/) and ($_[1] ne $idfields{$1}) and ($_[5] ne "auto_increment") and ($_[0] ne "loguser_id") )
		{$out .= qq{<font color="#FF0000">тип ссылочного поля <b>$_[0]</b><br/>не соответствует оригиналу</font>}}
	else {$out .= qq{<font color="#006600">OK</font>}}
	$out .= qq{</td>};
	return $out
	} # check_field

sub tab_downlist { # список таблиц БД
	my $out;
	my $sth = $modules::DBfunctions::dbh->prepare("SHOW TABLES");
	$sth->execute();
	while (my $t = $sth->fetchrow_array) { $out .= qq{<option value="$t">$t</option>} }
	return $out
} # tablist

sub db_dump {
	my $q = new CGI;
	$|=1;
	my @tabs = grep { s/^tab_// } grep { /^tab_(.+)$/ } $q->param;
	my $str;
	print "<pre>MySQL dump...\n";
	if (get_setting("update","mode")) {
		my ($db,$dbhost,$u,$pass,$loc,$h) = $modules::DBfunctions::dbh->selectrow_array("SELECT dbname_fld,dbhost_fld,
																	   dbuser_fld,dbpass_fld,
																	   local_fld,host_fld
																	   FROM site_tbl
																	   WHERE site_id=$modules::Security::FORM{site}");
		my $host = ($loc)?'':qq{-h $h};
		open(DUMP,"mysqldump --opt -C --compatible=mysql40 $host -u $u --password=$pass $db ".(join " "=>@tabs)." |");
		print "\t".(join "\n\t"=>@tabs)."\n";
		my @d = <DUMP>;
		close(DUMP);
		$str = join ""=>@d;
	} else {
		foreach my $t (@tabs) {
			$t =~ /^(.+?)_tbl$/;
			my $_t = $1;
			my @rr = $modules::Core::soap->getQuery("SHOW CREATE TABLE `$t`")->paramsout;
			$rr[0]->[1] =~ s/[\n\r\t]/ /g;
			$str .= qq{DROP TABLE IF EXISTS `$t`;\n\n};
			$str .= $rr[0]->[1].";\n\n";
			$str .= get_table_dump($_t)."\n\n";
			print "\t$t\n";
		}
	}
	print "OK\n\n";
	print "Создаю архив\n";
	my $now = strftime "%Y%m%e", localtime;
	my $zip = Archive::Zip->new();

	print "Добавляю туда дамп... ";
	my $member1 = $zip->addString("MySQL dump from ".localtime,'mysql.stamp');
	$member1->desiredCompressionMethod(COMPRESSION_STORED);
	$member1->desiredCompressionLevel(COMPRESSION_LEVEL_NONE);

	open(ZIN,">$modules::Settings::c{dir}{htdocs}/mysql.string");
	print ZIN $str;
	close(ZIN);

	my $member2 = $zip->addFile($modules::Settings::c{dir}{htdocs}."/mysql.string","mysql.string");
	$member2->desiredCompressionMethod(COMPRESSION_DEFLATED);
	$member2->desiredCompressionLevel(COMPRESSION_LEVEL_BEST_COMPRESSION); # Tha BEST
	print "OK\n";

	print "Пишу всё это в файл 'mysql_dump_$now.zip'... ";
	open(DUMP, ">$modules::Settings::c{dir}{htdocs}/mysql_dump_$now.zip");
	print DUMP $str;
	close(DUMP);

	die 'Ошибка записи!' unless $zip->writeToFileNamed($modules::Settings::c{dir}{htdocs}."/mysql_dump_$now.zip") == AZ_OK;
	print "OK\n\n</pre>";
	print "Всё OK!";
	print <<EOHT;
	<script language="JavaScript">
	function sub() {
		location.href="/mysql_dump_$now.zip"
	}
	</script>
EOHT
	unlink $modules::Settings::c{dir}{htdocs}."/mysql.string";

	return " ";
}

sub get_field_names {
	my $tbl = shift;
	my @r = $modules::Core::soap->getQuery("SHOW COLUMNS FROM ${tbl}_tbl")->paramsout;
	my @flds = map { $_->[0] } @r;
	return @flds;
}

# Возвращает массив типов полей таблицы
sub get_field_types {
	my $tbl = shift;
	my @r = $modules::Core::soap->getQuery("SHOW COLUMNS FROM ${tbl}_tbl")->paramsout;
	my @types = map { $_->[1] } @r;
	return @types;
}

sub module_conf {
	my $out;
	if ($modules::Security::FORM{show}) {
		my $conf = <<EOC;
[Module]
SystemName = {SYSNAME}
RussianName = {RUSNAME}
Version = {VERSION}
Description = {DESCR}
Uses = {USES}

[Site]
SiteName = {SITE_SYSNAME}
Tables = {TABLES}
Files = {FILES}
EOC
		my $mid = $modules::Security::FORM{module_id};
		my ($module,$name,$descr) = $modules::DBfunctions::dbh->selectrow_array("SELECT module_fld,menuname_fld,
																	descr_fld
																	FROM module_tbl WHERE module_id=$mid");
		my $ver = qq{[нет]};
		my @f = glob $modules::Settings::c{dir}{htdocs}."/_DISTRIB_/".$module."*";
		if (-e $f[0]) {
			my $zip = Archive::Zip->new($f[0]);
			my $stamp = $zip->contents('module.stamp');
			$stamp =~ /\s'\w+\-(.+?)'/;
			$ver = $1 if $1;
		}
		my @used = _get_used_modules($module);
		my @tbl = grep { !/^_/ } _guess_tables($module);
		#modules::Debug::dump(\@tbl,'Guessed',1);
		my $sth = $modules::DBfunctions::dbh->prepare("SELECT table_fld,filepath_fld,update_fld FROM tables_tbl WHERE module_fld='$module'");
		$sth->execute();
		my %upd;
		my @f;
		while (my @row = $sth->fetchrow_array) {
			push @f=>join '|'=>@row if $row[1];
			$upd{$row[0]} = $row[2]
		}
		my $f = join ';'=>@f;
		#modules::Debug::dump(\@tbl,'Guessed',1);
		#modules::Debug::dump(\%upd,'2 Update',1);
		my $u = join ',' => grep { !/Settings|Debug|Core|Comfunctions|Validate|Validfunc|DBfunctions|ModSet|Security/ } @used;
		my $t = join ',' => @tbl;
		$conf =~ s/{SYSNAME}/$module/;
		$conf =~ s/{RUSNAME}/$name/;
		$conf =~ s/{VERSION}/$ver/;
		$conf =~ s/{DESCR}/$descr/;
		$conf =~ s/{SITE_SYSNAME}/$module/;
		$conf =~ s/{USES}/$u/;
		$conf =~ s/{TABLES}/$t/;
		$conf =~ s/{FILES}/$f/;
		open(CONF,'>'.$modules::Settings::c{dir}{cgi}."/modules/".$module."/".$module.".conf");
		print CONF $conf;
		close(CONF);
# 		$out .= modules::Debug::notice($conf);
		#
		# Dummy_db tables (1)
		$sth = $modules::DBfunctions::dbh->prepare("SHOW TABLES FROM `dummy_db`");
		$sth->execute();
		my @table;
		while (my $t = $sth->fetchrow_array) {
			push @table=>$t
		}
		# Every Tables_tbl table (1)
		$sth = $modules::DBfunctions::dbh->prepare("SELECT table_fld FROM tables_tbl");
		$sth->execute();
		my @table1;
		while (my $t = $sth->fetchrow_array) {
			next unless $t;
			next if $t =~ /^site/;
			next if $t =~ /^permission/;
			next if $t =~ /^tables/;
			next if $t =~ /^domain/;
			next if $t =~ /^actionm/;
			next if $t =~ /^user_/;
			next if $t =~ /^(?!fb).+?_forms_/;
			push @table1=>$t
		}
		@table1 = sort { $a cmp $b } @table1;
		# Multisite tables (if "System") (8)
		my @stbl;
		if ($module eq 'System') {
			my $sth = $modules::DBfunctions::dbh->prepare("SHOW TABLES FROM `multisite`");
			$sth->execute();
			while (my $t = $sth->fetchrow_array) {
				push @stbl=>$t
			}
		}
		# Module owned Tables_tbl tables (4)
		my @tb;
		$sth = $modules::DBfunctions::dbh->prepare("SELECT table_fld FROM tables_tbl WHERE module_fld='$module'");
		$sth->execute();
		while (my $t = $sth->fetchrow_array) {
			push @tb=>$t
		}
		#modules::Debug::dump(\@table,'From dummy_db');
		#modules::Debug::dump(\@table1,'From tables_tbl');
		#modules::Debug::dump(\@tb,'From tables_tbl (module)');
		my %m;
		foreach (@table,@table1) { $m{$_}++ }
		foreach (@tbl) { $m{$_} += 2 }
		foreach (@tb) { $m{$_} += 4 }
		foreach (@stbl) { $m{$_} += 8 }
		#modules::Debug::dump(\%m);
		my $i = 0;
		# my $count = 22;
		my %fp;
		my $fp = $modules::DBfunctions::dbh->selectall_hashref("SELECT table_fld,filepath_fld FROM tables_tbl WHERE table_fld IN ('".(join "','"=>@tb)."')",'table_fld');
		grep { $fp{$_} = $fp->{$_}->{filepath_fld} } keys %$fp;
		$out .= qq{<h3>Привязанные таблицы</h3>
		<form action="$modules::Settings::c{dir}{cgi_ref}/4site.pl" method="POST" name="tbl">}.
		logpass().qq{
		<input type="hidden" name="returnact" value="module_conf2">
		<input type="hidden" name="s" value="283">
		<input type="hidden" name="module_id" value="$mid">}.start_table().head_table('Таблица','V','Путь','Upd');
		foreach (@tb) {
			$out .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{">
			<td class="tl"><span style="color: #007BFF; font-weight: bold">$_</span></td>
			<td class="tal"><input type="checkbox" name="tbl" checked id="t$_" value="$_" /></td>
			<td class="tal" title="Путь к файлам"><input type="text" name="filepath" size="60" value="$fp{$_}" /></td>
			<td class="tal" title="Обновлять или нет"><input type="checkbox" name="update" value="$_"}.($upd{$_}?' checked':'').qq{ /></td>
			</tr>}
		}
		$out .= end_table();
		$out .= qq{<h3>Непривязанные таблицы</h3>}.start_table();
		foreach (grep { $m{$_} & 1 } sort { $a cmp $b } keys %m) {
			$out .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{">
			<td class="tl">$m{$_} <label for="t$_">};
			my $qq = $_;
			#if ($m{$_} & 2) {
			#	$qq = "<b>$qq</b>"
			#}
			#if ($m{$_} & 4) {
			#	$qq = qq{<span style="color: #007BFF; font-weight: bold">$qq</span>}
			#}
			#if ($m{$_} & 8) {
			#	$qq = qq{<span style="color: #FF0000;">$qq</span>}
			#}
			$out .= $qq;
			$out .= qq{</label></td>
			<td class="tal"><input type="checkbox" name="tbl"}.(($m{$_} & 4)?" checked":"").qq{ id="t$_" value="$_"></td></tr>};
			# $out .= qq{</table><table class="tab" align="left">} unless $i % $count;
		}
		$out .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{">
		</tr>};
		$out .= end_table().qq{
		<table class="tab" align="auto">
			<tr class="tr_col}.($i++ % 2 +1).qq{">
				<td class="tr">Текущая версия:</td>
				<td class="tl"><b>$ver</b></td>
				<td class="tr">Новая версия</td>
				<td class="tal"><input type="text" name="ver" ></td>
				<td class="tar"><input type="submit" class="but" value="Создать пакет модуля"></td>
			</tr>
		</table>
		</form>}
	}
	return $out
}

sub _get_used_modules {
	my $mod = shift;
	return () unless $mod;
	my @used;
	open(MOD,$modules::Settings::c{dir}{cgi}."/modules/".$mod.".pm");
	while (<MOD>) {
		if (/^use\smodules::(.+?)(?:\s|;)/) {
			push @used, $1
		}
		last if /^sub\s/
	}
	close(MOD);
	return @used
}

sub _guess_tables {
	my $mod = shift;
	return () unless $mod;
	my %t;
	open(MOD,$modules::Settings::c{dir}{cgi}."/modules/".$mod.".pm");
	while (<MOD>) {
		if (/([a-z0-9_]+?_tbl)/) {
			$t{$1}++
		}
	}
	close(MOD);
	#modules::Debug::dump(\%t);
	return keys %t
}

sub module_conf2 {
	use Archive::Zip qw(:ERROR_CODES :CONSTANTS);
	my $out;
	my @upd = get_array($modules::Security::FORM{update});
	#modules::Debug::dump(\@upd);
	my $mid = $modules::Security::FORM{module_id};
	my @mm = $modules::DBfunctions::dbh->selectrow_array("SELECT *
																FROM module_tbl WHERE module_id=$mid");
	my $module = $mm[1];
	# Get site data
	my @site = $modules::DBfunctions::dbh->selectrow_array("SELECT *
															FROM site_tbl
															WHERE site_id=283");
	#
	$out .= modules::Debug::notice("","Dumping site tables");
	my $db;
	$modules::DBfunctions::dbh->do("DELETE FROM tables_tbl WHERE module_fld='$module'");
	my $sql;
	my $MYSQLOPTS = "--opt -C";
	my @tbl = get_array($modules::Security::FORM{tbl});
	my @fp = get_array($modules::Security::FORM{filepath});
	for my $i (0..$#tbl) {
		my $str;
#		if (/_settings_/) {
			my $t = $tbl[$i];
			my $host = ($site[-4])?'':qq{-h $site[2]};
			my $ds = "mysqldump $MYSQLOPTS -u $site[5] --password=$site[6] $host $site[4] $t |";
			open(DUMP,$ds);
			my @d = <DUMP>;
			close(DUMP);
			$str = join ""=>@d;
			$sql .= $str;
			$out .= modules::Debug::dump($str,"",1);
#		} else {
#			my @r = $modules::DBfunctions::dbh->selectrow_array("SHOW CREATE TABLE dummy_db.$_");
#			$str = $r[1];
#			$out .= modules::Debug::notice($str,"$_",1);
#			$sql .= "DROP TABLE IF EXISTS `$_`;\n".$str.";\n\n";
#		}
		my $s = $str;
		$s =~ s/'/\\'/g;
		#modules::Debug::notice($t,'',2);
		#modules::Debug::notice((grep{$_ eq $t}@upd)?1:0,$t,3);
		#modules::Debug::notice("INSERT INTO tables_tbl (module_fld,table_fld,filepath_fld,tables_fld,update_fld) VALUES ('$module','$t','".($fp[$i]||'')."','".$s."','".((grep{$_ eq $t}@upd)?1:0)."')");
		$modules::DBfunctions::dbh->do("INSERT INTO tables_tbl (module_fld,table_fld,filepath_fld,tables_fld,update_fld) VALUES ('$module','$t','".($fp[$i]||'')."','".$s."','".((grep{$_ eq $t}@upd)?1:0)."')")
	}
	open(CONF,'>'.$modules::Settings::c{dir}{cgi}."modules/".$module."/site.sql");
	print CONF $sql;
	close(CONF);
	undef $db;
	$out .= modules::Debug::notice("","Dumping multi-site tables");
	$modules::DBfunctions::dbh->do("DELETE FROM tables_tbl WHERE module_fld='_".$module."_SYSTEM'");
	open(DUMP,"mysqldump $MYSQLOPTS -u $modules::Settings::c{dir}{user} --password=$modules::Settings::c{dir}{user} multisite ".lc($module)."_forms_tbl |");
	my @dm = <DUMP>;
	close(DUMP);
	my $str = join ""=>@dm;
	my $s = $str;
	$s =~ s/'/\\'/g;
	$modules::DBfunctions::dbh->do("INSERT INTO tables_tbl (module_fld,table_fld,tables_fld,update_fld) VALUES ('_".$module."_SYSTEM','".lc($module)."_forms_tbl','".$s."','0')");
	my $sql .= $str;
	$sql .= "\n".qq{DELETE FROM module_tbl WHERE module_fld='$module';
	INSERT module_tbl VALUES ('}.(join "','"=>@mm).qq{');};
	$out .= modules::Debug::dump($str,"",1);
	open(CONF,'>'.$modules::Settings::c{dir}{cgi}."modules/".$module."/multisite.sql");
	print CONF $sql;
	close(CONF);
	# Somewhere here ZIP is to create
	$out .= modules::Debug::notice("Создаю архив");
	my $now = strftime "%Y%m%e", localtime();
	my $zip = Archive::Zip->new();
	my $ver = $modules::Security::FORM{ver}||'1.0';

	$out .= modules::Debug::notice("Ставлю метку... '"."Module '$module-$ver' archive from ".localtime()."'");
	my $member1 = $zip->addString("Module '$module-$ver' archive from ".localtime(),'module.stamp');
	$member1->desiredCompressionMethod(COMPRESSION_STORED);
	$member1->desiredCompressionLevel(COMPRESSION_LEVEL_NONE);

	$out .= modules::Debug::notice("Добавляю туда все файлы...");
	$zip->addTree($modules::Settings::c{dir}{cgi}."modules/".$module, "$module");

	my $member2 = $zip->addFile($modules::Settings::c{dir}{cgi}."modules/".$module.".pm", $module.".pm");
	$member2->desiredCompressionMethod(COMPRESSION_DEFLATED);
	$member2->desiredCompressionLevel(COMPRESSION_LEVEL_BEST_COMPRESSION);

	$out .= modules::Debug::notice("Пишу всё это в файл '$module-$ver.zip'... ");
	unlink foreach (glob $modules::Settings::c{dir}{htdocs}."/_DISTRIB_/$module-*");
	$out .= modules::Debug::dump('Ошибка записи!') unless $zip->writeToFileNamed($modules::Settings::c{dir}{htdocs}."/_DISTRIB_/$module-$ver.zip") == AZ_OK;
	return $out
}

sub module_download {
	my $out;
	$out .= qq{<table class="tab">
	<tr class="th">
		<td class="td_left" minwidth="140">Имя архива</td>
		<td class="td_left" width="50">Версия</td>
		<td class="td_right" width="50">Длина</td>
	</tr>};
	my @files = glob $modules::Settings::c{dir}{htdocs}."/_DISTRIB_/*.zip";
# 	modules::Debug::dump(\@files);
	my $i = 1;
	foreach my $f (@files) {
		my @s = stat $f;
# 		modules::Debug::dump(\@s,$f,1);
		my $ver;
		my $zip = Archive::Zip->new($f);
		my $stamp = $zip->contents('module.stamp');
		$stamp =~ /\s'\w+\-(.+?)'/;
		$ver = $1 if $1;
		$f =~ m!/([^/]+)$!;
		my $sf = $1;
# 		modules::Debug::notice($sf,"",1);
		$out .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{">
			<td class="tl" minwidth="140" nowrap="nowrap"><b><a href="/_DISTRIB_/$sf" target="_blank" title="Загрузить '$sf' ($s[7] Bytes)" alt="Загрузить '$sf' ($s[7] Bytes)">$sf</a></b></td>
			<td class="tr"><b>$ver</b></td>
			<td class="tr">$s[7]</td>
		</tr>
		}
	}
	$out .= qq{</table>};
	return $out
}

sub module_order_drag { # Изменение порядка картинок
    my $out;
	$out .= qq{<form name="fo" method="post" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl">
			   <input type="hidden" name="move" value="">
			   <input type="hidden" name="order_fld" value="">
   <p class="note"><b>Примечание:</b> чтобы поменять местами модули, необходимо навести мышку на&nbsp;блок с&nbsp;названием и&nbsp;перетащить в&nbsp;нужное место. По окончании нажать кнопку &laquo;Изменить&raquo;.</p>
   <table class="tab_gal" border="0" cellpadding="0" cellspacing="0"><tr><td>};
   my $sth = $modules::DBfunctions::dbh->prepare("SELECT * FROM module_tbl ORDER BY order_fld");
   $sth->execute();
   my @r;
   $out .= qq{<ul id="gpix" class="gpic">
   };
   my $i = 1;
   while (my @r = $sth->fetchrow_array) {
	   $out .= qq{<li id="p$i"><table class="tab" width="98%"><tr class="tr_col}.($i++ % 2 +1).qq{" id="pp$r[0]" height="32">};
	   $out .= qq{<td class="tl">}.sprintf(qq{<img src="%s" border="0" align="absmiddle"><b>%s</b> (%s)},($r[5]||'/img/head/common.gif'),@r[1..2]).qq{</td></tr></table></li>
	   };
   }
   $out .= qq{</ul></td></tr>
   <tr><td class="tar"><input type="Image" src="/img/but/change1.gif" title="Изменить" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)" onclick="this.form.order.value=junkdrawer.serializeList(document.getElementById('gpix'));"></td></tr>
   </table>};
    return $out
}

sub module_check {
	require Text::Diff;
	my $out;
	return unless $::SHOW;
	$out .= qq{<table border="0"><tr><td valign="top">};
	my $sth = $modules::DBfunctions::dbh->prepare("SELECT sm.site_id, site_fld
											FROM `site_module_tbl` as sm, site_tbl as s
											WHERE module_id=$modules::Security::FORM{module_id}
											AND sm.site_id!=256
											AND s.site_id=sm.site_id
											ORDER BY site_fld");
	$sth->execute();
	my %s;
	while (my @row = $sth->fetchrow_array) {
		my @s = split /\s/=>$row[1];
		my $srv = pop @s;
		($srv) = $srv =~ /\((.+?)\)/;
		#$srv = $1;
		push @{$s{$srv}}=>\@row
	}
	$out .= start_table().head_table(['Сайт',2]);
	my $i = 1;
	foreach my $srv (sort { $a cmp $b } keys %s) {
		$out .= qq{<tr class="tr_col4"><td colspan="2" class="tl"><b>$srv</b></td></tr>};
		foreach my $ss (sort { $a->[1] cmp $b->[1] } @{$s{$srv}}) {
			$i++;
			$out .= qq{<form method="post" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl">
			<tr class="tr_col}.(($modules::Security::FORM{ct} eq $ss->[1])?3:($i % 2 +1)).qq{"><td class="tl">$ss->[1]</td>
			<td class="tal"><input type="Image" }.($modules::Security::FORM{ct} eq $ss->[1]?qq{src="/img/arrow_right2.gif" disabled}:qq{src="/img/arrow_right1.gif" title="Проверить таблицы" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"}).qq{></td></tr><input type="hidden" name="ct" value="$ss->[1]"><input type="hidden" name="show" value="1"><input type="hidden" name="module_id" value="$modules::Security::FORM{module_id}">}.logpass().returnact().qq{</form>}
		}
	}
	$out .= end_table();
	$out .= qq{</td>};
	if ($modules::Security::FORM{ct}) {
		$out .= qq{<td width="10">&nbsp;</td><td valign="top">};
		$out .= qq[<style>
		.file {
			display: block;
			border: 1px dashed Silver;
			background: White;
			padding: 2px;
		}
		.hunk {
			display: block;
			font-family: Monaco, Courier, mono;
			font-size: 13px;
		}
		.hunkheader {
			display: none;
		}
		.ctx {
			display: table-row;
			color: #999999;
		}
		ins {
			color: Green;
			background: Yellow;
			text-decoration: none;
		}
		del {
			color: Red;
		}
		</style>];
		my $site = $modules::DBfunctions::dbh->selectrow_array("SELECT * FROM site_tbl WHERE site_fld='$modules::Security::FORM{ct}'");
		my $s = get_site_data($site);
		$out .= start_table().head_table('Таблицы сайта &laquo;'.$modules::Security::FORM{ct}.'&raquo;','Эталон');
		my $sth = $modules::DBfunctions::dbh->prepare("SELECT table_fld,tables_fld
													FROM `tables_tbl` as t, module_tbl as m
													WHERE module_id=$modules::Security::FORM{module_id}
													AND t.module_fld=m.module_fld");
		$sth->execute();
		while (my ($t,$tt) = $sth->fetchrow_array) {
			my @r = $s->getQuery("SHOW CREATE TABLE $t")->paramsout;
			my @tt = _get_cont($tt);
			my @ss = _get_cont($r[0]->[1]);
			my $ss = join "\n"=>@ss;
			my $tt = join "\n"=>@tt;
			my $diff = Text::Diff::diff(\$ss,\$tt, {STYLE => 'Text::Diff::HTML'});
			$diff =~ s!\n!<br/>!g;
			$out .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{">
			<td colspan="2" class="tl" valign="top"><b>$t</b>:<br/>}.($diff?$diff:qq{<b>Идентичны</b>}).qq{</td>
			</tr>}
		}
		$out .= end_table();
		$out .= qq{</td>}
	}
	$out .= qq{</tr></table>};
	return $out
}

sub module_test {
	#return unless $::SHOW;
	my $out;
	print qq{<div id="_test">};
	print start_table().head_table('Item','test result');
	print qq{<tr style="height: 2px !important;"><td colspan="2" style="background-color: Green"></td></tr>};
	my $sth1 = $modules::DBfunctions::dbh->prepare("SELECT module_id FROM module_tbl");
	$sth1->execute();
	while (my $mod = $sth1->fetchrow_array) {
		my ($modname,$menuname,$p,$fp) = $modules::DBfunctions::dbh->selectrow_array("SELECT module_fld,menuname_fld,pic_fld,headpic_fld FROM module_tbl WHERE module_id=$mod");
		my $mn = lc $modname;
		print qq{<tr><td colspan="2"><h2>Модуль &laquo;$menuname ($modname)&raquo;</h2></td></tr>};
		my $i = 1;
		print qq{<tr class="tr_col4"><td colspan="2" class="tl"><b>Files</b></td></tr>};
		# Module itself
		print qq{<tr class="tr_col}.($i++ % 2 +1).qq{"><td class="tl">modules/$modname.pm</td><td class="tr" nowrap="nowrap">}.(-e $modules::Settings::c{dir}{cgi}."modules/$modname.pm"?_OK():_notOK()).qq{</td></tr>};
		# Configs
		print qq{<tr class="tr_col}.($i++ % 2 +1).qq{"><td class="tl">modules/$modname/$modname.conf</td><td class="tr" nowrap="nowrap">}.(-e $modules::Settings::c{dir}{cgi}."modules/$modname/$modname.conf"?_OK():_notOK()).qq{</td></tr>};
		# Table {module}_forms_tbl
		my $tbl = $modules::DBfunctions::dbh->selectrow_array("SHOW TABLES LIKE '${mn}_forms_tbl'");
		# Pictures
		foreach ($p,$fp) {
			print qq{<tr class="tr_col}.($i++ % 2 +1).qq{"><td class="tl">modules/$modname$_</td><td class="tr" nowrap="nowrap">}.(-e $modules::Settings::c{dir}{cgi}."modules/$modname$_"?_OK():_notOK()).qq{</td></tr>}
		}
		if ($tbl) {
			# Forms
			my $sth = $modules::DBfunctions::dbh->prepare("SELECT ${mn}_forms_fld, menuname_fld FROM $tbl");
			$sth->execute();
			while (my ($fn,$fmn) = $sth->fetchrow_array) {
				print qq{<tr class="tr_col}.($i++ % 2 +1).qq{"><td class="tl">modules/$modname/$fn.htm ($fmn)</td><td class="tr" nowrap="nowrap">}.(-e $modules::Settings::c{dir}{cgi}."modules/$modname/$fn.htm"?_OK():_notOK()).qq{</td></tr>}
			}
		}
		print qq{<tr class="tr_col4"><td colspan="2" class="tl"><b>Tables</b></td></tr>};
		print qq{<tr class="tr_col}.($i++ % 2 +1).qq{"><td class="tl">${mn}_forms_tbl</td><td class="tr" nowrap="nowrap">}.($tbl?_OK():_notOK()).qq{</td></tr>};
		#print qq{<tr style="height: 2px !important;"><td colspan="2" style="background-color: Green"></td></tr>};

		# Site bindings
		print qq{<tr class="tr_col4"><td colspan="2" class="tl"><b>Site bindings</b></td></tr>};
		my $sth = $modules::DBfunctions::dbh->prepare("SELECT sm.site_id,site_fld,
													  homedir_fld,cgidir_fld
													FROM site_module_tbl as sm, site_tbl as s
													WHERE s.site_id=sm.site_id
													AND module_id=$mod
													ORDER BY site_fld");
		$sth->execute();
		if ($sth->rows) {
			while (my @s = $sth->fetchrow_array) {
				my $st = get_site_data($s[0]);
				my ($error,$OK);
				if ($st) {
					my $res = $st->getFileEx($s[2].$s[3].'/sitemodules/'.$modname.'.pm');
					$error = $res->faultstring
				} else {
					$error = join '<br/>'=>get_array($modules::Security::ERROR{soap})
				}
				$OK = ($error)?0:1;
				print qq{<tr class="tr_col}.($i++ % 2 +1).qq{"><td class="tl">$s[1]<br/>$s[2]$s[3]/sitemodules/$modname.pm</td><td class="tr" nowrap="nowrap">}.($OK?_OK():_notOK($error)).qq{</td></tr>}
			}
		} else {
			print qq{<tr class="tr_col}.($i++ % 2 +1).qq{"><td colspan="2" class="tl">None</td></tr>};
		}
		print qq{<tr style="height: 2px !important;"><td colspan="2" style="background-color: Green"></td></tr>};

		print qq{};
	}
	print end_table();
	print qq{</div>};
	return $out
}

sub _OK {
	return qq{<span class="OK">OK</span>}
}

sub _notOK {
	my $str = shift;
	return qq{<span class="notOK" title="$str">Not OK</span>}
}

sub _get_cont {
	my $t = shift;
	my @r = grep { $_ =~ /^\s\s/ } split /\r?\n/=>$t;
	return @r
}

sub forms_overall_list {
	my $out;
	return unless $::SHOW;
	$out .= alert_msg(qq{Внимание! Права будут изменены только для тех сайтов, на которых пользователь имеет доступ хотя бы к одной форме.}).'<br/>';
	my $sth = $modules::DBfunctions::dbh->prepare("SELECT permission_id, site_id,
												  form_id, permission_fld
												  FROM permission_tbl
												  WHERE user_id=$modules::Security::FORM{user_id}
												  AND module_id=$modules::Security::FORM{module_id}
												  AND site_id!=256
												  ORDER BY site_id, form_id");
	$sth->execute();
	my ($sites,$forms,%f,%s,%overall);
	my %perm;
	while (my @row = $sth->fetchrow_array) {
		$s{$row[1]}++;
		$f{qq{$row[2]|$row[3]}}++;
		$overall{$row[1]}->{$row[2]} = $row[3]
	}
	my $sites = scalar keys %overall;
	#modules::Debug::dump(\%f);
	my %m;
	foreach (grep { s/\|.+$// } keys %f) { $m{$_}++ }
	my @f = sort { $a <=> $b } keys %m;
	foreach my $p (@f) {
		my @p = grep { $_ =~ /^$p\|/ } keys %f;
		my $k = $p[0];
		if (scalar @p ==1) {
			if ($f{$p[0]}==$sites) {
				$k =~ s/^$p\|//;
				$perm{$p} = $k
			} else {
				$perm{$p} = 'DONT_CHANGE'
			}
		} else {
			$perm{$p} = 'DONT_CHANGE'
		}
		#modules::Debug::dump(\@p,$p,1);
	}
	#modules::Debug::dump(\%perm);
	$out .= start_table().head_table('Форма','*',' ','R','X');
	my $i = 1;
	my $m = lc $modules::DBfunctions::dbh->selectrow_array("SELECT module_fld FROM module_tbl WHERE module_id=$modules::Security::FORM{module_id}");
	$sth = $modules::DBfunctions::dbh->prepare("SELECT * FROM ${m}_forms_tbl ORDER BY order_fld");
	$sth->execute();
	while (my @row = $sth->fetchrow_array) {
		$out .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{">
		<td class="tr"><b>$row[2]</b> ($row[1])</td>
		<td class="tal" style="background: Yellow"><input type="checkbox" name="dc$row[0]" value="$row[0]"}.($perm{$row[0]} eq 'DONT_CHANGE'?' checked':'').qq{ title="Не менять права, оставить как есть" onchange="check_perms($row[0])"></td>
		<td class="tal"><input type="radio" name="p$row[0]" value="_"}.(!exists $perm{$row[0]}?' checked':'').qq{></td>
		<td class="tal"><input type="radio" name="p$row[0]" value="READ_ONLY"}.($perm{$row[0]} eq 'READ_ONLY'?' checked':'').qq{></td>
		<td class="tal"><input type="radio" name="p$row[0]" value="EXEC"}.($perm{$row[0]} eq 'EXEC'?' checked':'').qq{></td>
		</tr>}
	}
	$out .= qq{<tr class="tr_col3"><td colspan="5" class="tar"><input type="Image" src="/img/but/apply1.gif" title="Применить" class="but" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"></td></tr>};
	$out .= end_table();
	return $out
}
#<div class="file"><span class="fileheader"></span><div class="hunk"><span class="hunkheader">@@ -8,4 +8,5 @@
#</span><span class="ctx">    `clickmax_fld` mediumint(8) unsigned NOT NULL default \'0\',    `clickcount_fld` mediumint(8) unsigned NOT NULL default \'0\',    `timeexpired_fld` date NOT NULL default \'1970-01-01\',</span><ins>+   `text_fld` text,</ins><span class="ctx">    PRIMARY KEY  (`banner_id`)</span><span class="hunkfooter"></span></div><span class="filefooter"></span></div>

sub actionstat_list {
	return unless $::SHOW;
	my $out;
	$out .= qq{<h2>Действия пользователей</h2>};
	my $user = $modules::DBfunctions::dbh->selectrow_array("SELECT login_fld FROM user_tbl WHERE user_id=$modules::Security::FORM{user_id}") || '';
	my $site = $modules::DBfunctions::dbh->selectrow_array("SELECT site_fld FROM site_tbl WHERE site_id=$modules::Security::FORM{site1_id}") || '';
	my $sql = "SELECT login_fld as user, INET_NTOA(hostfrom_fld) as fr,
			site_fld as site,
			DATE_FORMAT(datetime_fld,'%d.%m.%Y %H:%i:%s') as d,
			form_fld as returnact,
			m.module_fld as module,
			act_fld as act,
			formhash_fld as fh,
			actionstat_id as id
			FROM actionstat_tbl as ast, module_tbl as m, user_tbl as u WHERE ";
	my @s;
	push @s=>"user_fld=$modules::Security::FORM{user_id}" if $modules::Security::FORM{user_id};
	push @s=>"site_fld=$modules::Security::FORM{site1_id}" if $modules::Security::FORM{site1_id};
	push @s=>"m.module_id=ast.module_fld";
	push @s=>"u.user_id=ast.user_fld";
	$sql .= join ' AND '=>@s;
	my $st = $modules::Security::FORM{stdate};
	my $end = $modules::Security::FORM{enddate};
	$st = sprintf "%4d-%02d-%02d 00:00:00",reverse split /\./=>$st;
	$end = sprintf "%4d-%02d-%02d 23:59:59",reverse split /\./=>$end;
	$sql .= (scalar @s?" AND ":'')."datetime_fld BETWEEN '$st' AND '$end' ORDER BY datetime_fld";
	#modules::Debug::notice($sql);
	my $sth = $modules::DBfunctions::dbh->prepare($sql);
	$sth->execute();
	if ($sth->rows) {
		$out .= start_table().head_table('Пользователь','Хост','Сайт','Модуль','Форма','[Действие]','Дата и время','FORM');
		my $i = 1;
		while (my $a = $sth->fetchrow_hashref) {
			$a->{site} = $a->{site}?$modules::DBfunctions::dbh->selectrow_array("SELECT site_fld FROM site_tbl WHERE site_id=$a->{site}"):'';
			$a->{returnact} = $modules::DBfunctions::dbh->selectrow_array("SELECT menuname_fld FROM ".lc($a->{module})."_forms_tbl WHERE ".lc($a->{module})."_forms_id=$a->{returnact}");
			$out .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{">
				<td class="tl">$a->{user}</td>
				<td class="tl">$a->{fr}</td>
				<td class="tl">$a->{site}</td>
				<td class="tl">$a->{module}</td>
				<td class="tl">$a->{returnact}</td>
				<td class="tl">$a->{act}</td>
				<td class="tr">$a->{d}</td>
				<td class="tl">}.($a->{fh}&&$a->{act}?qq{<a href="#" onclick="showForm('_form',$a->{id});return false">FORM</a>}:' ').qq{</td>
			</tr>}
		}
		$out .= end_table()
	} else {
		$out .= info_msg('Нет ни одного действия с данными параметрами')
	}
	return $out
}

sub clone_progress {
	return unless $::SHOW;
	my $out;
	my $site_to = $modules::Security::FORM{clone_id};
	my $site_from = $modules::Security::FORM{site_id};
	#modules::Debug::notice($site_from,'Site from');
	my $from = $modules::DBfunctions::dbh->selectrow_hashref("SELECT * FROM site_tbl WHERE site_id=$site_from");
	my $to = $modules::DBfunctions::dbh->selectrow_hashref("SELECT * FROM site_tbl WHERE site_id=$site_to");
	my $from_htdocs = qq{$from->{homedir_fld}$from->{htdocs_fld}};
	my $from_cgi = qq{$from->{homedir_fld}$from->{cgiref_fld}};
	my $to_htdocs = qq{$to->{homedir_fld}$to->{htdocs_fld}};
	my $to_cgi = qq{$to->{homedir_fld}$to->{cgiref_fld}};
	my $cmd = qq{rm -rfd $to_htdocs/*};
	modules::Debug::notice('Удаление старых файлов...');
	qx{$cmd};
	$cmd = qq{rm -f $to_cgi/* $to_cgi/pagetemplate/* $to_cgi/sitemodules/*};
	qx{$cmd};
	$cmd = qq{cp -rfp $from_htdocs/* $to_htdocs};
	modules::Debug::notice('Копирование новых файлов...');
	qx{$cmd};
	$cmd = qq{cp -p $from_cgi/* $to_cgi};
	qx{$cmd};
	$cmd = qq{cp -p $from_cgi/sitemodules/* $to_cgi/sitemodules};
	qx{$cmd};
	$cmd = qq{cp -p $from_cgi/pagetemplate/* $to_cgi/pagetemplate};
	qx{$cmd};
	$cmd = qq{cp -fp $to->{homedir_fld}/Settings.pm $to_cgi/sitemodules};
	qx{$cmd};
	#return;
	my $soap = get_site_data($site_from);
	my @tabs = $soap->getQuery("SHOW TABLES")->paramsout;
	@tabs = map { $_->[0] } @tabs;
	my $updstr = "mysqldump --opt -C -u $from->{dbuser_fld} $from->{dbname_fld} ".(join ' '=>@tabs)." > $modules::Security::c{dir}{cgi}/_session/_sql";
	#modules::Debug::notice($updstr,'Dump');
	modules::Debug::notice('Дамп БД клонируемого сайта...');
	qx{$updstr};
	my $str = "mysql -u $to->{dbuser_fld} ".($to->{dbpass_fld}?qq{--password=$to->{dbpass_fld} }:'')."-e 'DROP DATABASE $to->{dbname_fld}; CREATE DATABASE $to->{dbname_fld}'";
	qx{$str};
	$str = "mysql -u $to->{dbuser_fld} ".($to->{dbpass_fld}?qq{--password=$to->{dbpass_fld} }:'')."-D $to->{dbname_fld} < $modules::Security::c{dir}{cgi}/_session/_sql";
	#modules::Debug::notice($str,'Restore');
	modules::Debug::notice('Заливка дампа на новый сайт...');
	qx{$str};
	#unlink "/home/httpd/multisite/pcgi/_session/_sql";
	$str = qq{DELETE FROM site_module_tbl WHERE site_id=$site_to};
	modules::Debug::notice('Прописка модулей и прав...');
	$modules::DBfunctions::dbh->do($str);
	$str = qq{SELECT module_id FROM site_module_tbl WHERE site_id=$site_from};
	my $sth = $modules::DBfunctions::dbh->prepare($str);
	$sth->execute();
	while (my $m = $sth->fetchrow_array) {
		my $s = qq{INSERT INTO site_module_tbl (site_id,module_id) VALUES ($site_to,$m)};
		$modules::DBfunctions::dbh->do($s)
	}
	$str = qq{DELETE FROM permission_tbl WHERE site_id=$site_to}; # AND user_id=$modules::Security::FORM{user}};
	$modules::DBfunctions::dbh->do($str);
	$str = qq{SELECT user_id,module_id,form_id,permission_fld FROM permission_tbl WHERE site_id=$site_from};
	$sth = $modules::DBfunctions::dbh->prepare($str);
	$sth->execute();
	while (my @p = $sth->fetchrow_array) {
		my $s = qq{INSERT INTO permission_tbl (site_id,user_id,module_id,form_id,permission_fld) VALUES ($site_to,'}.(join "','"=>@p).qq{')};
		#modules::Debug::notice($s);
		$modules::DBfunctions::dbh->do($s)
	}
	modules::Debug::notice('','Готово!');
	return $out
}

################################################################################
################################### Actions ####################################
################################################################################

sub order_modules {
	my @order = grep { s/^p// } split /\|/=>$modules::Security::FORM{order};
	my %o;
	@o{@order} = (1..scalar @order);
	unshift @order=>0;
	$o{'0'} = '_';
	# %o = reverse %o;
	my $sth = $modules::DBfunctions::dbh->prepare("SELECT module_id,order_fld
							FROM module_tbl
							ORDER BY order_fld");
	$sth->execute();
	my $i = 0;
	while (my @r = $sth->fetchrow_array) {
		$modules::DBfunctions::dbh->do("UPDATE module_tbl
									  SET order_fld=".$o{$i+1}."
									  WHERE module_id=".$r[0]);
		$i++;
	}
}

sub add_sysuser {
	my $id = $modules::Security::session->param('user');
	my $uid = $modules::DBfunctions::dbh->selectrow_array("SELECT user_id FROM user_tbl WHERE login_fld='$modules::Security::FORM{login_fld}'");
	unless ($uid) {
		Madd_record("user_tbl");
	} # такого пользователя нет — добавить
	else {
			push @{$modules::Security::ERROR{act}}, qq{Введенный логин уже существует!<br/>Попытайтесь ещё раз.};
			return "err"
		}
	} # add_user

sub edit_sysuser {
	unless ($modules::Security::FORM{self}) {
		if ($modules::Security::FORM{extperm_fld}) {
			my $sth = $modules::DBfunctions::dbh->prepare("SELECT system_forms_id FROM system_forms_tbl");
			$sth->execute();
			my @ext;
			while (my @row = $sth->fetchrow_array) {
				$modules::DBfunctions::dbh->do("INSERT INTO permission_tbl SET user_id=$modules::Security::FORM{user_id}, site_id=256, module_id=19, form_id=$row[0], permission_fld='EXEC'")
			}
		} else  {
			$modules::DBfunctions::dbh->do("DELETE FROM permission_tbl WHERE user_id=$modules::Security::FORM{user_id} AND site_id=256")
		}
		Medit_record("user_tbl");
	} else {
 		$modules::DBfunctions::dbh->do("UPDATE user_tbl SET login_fld='$modules::Security::FORM{login_fld}', pass_fld='$modules::Security::FORM{pass_fld}' WHERE user_id=$modules::Security::FORM{user_id}");
 		print "<script>location.href='/'</script>";
	}
# 	Medit_record("user_tbl");
} # edit_user

sub del_sysuser {
	Mdel_record("user_tbl");
	$modules::DBfunctions::dbh->do("DELETE FROM permission_tbl WHERE user_id=$modules::Security::FORM{user_id}");
} # del_user

sub add_action_message { Madd_record("actionmsg_tbl") }

sub edit_action_message { Medit_record("actionmsg_tbl") }

sub del_action_message {
 	$modules::Validate::result_msg = modules::DBfunctions::get_erased_msg_text("actionmsg_tbl",$modules::Security::FORM{actionmsg_id});
	Mdel_record("actionmsg_tbl")
} # del_action_message

sub edit_help {
	my $mod = lc $modules::DBfunctions::dbh->selectrow_array("SELECT module_fld
												FROM module_tbl
												WHERE module_id=$modules::Security::FORM{module_id}");
	$modules::DBfunctions::dbh->do("UPDATE ${mod}_forms_tbl
								   SET help_fld='$modules::Security::FORM{help_fld}'
								   WHERE ${mod}_forms_fld='$modules::Security::FORM{form_fld}'")
}

sub edit_perms {
	$modules::DBfunctions::dbh->do("DELETE FROM permission_tbl
								   WHERE site_id=$modules::Security::FORM{site_id}
								   AND user_id=$modules::Security::FORM{user_id}");
	my @perm = grep { /^c[A-Z]/ } sort { $a cmp $b } keys %modules::Security::FORM;
	#modules::Debug::dump(\@perm); return;
	my %ms;
	foreach (@perm) {
		/^c([A-Za-z0-9]+[A-Za-z])\d+$/ && $ms{$1}++
	}
 	#modules::Debug::dump(\%ms);
	my @modlist = sort { $a cmp $b } keys %ms;
	#if (scalar grep { 'System' } @modlist) {
	#	$modules::DBfunctions::dbh->do("DELETE FROM permission_tbl
	#								   WHERE site_id=256
	#								   AND user_id=$modules::Security::FORM{user_id}".($modules::Security::FORM{user_id}==$modules::Security::FORM{user}?" AND (form_id<>18 AND form_id<>37)":''));
	#}
	my $sql = "INSERT INTO permission_tbl (user_id,site_id,module_id,form_id,permission_fld) VALUES ";
	my @s;
  	#modules::Debug::dump(\@modlist);
	foreach my $m (@modlist) {
  		#modules::Debug::dump($m,'m',1);
		next unless $m;
		#next if $m eq 'System';
		my $rx = qr/^c$m\d+/;
		#modules::Debug::dump($rx);
		my @p = grep { /$rx/ } @perm;
		my $mid = $modules::DBfunctions::dbh->selectrow_array("SELECT module_id FROM module_tbl WHERE module_fld='$m'");
		my $site = ($mid==19?256:$modules::Security::FORM{site_id});
		foreach my $p (@p) {
			$p =~ /(\d+)$/;
			if ($modules::Security::FORM{$p} ne "_") {
				push @s => qq{($modules::Security::FORM{user_id},$site,$mid,$1,'$modules::Security::FORM{$p}')}
			}
		}
	}
	$sql .= join ", "=>@s;
			#modules::Debug::notice($sql);
	$modules::DBfunctions::dbh->do($sql)
}

sub edit_perms_overall {
	my @perm = grep { /^p\d+/ } keys %modules::Security::FORM;
	my @dc = grep { /^dc\d+/ } keys %modules::Security::FORM;
	my ($m,$u) = @modules::Security::FORM{qw(module_id user_id)};
	my $sth = $modules::DBfunctions::dbh->prepare("SELECT DISTINCT site_id FROM permission_tbl WHERE user_id=$u");
	$sth->execute();
	my @sites;
	while (my $s = $sth->fetchrow_array) {
		push @sites=>$s
	}
	my $sql = qq{DELETE FROM permission_tbl WHERE user_id=$u AND module_id=$m}.(scalar @dc?qq{ AND form_id NOT IN (}.(join ','=>grep { s/^dc// } @dc).qq{)}:'');
	$modules::DBfunctions::dbh->do($sql);
	return unless scalar @perm;
	foreach my $s (@sites) {
		foreach my $p (@perm) {
			my $perm = $modules::Security::FORM{$p};
			next if $perm eq '_';
			$p =~ /^p(\d+)/;
			my $sql = "INSERT INTO permission_tbl (user_id,site_id,module_id,form_id,permission_fld) VALUES ($u,$s,$m,$1,'$perm')";
			#modules::Debug::notice($sql);
			$modules::DBfunctions::dbh->do($sql)
		}
	}
}

sub edit_module {
	my $pic = ($modules::Security::FORM{pic_fld})?$modules::Security::FORM{pic_fld}:'';
	my $hpic = ($modules::Security::FORM{headpic_fld})?$modules::Security::FORM{headpic_fld}:'';
	$modules::DBfunctions::dbh->do("UPDATE module_tbl SET pic_fld='$pic' WHERE module_id=$modules::Security::FORM{module_id}");
	$modules::DBfunctions::dbh->do("UPDATE module_tbl SET headpic_fld='$hpic' WHERE module_id=$modules::Security::FORM{module_id}");
}

sub edit_module_forms {
	my $module = $modules::DBfunctions::dbh->selectrow_array("SELECT module_fld FROM module_tbl WHERE module_id=$modules::Security::FORM{module_id}");
	my ($delete) = grep { /^pb(\d+)/ } keys %modules::Security::FORM;
	if ($delete) {
		$delete =~ s/^pb//;
		my $sql = "UNLINK ".$modules::DBfunctions::dbh->selectrow_array("SELECT ".(lc $module)."_forms_fld FROM ".(lc $module)."_forms_tbl WHERE ".(lc $module)."_forms_id=$delete").".htm";
# 		modules::Debug::dump($sql);
	} else {
		my @enabled = sort { $a cmp $b } grep { /^e(\d+)/ } keys %modules::Security::FORM;
		my @plugged = sort { $a cmp $b } grep { /^p(\d+)/ } keys %modules::Security::FORM;
		my @names = sort { $a cmp $b } grep { /^ni(\d+)/ } keys %modules::Security::FORM;
		my @heads = sort { $a cmp $b } grep { /^nh(\d+)/ } keys %modules::Security::FORM;
		my @x = sort { $a cmp $b } grep { /^x(.+)/ } keys %modules::Security::FORM;
		my %m;
		foreach (@enabled,@plugged) { /^([ep])(\d+)/; $m{$2} .= $1 }
		foreach (@names) {
			/^ni(\d+)/;
			my $p = $1;
			my $sql = "UPDATE ".(lc $module)."_forms_tbl SET menuname_fld='$modules::Security::FORM{$_}' WHERE ".lc $module."_forms_id=$p";
			$modules::DBfunctions::dbh->do($sql)
		}
		foreach (@heads) {
			/^nh(\d+)/;
			my $p = $1;
			my $sql = "UPDATE ".(lc $module)."_forms_tbl SET head_fld='$modules::Security::FORM{$_}' WHERE ".lc $module."_forms_id=$p";
			$modules::DBfunctions::dbh->do($sql)
		}

		foreach (@x) {
			/^x(\d+)/;
			my $p = $1;
			my ($x) = grep { /^x(\d+)/; $1==$p } @x;
			if ($m{$p} =~ /p/) {
				my $sql = "UPDATE ".(lc $module)."_forms_tbl SET ";
				if ($m{$p} =~ /e/) {
					$sql .= "menuenable_fld='1'"
				} else {
					$sql .= "menuenable_fld='0'"
				}
				$sql .= " WHERE ".lc($module)."_forms_id=$p";
				$modules::DBfunctions::dbh->do($sql);
			} else {
				if ($x) {
					my $sql = "DELETE FROM ".(lc $module)."_forms_tbl WHERE ".(lc $module)."_forms_id=$p";
					$modules::DBfunctions::dbh->do($sql);
				}
			}
		}
	}

	# Processing new items
	my %name;
	foreach my $k (keys %modules::Security::FORM) {
		$name{$1} = $modules::Security::FORM{$k} if ($k =~ /^nn(.+)/)
	}
# 	modules::Debug::dump(\%name);
	my @newplug = sort { $a cmp $b } grep { /^np(.+)/ } keys %modules::Security::FORM;
	my @newenbl = sort { $a cmp $b } grep { /^ne(.+)/ } keys %modules::Security::FORM;
	@newenbl = grep { $modules::Security::FORM{$_} } @newenbl;
	@newplug = grep { $modules::Security::FORM{$_} } @newplug;
	my $module = $modules::DBfunctions::dbh->selectrow_array("SELECT module_fld FROM module_tbl WHERE module_id=$modules::Security::FORM{module_id}");
	my $exist = $modules::DBfunctions::dbh->selectrow_array("SHOW TABLES LIKE '".lc($module)."_forms_tbl'");
	unless ($exist) {
		$modules::DBfunctions::dbh->do("CREATE TABLE `".(lc $module)."_forms_tbl` (
  `".(lc $module)."_forms_id` mediumint(8) unsigned NOT NULL auto_increment,
  `".(lc $module)."_forms_fld` varchar(64) NOT NULL default '',
  `menuname_fld` varchar(64) default NULL,
  `menuenable_fld` enum('0','1') NOT NULL default '0',
  `order_fld` mediumint unsigned not null default '0',
  `head_fld` text NOT NULL,
  PRIMARY KEY  (`".(lc $module)."_forms_id`)
)");
		# Create table unless it exists
	}
	my $order = $modules::DBfunctions::dbh->selectrow_array("SELECT max(order_fld) FROM `".lc($module)."_forms_tbl`");
	$order++;
	if (scalar @newplug) {
		my $sql = "INSERT INTO `".(lc $module)."_forms_tbl` (`".(lc $module)."_forms_fld`,`menuname_fld`,`order_fld`,`head_fld`) VALUES ";
		my @v;
		foreach (@newplug) {
			s/^np//;
			push @v, qq{('$_','}.$modules::Security::FORM{'nn'.$_}.qq{',$order,'}.$modules::Security::FORM{'nhn'.$_}.qq{')};
			$order++
		}
		$sql .= join ","=>@v;
		$modules::DBfunctions::dbh->do($sql)
	}
	my %m;
	foreach (@newplug,@newenbl) { $m{$_}++ }
	@newenbl = grep { $m{$_}==2 } keys %m;
	if (scalar @newenbl) {
		$modules::DBfunctions::dbh->do("UPDATE TABLE `".(lc $module)."_forms_tbl` SET menuenable_fld='0' WHERE `".(lc $module)."_forms_fld` NOT IN ('".(join "','"=>(grep{s/^ne//}@newenbl))."')");
		$modules::DBfunctions::dbh->do("UPDATE TABLE `".(lc $module)."_forms_tbl` SET menuenable_fld='1' WHERE `".(lc $module)."_forms_fld` IN ('".(join "','"=>@newenbl)."')");
	}
}

sub create_site {
	return error_return(qq{Невозможно создать сайт: Задайте папку!}) unless (my $site = $modules::Security::FORM{folder});
	return error_return(qq{Не могу создать сайт без названия!}) unless (my $name = $modules::Security::FORM{site_fld});
	my @mod = get_array($modules::Security::FORM{module_id});
	my @u = get_array($modules::Security::FORM{user_id});
	modules::Debug::notice('','Создаём новый сайт');
	# Folders creation
	$site =~ s/-//g;
	eval {
		mkdir qq{/home/httpd/$site};
		mkdir qq{/home/httpd/$site/htdocs};
		mkdir qq{/home/httpd/$site/htdocs/img};
		mkdir qq{/home/httpd/$site/htdocs/js};
		mkdir qq{/home/httpd/$site/htdocs/ssi};
		mkdir qq{/home/httpd/$site/pcgi};
		mkdir qq{/home/httpd/$site/pcgi/sitemodules};
		qx{chown -R developer:staff /home/httpd/$site};
		qx{chmod -R 0775 /home/httpd/$site}
	};
	if ($@) {
		return error_return(qq{Не удалось создать одну из папок сайта: $@})
	}
	modules::Debug::notice('...файловая структура СОЗДАНА!');
	# DB operations
	my $db;
	eval {
		$modules::DBfunctions::dbh->do("CREATE DATABASE ${site}_db");
		$db++
	};
	modules::Debug::notice('...БД СОЗДАНА!');
	my %sh = (
		mirror_id => 0,
		local_fld => 1,
		clone_fld => 0,
		authlogin_fld => $site,
		authpass_fld => $site,
		dbhost_fld => 'localhost',
		dbname_fld => "${site}_db",
		dbuser_fld => 'root',
		dbpass_fld => '',
		homedir_fld => qq{/home/httpd/$site},
		htdocs_fld => '/htdocs',
		cgidir_fld => '/pcgi',
		cgiref_fld => '/pcgi',
		soap_fld => '',
		domains => ''
	);
	%modules::Security::FORM = (%modules::Security::FORM,%sh);
	add_site();
	modules::Debug::notice('...прописка в Системе ЕСТЬ!');
	my $sid = $modules::Security::FORM{site_id};
	# From, To
	my $from = 348;
	($modules::Security::FORM{site_id},$modules::Security::FORM{clone_id}) = ($from,$sid);
	modules::Debug::notice('','Теперь клонируем &laquo;'.$modules::DBfunctions::dbh->selectrow_array("SELECT site_fld FROM site_tbl WHERE site_id=$from").'&raquo;');
	$::SHOW = 1;
	clone_progress();
}

sub add_site {
	Madd_record("site_tbl");
	$modules::Security::FORM{site_id} = $modules::DBfunctions::dbh->selectrow_array("SELECT LAST_INSERT_ID()");
	my @doms = split "\n",$modules::Security::FORM{domains};
	foreach (@doms) {
		$modules::Security::FORM{domain_fld} = $_;
		Madd_record("site_domain_tbl")
	}
}

sub edit_site {
	Medit_record("site_tbl");
	$modules::DBfunctions::dbh->do("DELETE FROM site_domain_tbl WHERE site_id=$modules::Security::FORM{site_id}");
	my @doms = split "\n",$modules::Security::FORM{domains};
	foreach (@doms) {
		$modules::Security::FORM{domain_fld} = $_;
		Madd_record("site_domain_tbl")
	}
}

sub del_site {
	$modules::DBfunctions::dbh->do("DELETE FROM site_domain_tbl WHERE site_id=$modules::Security::FORM{site_id}");
	$modules::DBfunctions::dbh->do("DELETE FROM site_module_tbl WHERE site_id=$modules::Security::FORM{site_id}");
	$modules::DBfunctions::dbh->do("DELETE FROM permission_tbl WHERE site_id=$modules::Security::FORM{site_id}");
	Mdel_record("site_tbl")
}

sub edit_modbysite {
	my @m = @{$modules::Security::FORM{m}};
	my @del = modules::Comfunctions::get_array($modules::Security::FORM{del});
	my @t2d;
	if (@del) {
		my $sth = $modules::DBfunctions::dbh->prepare("SELECT table_fld
													  FROM module_tbl as m, tables_tbl as t
													  WHERE module_id IN (".(join ','=>@del).")
													  AND t.module_fld=m.module_fld");
		$sth->execute();
		while (my $t = $sth->fetchrow_array) {
			push @t2d=>$t
		}
	}
	my @cs = grep { s/^cs// } keys %modules::Security::FORM;
	my @c = grep { s/^c(\d+)/$1/ } keys %modules::Security::FORM;
	$modules::DBfunctions::dbh->do("DELETE FROM site_module_tbl WHERE site_id=$modules::Security::FORM{site_id} AND module_id NOT IN (".(join ','=>@c).")");
	$modules::DBfunctions::dbh->do("DELETE FROM permission_tbl WHERE site_id=$modules::Security::FORM{site_id} AND module_id NOT IN (".(join ','=>@c).")");
	foreach my $i (@cs) {
		$modules::DBfunctions::dbh->do("INSERT INTO site_module_tbl (site_id,module_id) VALUES ($modules::Security::FORM{site_id},$i)")
	}
	my ($al,$ap,$db,$host,$local,$cgiref,$dbpass,$sp) = $modules::DBfunctions::dbh->selectrow_array("SELECT authlogin_fld,authpass_fld,dbname_fld,host_fld,local_fld,cgiref_fld,dbpass_fld,soap_fld FROM site_tbl WHERE site_id=$modules::Security::FORM{site_id}");
	my $soap;
	if ($local eq '1') {
		$soap = modules::NoSOAP->new($modules::Security::FORM{site_id})
	} else {
		modules::Debug::notice('http://'.$host.$sp);
		my $s = SOAP::Lite
			->uri('http://'.$host.'/ServerAuth')
			->proxy('http://'.$host.$sp);
		$SOAP::Constants::DO_NOT_USE_XML_PARSER = 1;
		my $authInfo = $s->login($al,$ap);
		$authInfo = SOAP::Header->name(authInfo => $authInfo);
		#modules::Debug::dump($authInfo,"authInfo Fault");
		$soap = modules::AuthInfo->new($s,$authInfo);
	}
	my @r = $soap->getQuery("SHOW TABLES LIKE '%_tbl'")->paramsout;
	@r = map { $_->[0] } @r;
	#modules::Debug::dump(\@r);
	if (@t2d) {
		foreach (@t2d) {
			$soap->doQuery("DROP TABLE $_")
		}
	}
	my $sth = $modules::DBfunctions::dbh->prepare("SELECT module_fld FROM module_tbl WHERE module_id IN (".(join ","=>@cs).")");
	$sth->execute();
	while (my $m = $sth->fetchrow_array) {
		#modules::Debug::notice($m);
		my @t;
		my $sth1 = $modules::DBfunctions::dbh->prepare("SELECT table_fld, tables_fld
													   FROM tables_tbl
													   WHERE module_fld='$m'");
		$sth1->execute();
		my %tc;
		while (my ($t,$td) = $sth1->fetchrow_array) {
			push @t=>$t;
			$tc{$t} = $td
		}
		#modules::Debug::dump(\@t);
		my %m;
		foreach (@r,@t) { $m{$_}++ }
		my @tp = grep { $m{$_}==2 } keys %m;
		#modules::Debug::dump(\@tp,'Tables present');
		%m = ();
		foreach (@t,@tp) { $m{$_}++ }
		my @t2c = grep { $m{$_}==1 } keys %m;
		#modules::Debug::dump(\@t2c,'Tables to create');
		unless ($modules::Security::FORM{forcecreate}) {
			@t = @t2c
		}
		foreach (@t) {
			#modules::Debug::notice('Creating "'.$_.'"...');
			#modules::Debug::dump($tc{$_},$_,1);
			$soap->doDBUpdate([$db,$dbpass,$tc{$_}]);
		}
		#my @mod = glob $modules::Settings::c{dir}{htdocs}."/_DISTRIB_/".$m."*.zip";
		#next unless scalar @mod;
		#my $zip = Archive::Zip->new($mod[0]);
		#my $sql = $zip->contents($m.'/site.sql');
		#$soap->doDBUpdate([$db,$dbpass,$sql])
	}
	undef $soap;
}

sub add_module {
	my $out;
	my $ret;
	$modules::Security::FORM{module_fld} = ucfirst $modules::Security::FORM{module_fld};
	my $mod = $modules::Security::FORM{module_fld};
	chdir $modules::Settings::c{dir}{cgi}.'modules';
	if (! (-e $modules::Settings::c{dir}{cgi}.'modules/'.$mod and -d $modules::Settings::c{dir}{cgi}.'modules/'.$mod and -e $modules::Settings::c{dir}{cgi}.'modules/'.$mod.'.pm')) {
		mkdir $mod;
		mkdir $mod.'/img';
		open(IN,$modules::Settings::c{dir}{cgi}.'modules/_Module_.pm');
		open(OUT,'>'.$modules::Settings::c{dir}{cgi}.'modules/'.$mod.'.pm');
		while (<IN>) {
			print OUT
		}
		close(OUT);
		close(IN);
		$modules::Security::FORM{order_fld} = $modules::DBfunctions::dbh->selectrow_array("SELECT MAX(order_fld) FROM module_tbl")+1;
		Madd_record('module_tbl')
	} else {
		push @{$modules::Security::ERROR{act}}, qq{Данный модуль уже существует!};
		$ret = "err"
	}
	return $ret
}

sub fileselect {
	use SOAP::Lite;
	my $out;
	my $type = $modules::Security::FORM{t} || 'txt';
	my $dir = $modules::Security::FORM{d} || "/";
	my $fld = $modules::Security::FORM{fld};
	my $frm = $modules::Security::FORM{form};
	my @types = map { '*.'.$_ } split /\|/=>$type;
	$out .= qq{<h3><span style="font-weight: normal">Папка:</span> $dir</h3><h4>Фильтр: }.(join ', '=>(@types)).qq{</h4>};

	my ($soap,$s);

	my $host = $modules::Security::FORM{host_fld};
	my ($al,$ap,$local,$soap_fld) = $modules::DBfunctions::dbh->selectrow_array("SELECT authlogin_fld,authpass_fld,
													local_fld,soap_fld
													FROM site_tbl
													WHERE site_id=$modules::Security::FORM{s}");
	if ($local eq '1' or $modules::Security::FORM{s}==256) {
		$soap = modules::NoSOAP->new($modules::Security::FORM{s})
	} else {
		$s = SOAP::Lite
			->uri('http://'.$host.'/ServerAuth')
			->proxy('http://'.$host.$modules::Security::FORM{cgiref_fld}.$soap_fld);
		my $authInfo = $s->login($al,$ap);
		modules::Debug::dump($authInfo->faultstring,"authInfo Fault") if $authInfo->faultstring;
		$authInfo = SOAP::Header->name(authInfo => $authInfo);
		$soap = modules::AuthInfo->new($s,$authInfo);
	}

	my @thisdir = $soap->getFileList([$dir,$type])->paramsout;
	my @_d = grep { $_ } split "/"=>$dir;
	my $updir;
	if (scalar @_d) {
		pop @_d;
		$updir = "/".join "/"=>@_d
	}

	my $up = ($dir ne '/')?qq{<div class="up"><a href="#" onclick="javascript:fs_open1('$updir','$type','$frm','$fld'); return false;"><img src="/img/arrow_up.gif" border="0"></a></div>}:'';
	$dir = '' if $dir eq '/';
	# Making links to DIRs
	my @dirs = map { $_->[1] } grep { $_->[0] eq 'd' } @thisdir;
 	@dirs = map { qq{<a href="#" onclick="javascript:fs_open1('$dir/$_','$type','$frm','$fld'); return false;"><img src="/img/folder.gif" border="0" align="absmiddle" class="img1">$_</a>} } @dirs;
	my @files = grep { $_->[0] ne 'd' } @thisdir;
	my @f;
	my %ft = (
		gif => '/img/gif.gif',
		jpg => '/img/jpg.gif',
	);
	foreach (@files) {
		if ($_->[0] eq 'f') {
			push @f => qq{<span class="grey"><img src="/img/txt.gif" border="0" align="absmiddle" class="img2">$_->[1]</span>}
		} else {
			$_->[1] =~ /\.([^.]+)$/;
			my $pt = (scalar grep { $_ eq $1 } keys %ft)?$ft{$1}:'/img/txt.gif';
			push @f => qq{<a href="javascript:;" onclick="opener.document.forms['$frm'].elements['$fld'].value='$dir/$_->[1]';window.close();"><img src="$pt" border="0" align="absmiddle" class="img2">$_->[1]</a>}
		}
	}
	@files = @f;
	$out .= ($up)?"$up":"";
 	$out .= "<b>".join("</b><br/><b>"=>@dirs)."</b><br/>" if scalar @dirs;	# DIRs
	$out .= join("<br/>"=>@files)."<br/>";	# files

	return $out
}

sub fileselect_ms {
	use SOAP::Lite;
	my $out;
	my $type = $modules::Security::FORM{t} || 'txt';
	my $dir = $modules::Security::FORM{d} || "/";
	my $id = $modules::Security::FORM{fid};
	my $frm = $modules::Security::FORM{form};

	my @types = map { '*.'.$_ } split /\|/=>$type;
	$out .= qq{<h3><span style="font-weight: normal">Папка:</span> $dir</h3><h4>Фильтр: }.(join ', '=>(@types)).qq{</h4>};

	my ($soap,$s);

	my $host = $modules::Security::FORM{host_fld};
	my ($al,$ap,$local,$soap_fld) = $modules::DBfunctions::dbh->selectrow_array("SELECT authlogin_fld,authpass_fld,
													local_fld,soap_fld
													FROM site_tbl
													WHERE site_id=$modules::Security::FORM{s}");
	if ($local eq '1' or $modules::Security::FORM{s}==256) {
		$soap = modules::NoSOAP->new($modules::Security::FORM{s})
	} else {
		$s = SOAP::Lite
			->uri('http://'.$host.'/ServerAuth')
			->proxy('http://'.$host.$modules::Security::FORM{cgiref_fld}.$soap_fld);
		my $authInfo = $s->login($al,$ap);
		modules::Debug::dump($authInfo->faultstring,"authInfo Fault") if $authInfo->faultstring;
		$authInfo = SOAP::Header->name(authInfo => $authInfo);
		$soap = modules::AuthInfo->new($s,$authInfo);
	}

	my @thisdir = $soap->getFileList([$dir,$type])->paramsout;
	my @_d = grep { $_ } split "/"=>$dir;
	my $updir;
	if (scalar @_d) {
		pop @_d;
		$updir = "/".join "/"=>@_d
	}

	my $up = ($dir ne '/')?qq{<div class="up"><a href="#" onclick="javascript:fs_open1_m('$updir','$type','$frm','$id'); return false;"><img src="/img/arrow_up.gif" border="0"></a></div>}:'';
	$dir = '' if $dir eq '/';
	# Making links to DIRs
	my @dirs = map { $_->[1] } grep { $_->[0] eq 'd' } @thisdir;
 	@dirs = map { qq{<a href="#" onclick="javascript:fs_open1_m('$dir/$_','$type','$frm','$id'); return false;"><img src="/img/folder.gif" border="0" align="absmiddle" class="img1">$_</a>} } @dirs;
	my @files = grep { $_->[0] ne 'd' } @thisdir;
	my @f;
	my %ft = (
		gif => '/img/gif.gif',
		jpg => '/img/jpg.gif',
	);
	foreach (@files) {
		if ($_->[0] eq 'f') {
			push @f => qq{<span class="grey"><img src="/img/txt.gif" border="0" align="absmiddle" class="img2">$_->[1]</span>}
		} else {
			$_->[1] =~ /\.([^.]+)$/;
			my $pt = (scalar grep { $_ eq $1 } keys %ft)?$ft{$1}:'/img/txt.gif';
			push @f => qq{<a href="javascript:;" onclick="opener.document.getElementById('$id').value='$dir/$_->[1]';window.close();"><img src="$pt" border="0" align="absmiddle" class="img2">$_->[1]</a>}
		}
	}
	@files = @f;
	$out .= ($up)?"$up":"";
 	$out .= "<b>".join("</b><br/><b>"=>@dirs)."</b><br/>" if scalar @dirs;	# DIRs
	$out .= join("<br/>"=>@files)."<br/>";	# files

	return $out
}

########
########
####
####

sub table_compare {
	my $out;
	if ($modules::Security::FORM{show} and $modules::Security::FORM{table1} and $modules::Security::FORM{table2}) {
		my $soap1 = get_site_data($modules::Security::FORM{site1});
		my $soap2 = get_site_data($modules::Security::FORM{site2});
		my ($c,$d1) = show_columns($soap1,'table1');
		my @col1 = @$c;
		my ($c,$d2) = show_columns($soap2,'table2');
		my @col2 = @$c;
		my %m;
		my %d;
		my @all;
		foreach (@col1) { push @all,$_; ${$d{$_}}[0] = $d1->{$_}; $m{$_}++ }
		foreach my $f (@col2) { push @all,$f unless scalar grep { $f eq $_ } @all; ${$d{$f}}[1] = $d2->{$f}; $m{$f} += 2 }
# 		@all = sort { $a cmp $b } @all;
		$out .= cmpShow(\@all,\%m,\%d)
	}
	return $out
}

sub show_columns {
	my @col;
	my %descr;
	my $soap = shift;
	my $tbl = shift;
	my @r = $soap->getQuery("SHOW COLUMNS FROM $modules::Security::FORM{$tbl}")->paramsout;
	foreach (@r) {
		push @col,$_->[0];
		$descr{$_->[0]} = join "|",@{$_}
	}
	return (\@col,\%descr)
}

sub show_index {
	my @col;
	my %descr;
	my $soap = shift;
	my $tbl = shift;
	my @r = $soap->getQuery("SHOW INDEX FROM $modules::Security::FORM{$tbl}")->paramsout;
	foreach (@r) {
		push @col,$_->[0];
		$descr{$_->[0]} = join "|",@{$_}[0..4,7]
	}
	return (\@col,\%descr)
}

sub table_select {
	my $out;
	if ($modules::Security::FORM{show}) {
		$out .= qq{
	<form method="post" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl" name="ff1">}.logpass.qq{
		<tr class="tr_col2">
			<td class="tal" valign="top"><select name="table1"><option>-- Выберите таблицу --</option>}.table_downlist($modules::Security::FORM{site1},'table1').qq{</select></td>
			<td class="tal"><input type="submit" class="but" value="<->" onclick="return checkTbl()"></td>
			<td class="tal" valign="top"><select name="table2"><option>-- Выберите таблицу --</option>}.table_downlist($modules::Security::FORM{site2},'table2').qq{</select></td>
		</tr>
	<input type="hidden" name="site1" value="$modules::Security::FORM{site1}">
	<input type="hidden" name="site2" value="$modules::Security::FORM{site2}">
	<input type="hidden" name="show" value="1">
	<input type="hidden" name="returnact" value="table_cmp">
	</form>}
	}
	return $out
}

sub db_table_select {
	my $out;
	if ($modules::Security::FORM{show}) {
		unless ($modules::Security::FORM{site1} =~ /\d+/ and $modules::Security::FORM{site2} =~ /\d+/) {
			push @{$modules::Security::ERROR{act}}, qq{<b>Не выбран по крайней мере один сайт</b>. Выберите оба сайта!};
			return
		}
		if ($modules::Security::FORM{site1} eq $modules::Security::FORM{site2}) {
			push @{$modules::Security::ERROR{act}}, qq{<b>Выбран один и тот же сайт</b>. Выберите два <u>разных</u> сайта!};
			return
		}
		my @tab1 = table_list($modules::Security::FORM{site1});
		my @tab2 = table_list($modules::Security::FORM{site2});
		my %m;
		my @all;
		foreach (@tab1) { push @all,$_; $m{$_}++ }
		foreach my $f (@tab2) { push @all,$f unless scalar grep { $f eq $_ } @all; $m{$f} += 2 }
# 		@all = sort { $a cmp $b } @all;
# 		$out .= qq{
# 		<form method="post" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl">}.logpass;
		$out .= cmpShowTbl(\@all,\%m);
# 		$out .= qq{
# 		<input type="hidden" name="site1" value="$modules::Security::FORM{site1}">
# 		<input type="hidden" name="site2" value="$modules::Security::FORM{site2}">
# 		<input type="hidden" name="show" value="1">
# 		<input type="hidden" name="returnact" value="db_cmp">
# 		</form>}
	}
	return $out
}

sub table_list {
	my $out;
	my $site = shift;
	my $soap = get_site_data($site);
	my @t;
	my @r = $soap->getQuery("SHOW TABLES LIKE '%tbl'")->paramsout;
	foreach (@r) {
		push @t,$_->[0]
	}
	return @t
}

sub table_downlist {
	my $out;
	my $site = shift || $modules::Security::FORM{site};
	my $soap = get_site_data($site);
	my $tbl = shift;
	my @r = $soap->getQuery("SHOW TABLES LIKE '%tbl'")->paramsout;
	foreach (@r) {
		$out .= qq{<option value="$_->[0]"}.(($_->[0] eq $tbl or $_->[0] eq $modules::Security::FORM{$tbl})?' selected':'').qq{>$_->[0]</option>}
	}
	return $out
}

sub get_site_data {
	my $site = shift;
	my @site = $modules::DBfunctions::dbh->selectrow_array("SELECT * FROM site_tbl WHERE site_id=$site");
	my $soap;
	if ($site[13] eq '1') {
		$soap = modules::NoSOAP->new($site)
	} else {
		my $s = SOAP::Lite
			->uri('http://'.$site[2].'/ServerAuth')
			->proxy('http://'.$site[2].$site[-1]);
		my $delay = 8;
		my $retries = 10;
		my $attempt = 0;
		#modules::Debug::dump($modules::Core::s);
		my $authInfo = undef;
		while ( (!eval { $authInfo = $s->login(@site[11,12]) }) && (++$attempt <= $retries) ) {
			modules::Debug::notice(sprintf("Attempt %d of %d failed. Retry in %d seconds", $attempt, $retries, $delay));
			sleep($delay)
		}
		#my $authInfo = $s->login(@site[11,12]);
		if (!$authInfo) {
			modules::Debug::dump("Таймаут (".($delay*$retries)." сек.) соединения с удалённым сервером.","Ошибка соединения");
			push @{$modules::Security::ERROR{soap}}=>"Таймаут (".($delay*$retries)." сек.) соединения с удалённым сервером."
		} else {
			if ($authInfo->faultstring) {
				modules::Debug::dump($authInfo->faultstring,"authInfo Fault");
				push @{$modules::Security::ERROR{soap}}=>$authInfo->faultstring
			} else {
				$authInfo = SOAP::Header->name(authInfo => $authInfo);
				$soap = modules::AuthInfo->new($s,$authInfo);
			}
		}
	}
	return $soap
}

sub cmpShow {
	my @a = @{$_[0]}; # Массив порядка вывода
	my %h = %{$_[1]}; # Хэш с результатами сравнения
	my %d = %{$_[2]}; # Хэш с определениями полей
	my $out;
	my $i = 1;
	foreach (@a) {
		$out .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{">};
		my $first;
		if ($h{$_}&1){
			if ($h{$_}&2) {
				if (${$d{$_}}[0] eq ${$d{$_}}[1]) {
					$first .= qq{<b>$_</b>}
				} else {
					${$d{$_}}[0] =~ s/^[^|]*\|//;
					$first = qq{<b style="color: #009900">$_</b><br/>&nbsp;&nbsp;<i style="color: #999999">}.${$d{$_}}[0].qq{</i>}
				}
			} else {
				$first = qq{<span style="color: Red">$_</span>}
			}
		} else {
			$out .= '&nbsp;'
		}
		$out .= qq{<td class="tl" valign="top">}.$first.qq{</td>};
		$out .= qq{<td class="tb"></td>};
		$out .= qq{<td class="tl" valign="top">};
		if ($h{$_}&2){
			if ($h{$_}&1) {
				if (${$d{$_}}[1] eq ${$d{$_}}[0]) {
					$out .= qq{<b>$_</b>}
				} else {
					${$d{$_}}[1] =~ s/^[^|]*\|//;
					$out .= qq{<b style="color: #009900">$_</b><br/>&nbsp;&nbsp;<i style="color: #999999">}.${$d{$_}}[1].qq{</i>}
				}
			} else {
				$out .= qq{<span style="color: Red">$_</span>}
			}
		} else {
			$out .= '&nbsp;'
		}
		$out .= qq{</td>};
		$out .= qq{</tr>}
	}
	return $out
}

sub cmpShowTbl {
	my @a = @{$_[0]}; # Массив порядка вывода
	my %h = %{$_[1]}; # Хэш с результатами сравнения
	my $out;
	my $i = 1;
	foreach (@a) {
		$out .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{">};
		$out .= qq{<td class="tl" valign="top">};
		if ($h{$_}&1){
			if ($h{$_}&2) {
				$out .= qq{<b>$_</b>}
			} else {
				$out .= qq{<span style="color: Red">$_</span>}
			}
		} else {
			$out .= '&nbsp;'
		}
		$out .= qq{</td>};
		$out .= qq{<td class="tal">};
		if ($h{$_}==3) {
			$out .= qq{<form method="post" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl">}.logpass;
			$out .= qq{<input type="submit" class="but" value="<->">};
			$out .= qq{
			<input type="hidden" name="site1" value="$modules::Security::FORM{site1}">
			<input type="hidden" name="site2" value="$modules::Security::FORM{site2}">
			<input type="hidden" name="table1" value="$_">
			<input type="hidden" name="table2" value="$_">
			<input type="hidden" name="show" value="1">
			<input type="hidden" name="returnact" value="table_cmp">
			</form>}
		} else {
			$out .= qq{}
		}
		$out .= qq{</td>};
		$out .= qq{<td class="tl" valign="top">};
		if ($h{$_}&2){
			if ($h{$_}&1) {
				$out .= qq{<b>$_</b>}
			} else {
				$out .= qq{<span style="color: Red">$_</span>}
			}
		} else {
			$out .= '&nbsp;'
		}
		$out .= qq{</td>};
		$out .= qq{</tr>}
	}
	return $out
}

sub mirror_downlist { site_downlist(shift) }

sub site1_downlist { site_downlist1($modules::Security::FORM{site1}) }

sub site2_downlist { site_downlist1($modules::Security::FORM{site2}) }

sub site_downlist1 {
	my $logpass = logpass();
	my $site = shift;
	my $extperm = $modules::DBfunctions::dbh->selectrow_array("SELECT extperm_fld FROM user_tbl WHERE user_id=$modules::Security::FORM{user}");
	my $sth = $modules::DBfunctions::dbh->prepare("SELECT site_id,site_fld
							 FROM site_tbl
							 ".(!$extperm?"WHERE site_fld<>'System'
							 ":'')."ORDER BY site_fld");
	$sth->execute();
	my $out;
	my %site;
	while (my @row = $sth->fetchrow_array) {
		$site{$row[1]} = $row[0]
	}
	my %s;
	foreach (sort { (split ' ',$a)[1] cmp (split ' ',$b)[1] || (split ' ',$a)[0] cmp (split ' ',$b)[0]} keys %site) {
		my ($n,$sect) = split ' ';
		$sect =~ s/\(([^)]+)\)/$1/;
		if ($sect) {
			$s{$sect} .= qq{<option value="$site{$_}"}.(($site{$_}==$site)?" selected":"").qq{>$_</option>};
		} else {
			$out .= qq{<option value="$site{$_}"}.(($site{$_}==$site)?" selected":"").qq{>$_</option>}
		}
	}
	foreach (sort {$a cmp $b} keys %s) {
		$out .= qq{<optgroup label="$_">}.$s{$_}.qq{</optgroup>}
	}
	return $out
}

sub modbysite_downlist {
	my $out;
	if ($modules::Security::FORM{show}) {
		my $sth = $modules::DBfunctions::dbh->prepare("SELECT sm.module_id,m.module_fld FROM site_module_tbl as sm, module_tbl as m WHERE site_id=$modules::Security::FORM{site_id} AND m.module_id=sm.module_id");
		$sth->execute();
		$out .= qq{<tr class="tr_col2">
		<td class="tl">Модуль</td>
		<td class="tal"><select name="module_id" onchange="submit('ff')"><option>-- Выберите --</option>};
		while (my @row = $sth->fetchrow_array) {
			$out .= qq{<option value="$row[0]"}.(($row[0]==$modules::Security::FORM{module_id})?" selected":"").qq{>$row[1]</option>}
		}
		$out .= qq{</select></td></tr>}
	}
	return $out
}

sub table_validate {
	my $out;
	if ($modules::Security::FORM{show}) {
		my $mod = $modules::DBfunctions::dbh->selectrow_array("SELECT module_fld FROM module_tbl WHERE module_id=$modules::Security::FORM{module_id}");
		my $sth = $modules::DBfunctions::dbh->prepare("SELECT table_fld FROM tables_tbl WHERE module_fld='$mod'");
		$sth->execute();
		my @st;
		while (my $t = $sth->fetchrow_array) {
			push @st=>$t
		}
		@st = sort { $a cmp $b } @st;
		my $s1 = get_site_data($modules::Security::FORM{site_id});
		my $s = get_site_data(283);
		$out .= qq{<table class="tab">
		<tr><td class="td_div">&nbsp;</td></tr>
		<tr class="th">
			<td class="td_left">Эталон</td>
			<td>&nbsp;</td>
			<td class="td_right">This site</td></tr>};
		foreach (@st) {
			$modules::Security::FORM{table2} = $modules::Security::FORM{table1} = $_;
			my ($c,$d1) = show_columns($s,'table1');
			my @col1 = @$c;
			my ($c,$d2) = show_columns($s1,'table2');
			my @col2 = @$c;
			my %m;
			my %d;
			my @all;
			foreach (@col1) { push @all,$_; ${$d{$_}}[0] = $d1->{$_}; $m{$_}++ }
			foreach my $f (@col2) { push @all,$f unless scalar grep { $f eq $_ } @all; ${$d{$f}}[1] = $d2->{$f}; $m{$f} += 2 }
			my ($i,$id1) = show_index($s,'table1');
			my @ind1 = @$i;
			my ($i,$id2) = show_index($s1,'table2');
			#modules::Debug::dump([$i,$id2]);
			my @ind2 = @$i;
			my %i;
			my %id;
			my @iall;
			foreach (@ind1) { push @iall,$_; ${$id{$_}}[0] = $id1->{$_}; $i{$_}++ }
			foreach my $f (@ind2) { push @iall,$f unless scalar grep { $f eq $_ } @iall; ${$id{$f}}[1] = $id2->{$f}; $i{$f} += 2 }
			# modules::Debug::dump(\%m);
			my @eq = grep { $m{$_}==3 } keys %m;
			$out .= qq{<tr class="th">};
			if (scalar @eq == scalar keys %m) {
				$out .= qq{<td>$_</td><td colspan="2" style="text-align: right; color: Silver">Таблицы идентичны</td></tr>};
			} else {
				$out .= qq{<td>$_</td><td colspan="2" style="text-align: right; color: Red">Есть различия</td></tr>};
				$out .= cmpShow(\@all,\%m,\%d);
			}
			$out .= qq{<tr class="th">};
			if (scalar grep { $i{$_}==3 } keys %i == scalar keys %i) {
				$out .= qq{<td colspan="3" style="text-align: right;">INDEX: <span style="color: Silver">идентичны</span></td></tr>};
			} else {
				$out .= qq{<td colspan="3" style="text-align: right;">INDEX: <span style="color: Red">Есть различия</span></td></tr>};
				$out .= cmpShow(\@iall,\%i,\%id);
			}
			$out .= qq{<tr><td class="td_div">&nbsp;</td></tr>}
		}
		$out .= qq{</table>}
	}
	return $out
}

1;
__END__

=head1 NAME

B<System.pm> — Модуль системных функций

=head1 SYNOPSIS

Модуль функций управления системой.

=head1 DESCRIPTION

Модуль функций управления системой. Включает в себя управление пользователями, сайтами, упорядочением форм других модулей и т.п.

=head2 modname

Выводит название (русское и английское) выбранного модуля.

=over 4

=item Вызов:

C<< <!--#include virtual="modname"--> >>

=item Пример вызова:

C<< <!--#include virtual="modname"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 user_list

Список пользователей для редактирования.

=over 4

=item Вызов:

C<< <!--#include virtual="user_list"--> >>

=item Пример вызова:

C<< <!--#include virtual="user_list"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

L<downlist|::Comfunctions/"downlist">.

=back

=head2 site_list

Список сайтов для редактирования.

=over 4

=item Вызов:

C<< <!--#include virtual="site_list"--> >>

=item Пример вызова:

C<< <!--#include virtual="site_list"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 site_edit

Данные выбранного сайта для редактирования.

=over 4

=item Вызов:

C<< <!--#include virtual="site_edit"--> >>

=item Пример вызова:

C<< <!--#include virtual="site_edit"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 mod_list

Список модулей Системы для редактирования их содержимого (формы).

=over 4

=item Вызов:

C<< <!--#include virtual="mod_list"--> >>

=item Пример вызова:

C<< <!--#include virtual="mod_list"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 module_downlist

Выпадающий список модулей Системы.

=over 4

=item Вызов:

C<< <!--#include virtual="module_downlist"--> >>

=item Пример вызова:

C<< <!--#include virtual="module_downlist"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 form_order

Список форм выбранного модуля для изменения порядка следования в меню.

=over 4

=item Вызов:

C<< <!--#include virtual="form_order"--> >>

=item Пример вызова:

C<< <!--#include virtual="form_order"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 order_form

Упорядочивает формы выбранного модуля.

=over 4

=item Вызов:

C<< <!--#include virtual="order_form"--> >>

=item Пример вызова:

C<< <!--#include virtual="order_form"--> >>

=item Примечания:

Напрямую не вызывается. Передаётся только через поле B<act> вызывающей HTML-формы.

=item Зависимости:

Нет.

=back

=head2 forms_list

Список форм выбранного модуля для подключения/отключения оных.

=over 4

=item Вызов:

C<< <!--#include virtual="forms_list"--> >>

=item Пример вызова:

C<< <!--#include virtual="forms_list"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 site_downlist

Выпададющий список сайтов, доступных текущему пользователю.

=over 4

=item Вызов:

C<< <!--#include virtual="site_downlist"--> >>

=item Пример вызова:

C<< <!--#include virtual="site_downlist"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 mod_by_site_list

Список модулей, подключенных к выбранному сайту.

=over 4

=item Вызов:

C<< <!--#include virtual="mod_by_site_list"--> >>

=item Пример вызова:

C<< <!--#include virtual="mod_by_site_list"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 form_by_module_list

Список форм по модулям на выбранном сайте, для назначения прав доступа (permissions).

=over 4

=item Вызов:

C<< <!--#include virtual="form_by_module_list"--> >>

=item Пример вызова:

C<< <!--#include virtual="form_by_module_list"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 idfield

Составление списка ключевых полей.

=over 4

=item Вызов:

C<&idfield();>

=item Примеры.

 idfield();

=item Примечания:

Не экспортируется. Внутренняя функция.

=item Зависимости:

Нет.

=back

=head2 user_downlist

Выпадающий список пользователей (с выделением переданного, если есть).

=over 4

=item Вызов:

C<< <!--#include virtual="user_downlist"--> >>

=item Пример вызова:

C<< <!--#include virtual="user_downlist"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 action_downlist

Выпадающий список действий Системы.

=over 4

=item Вызов:

C<< <!--#include virtual="action_downlist"--> >>

=item Пример вызова:

C<< <!--#include virtual="action_downlist"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 actionmsg_list

Список сообщений о результатах действий для редактирования.

=over 4

=item Вызов:

C<< <!--#include virtual="actionmsg_list"--> >>

=item Пример вызова:

C<< <!--#include virtual="actionmsg_list"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

L<logpass|::Comfunctions/"logpass">, L<action_downlist|::Comfunctions/"action_downlist">.

=back

=head2 check_db

Проверяет БД потаблично на соответствие соглашениям и выводит результат в таблицу.

=over 4

=item Вызов:

C<< <!--#include virtual="check_db"--> >>

=item Пример вызова:

C<< <!--#include virtual="check_db"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

L<idfield|"idfield">, L<check_table|"check_table">, L<check_field|"check_field">.

=back

=head2 check_table

Проверка имен таблиц на соответствие соглашениям системы.

=over 4

=item Вызов:

C<&check_table("имя_таблицы");>

=item Пример вызова:

 &check_table("page_tbl");

=item Примечания:

Не экспортируется. Внутренняя функция.

=item Зависимости:

Нет.

=back

=head2 check_field

Проверка имен полей на соответствие соглашениям системы.

=over 4

=item Вызов:

C<&check_field("имя_поля");>

=item Пример вызова:

 &check_field("url_fld");

=item Примечания:

Не экспортируется. Внутренняя функция.

=item Зависимости:

Нет.

=back

=head2 tab_downlist

Выпадающий список таблиц БД Системы.

=over 4

=item Вызов:

C<< <!--#include virtual="tab_downlist"--> >>

=item Пример вызова:

C<< <!--#include virtual="tab_downlist"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 db_dump

Производит дамп выбранных таблиц БД в zip-файл.

=over 4

=item Вызов:

C<< <!--#include virtual="db_dump"--> >>

=item Пример вызова:

C<< <!--#include virtual="db_dump"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

L<tab_list|"tab_list">, L<get_table_dump|"get_table_dump">.

=back

=head2 get_field_names

Возвращает массив имён полей таблицы.

=over 4

=item Вызов:

C<get_field_names("имя_таблицы без '_tbl'")>

=item Пример вызова:

 get_field_names($tbl);

=item Примечания:

Не экспортируется. Внутренняя функция.

=item Зависимости:

Нет.

=back

=head2 get_field_types

Возвращает массив типов полей таблицы.

=over 4

=item Вызов:

C<get_field_types("имя_таблицы без '_tbl'")>

=item Пример вызова:

 get_field_types($tbl);

=item Примечания:

Не экспортируется. Внутренняя функция.

=item Зависимости:

Нет.

=back

=head2 module_conf

Выводит список таблиц с отмеченными таблицами данного модуля. Предлагает создать новую версию модуля.

=over 4

=item Вызов:

C<< <!--#include virtual="module_conf"--> >>

=item Пример вызова:

 C<< <!--#include virtual="module_conf"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

L<_get_used_modules>, L<_guess_tables>.

=back

=head2 module_conf2

Составляет конфигурацию модуля и пакует в zip.

=over 4

=item Вызов:

C<< <!--#include virtual="module_conf2"--> >>

=item Пример вызова:

 C<< <!--#include virtual="module_conf2"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

L<Archive::Zip>.

=back

=head2 _guess_tables

Пытается из текста модуля угадать, какие таблицы он использует, и возвращает список.

=over 4

=item Вызов:

C<< _guess_tables($module) >>

=item Пример вызова:

 C<< _guess_tables($module) >>

=item Примечания:

Не экспортируется. Внутренняя функция.

=item Зависимости:

Нет.

=back

=head2 _get_used_modules

Опеределяет из текста модуля, какие другие модули он use'ает.

=over 4

=item Вызов:

C<< _get_used_modules($module) >>

=item Пример вызова:

 C<< _get_used_modules($module) >>

=item Примечания:

Не экспортируется. Внутренняя функция.

=item Зависимости:

Нет.

=back

=head2 module_download

Таблица модулей (архивы) для загрузки.

=over 4

=item Вызов:

C<< <!--#include virtual="module_download"--> >>

=item Пример вызова:

 C<< <!--#include virtual="module_download"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 (add|edit|del)_sysuser

Добавление/изменение/удаление пользователя в/из Систему.

=over 2

=item Примечания:

Напрямую не вызывается. Передаётся только через поле B<act> вызывающей HTML-формы.

=item Зависимости:

L<add_record|::Comfunctions/"add_record">, L<edit_record|::Comfunctions/"edit_record">, L<del_record|::Comfunctions/"del_record"> соответственно.

=back

=head2 (add|del|edit)_action_message

Добавление/удаление/изменение сообщения системы на действие пользователя.

=over 2

=item Примечания:

Напрямую не вызывается. Передаётся только через поле B<act> вызывающей HTML-формы.

=item Зависимости:

L<add_record|::Comfunctions/"add_record">, L<edit_record|::Comfunctions/"edit_record">, L<del_record|::Comfunctions/"del_record"> соответственно.

=back

=head2 edit_perms

Редактирование прав доступа выбранного пользователя к выбранному сайту.

=over 2

=item Примечания:

Напрямую не вызывается. Передаётся только через поле B<act> вызывающей HTML-формы.

=item Зависимости:

Нет.

=back

=head2 edit_module

Подключение/отключение удаление форм к выбранному модулю.

=over 2

=item Примечания:

Напрямую не вызывается. Передаётся только через поле B<act> вызывающей HTML-формы.

=item Зависимости:

Нет.

=back

=head2 (add|del|edit)_site

Добавление/удаление/изменение сайта.

=over 2

=item Примечания:

Напрямую не вызывается. Передаётся только через поле B<act> вызывающей HTML-формы.

=item Зависимости:

L<Madd_record|::Comfunctions/"Madd_record">, L<Medit_record|::Comfunctions/"Medit_record">, L<Mdel_record|::Comfunctions/"Mdel_record"> соответственно.

=back

=head2 edit_modbysite

Подключение/отключение модулей к выбранному сайту.

=over 2

=item Примечания:

Напрямую не вызывается. Передаётся только через поле B<act> вызывающей HTML-формы.

=item Зависимости:

Нет.

=back

=head2 fileselect

Выводит список файлов по маске из выбранной папки на сервере. Выводится в отдельном окне броузера.

=over 2

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

L<SOAP::Lite>, L<SOAP::Header>, L<modules::AuthInfo>, L<modules::NoSOAP>.

=back

=head2 table_compare

Выводит список полей выбранных таблиц из выбранных сайтов для сравнения.

=over 2

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 show_columns

Выводит список полей выбранных таблиц из выбранных сайтов для сравнения.

=over 2

=item Примечания:

Внутренняя функция. Не экспортируется.

=item Зависимости:

Нет.

=back

=head2 table_select

Выводит форму выбора таблиц из выбранных сайтов для сравнения.

=over 2

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 db_table_select

Выводит список таблиц из выбранных сайтов для сравнения.

=over 2

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 table_list

Отдаёт массив имён таблиц из выбранного сайта.

=over 2

=item Примечания:

Внутренняя функция. Не экспортируется.

=item Зависимости:

Нет.

=back

=head2 table_downlist

Выпадающий список имён таблиц из выбранного сайта.

=over 2

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 get_site_data

Отдаёт SOAP-объект для выбранного сайта.

=over 2

=item Примечания:

Внутренняя функция. Не экспортируется.

=item Зависимости:

L<SOAP::Lite>, L<SOAP::Header>, L<modules::NoSOAP>, L<modules::AuthInfo>.

=back

=head2 cmpShow

Выводит таблицу с результатами сравнения таблиц выбранного сайта.

=over 2

=item Примечания:

Внутренняя функция. Не экспортируется.

=item Зависимости:

Нет.

=back

=head2 cmpShowTbl

Выводит таблицу с результатами сравнения таблиц выбранного сайта.

=over 2

=item Примечания:

Внутренняя функция. Не экспортируется.

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
