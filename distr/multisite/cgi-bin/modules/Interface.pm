#!/usr/bin/perl
#
#

# Модуль
package modules::Interface;
use Exporter;
our @ISA=qw(Exporter);
our @EXPORT=qw();
our @EXPORT_OK = qw();
our %EXPORT_TAGS = (
				actions => [qw()],
				elements => [qw()],
					);
our $VERSION=1.9;
use strict;
use CGI qw(escapeHTML);
use modules::Settings;
use modules::DBfunctions;
use modules::Comfunctions;
use modules::Core;
use modules::Debug;

$modules::DBfunctions::dbh = connectDB();

################################################################################
################################## Elements ####################################
################################################################################

################################################################################
################################### Actions ####################################
################################################################################

sub showForm {
	my $form = shift;
	my $iface = shift;
	#modules::Debug::notice($form,$iface,1);
	$iface = (defined $iface and -e $modules::Settings::c{dir}{interface}.$iface.'.htm')?$iface:'';
	my $file_iface = ($form ne 'error')?((!$iface)?"admin.htm":qq{$iface.htm}):"error.htm";
	my $out;
	my $ipath = $modules::Settings::c{dir}{interface}.$file_iface;
	open (FILE_INTERFACE, "<"."$ipath");
		while (<FILE_INTERFACE>) {
			my $issi_temp = "$_";
			while ($issi_temp =~ /\<\!--\#include\svirtual="form"--\>/) {
				my $r = modules::Core::getForm($form);
				$r = modules::Core::filterByPerm($r,$modules::Security::permission);
				my $rr = $issi_temp;
				$rr =~ s/\<\!--\#include\svirtual="form"--\>/$r/g;
				$out .= $rr;
				$issi_temp =~ s/\<\!--\#include\svirtual="form"--\>//g;
				print $rr
			}
			while ($issi_temp =~ /\<\!--\#include\svirtual="error"--\>/) {
				 my $r = modules::Core::error() || "";
				 $issi_temp =~ s/\<\!--\#include\svirtual="error"--\>/$r/g;
			}
			while ($issi_temp =~ /\<\!--\#include\svirtual="result"--\>/) {
				my $result = open_file_result("result.htm");
				$issi_temp =~ s/\<\!--\#include\svirtual="result"--\>/$result/g;
				undef($modules::Validate::result_msg);
			}
			while ($issi_temp =~ /\<\!--\#include\svirtual="([^"]+)"--\>/) {
				$issi_temp =~ s|\<\!--\#include\svirtual="([^"]+)"--\>|
				my $remove;
				(($remove = eval "$1()") or !$@)?$remove:qq{<i>Interface</i>: <b>Вызов неизвестной функции "$1" в строке $. !!!</b><br/>($@)<br/> Проверьте исходный код.}
				|gex
			}
			$out .= $issi_temp;
			print $issi_temp;
# 			if (scalar keys %modules::Security::ERROR) {
# 				print modules::Core::error();
# 				last
# 			}
		}
	close (FILE_INTERFACE);
	modules::Security::extract_act($out)
}

sub open_file_result {
	my ($file_iface)=@_;
 	return "" unless $modules::Security::FORM{act};
	my $result_msg = get_result_message();
	return "" unless $result_msg;
	my $fpath = $modules::Settings::c{dir}{interface}.$file_iface;
	my ($fssi_temp,$str);
	open (RESULT, "<"."$fpath");
		while (<RESULT>) {
			$fssi_temp = "$_";
			while ($fssi_temp =~ /\<\!--\#include\svirtual="result"--\>/) {
				$fssi_temp =~ s/\<\!--\#include\svirtual="result"--\>/$result_msg/g;
			}
			$str .= $fssi_temp;
		}
	close (RESULT);
	return $str
} # open_file_result

sub css {
	my $out;
	my $css;
	my $ua = $ENV{HTTP_USER_AGENT};
	if ($ua =~ /Opera/) {
		$css = 'opera'
	} elsif ($ua =~ /Gecko/) {
		$css = 'mozilla'
	} else {
		$css = 'ie'
	}
	$out = qq{<link href="/$css.css" rel="stylesheet" type="text/css">} if -e $modules::Settings::c{dir}{htdocs}.qq{/$css.css};
	return $out
}

sub formname {
	my $act = $modules::Security::FORM{'returnact'};
	my $mod = $modules::Security::session->param('module');
	my $funcname = $modules::DBfunctions::dbh->selectrow_array("SELECT menuname_fld FROM ".lc($mod)."_forms_tbl WHERE ".lc($mod)."_forms_fld='$act'")||$modules::DBfunctions::dbh->selectrow_array("SELECT menuname_fld FROM ".lc($mod)."_forms_tbl WHERE ".lc($mod)."_forms_fld='$modules::Security::FORM{'prev_act'}'");
	my $m = $modules::DBfunctions::dbh->selectrow_array("SELECT menuname_fld FROM module_tbl WHERE module_fld='$mod'");
	my $s = $modules::DBfunctions::dbh->selectrow_array("SELECT site_fld FROM site_tbl WHERE site_id=".$modules::Security::session->param('site'));
	return qq{$funcname | $m | $s}
} # formname

sub sitename {
	my $s = $modules::DBfunctions::dbh->selectrow_array("SELECT site_fld FROM site_tbl WHERE site_id=".$modules::Security::session->param('site'));
	return qq{$s}
}

sub formHead {
	my $act = $modules::Security::FORM{'returnact'};
	my $mod = $modules::Security::session->param('module');
	my $funcname = $modules::DBfunctions::dbh->selectrow_array("SELECT head_fld FROM ".lc($mod)."_forms_tbl WHERE ".lc($mod)."_forms_fld='$act'")||$modules::DBfunctions::dbh->selectrow_array("SELECT head_fld FROM ".lc($mod)."_forms_tbl WHERE ".lc($mod)."_forms_fld='$modules::Security::FORM{'prev_act'}'");
	return qq{$funcname}
} # formname

sub bugReport {
	my $out;
	$out .= qq{<form method="POST" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl" name="bug"><a href="#" onclick="showBR();if(this.className=='headlink-clk'){this.className='headlink'}else{this.className='headlink-clk'}" alt="BUG REPORT" title="BUG REPORT" class="headlink" id="brL">BUG REPORT</a><input type="hidden" name="returnact" value="bugreport"/>}.logpass(); # document.forms.bug.submit()
	foreach my $ek (keys %modules::Security::ERROR) {
		if (ref $modules::Security::ERROR{$ek} eq 'ARRAY') {
			foreach (@{$modules::Security::ERROR{$ek}}) {
				#s/"/\"/g;
				#s/</&lt;/g;
				s/>/&gt;/g;
				$out .= qq{<input type="hidden" name="ERROR_$ek" value="$_"/>}
			}
		} else {
			$out .= qq{<input type="hidden" name="ERROR_$ek" value="$modules::Security::ERROR{$ek}"/>}
		}
	}
	$out .= qq{</form>};
	$out .= qq{<div id="BR" class="redblock" style="position: absolute; left: -1000px; z-index: -1000; visibility: hidden;">
<div class="closepic" align="right"><img src="/img/close-off.gif" width="14" height="14" border="0" onMouseOver="this.src='/img/close-on.gif'" onMouseout="this.src='/img/close-off.gif'" onclick="layer('BR').hide();\$('brL').className='headlink';return false"></div>
<h3>Окружение</h3>
<table class="tab" width="99%" cellpadding="0">
<tr><td>
  <table class="tab2" width="100%" cellpadding="0">};
	$out .= qq{
	<tr><th>Переменная</th><th>Значение</th></tr>};
	%modules::Security::FORM = (%modules::Security::FORM,%modules::Security::ERROR,'User-Agent'=>$ENV{HTTP_USER_AGENT});
	$modules::Security::FORM{password} = '*' x 16;
	$modules::Security::FORM{site_name} = $modules::DBfunctions::dbh->selectrow_array("SELECT site_fld
															FROM site_tbl
															WHERE site_id=$modules::Security::FORM{site_id}");
	my $i = 1;
	#delete $modules::Security::FORM{pagecontent_fld};
	foreach (sort { $a cmp $b } keys %modules::Security::FORM) {
		next if $_ eq 'site_id';
		$out .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{"><td class="tl" valign="top"><b>$_</b></td>};
		if ($_ eq 'ERROR_act') {
			$modules::Security::FORM{$_} =~ s/\\"/"/g;
		}
		unless (ref $modules::Security::FORM{$_}) {
			my $v = $modules::Security::FORM{$_};
			$v = substr $v,0,255 if length $v > 255;
			$v = escapeHTML($v);
			$v =~ s/</&lt;/g;
			#modules::Debug::dump($v);
			$v .= '...' if length $modules::Security::FORM{$_}>255;
			$out .= qq{<td class="tl">}.$v
		} else {
			$out .= qq{<td class="tal">}.modules::Debug::dump($modules::Security::FORM{$_})
		}
		$out .= qq{</td></tr>}
	}
	$out .= qq{</table>
</td></tr></table>
</div><!--/table></div></td></tr></table-->};
	$out .= qq{
	<script type="text/javascript">
		var dw = getDocumentWidth();
		var dh = getDocumentHeight();
		var br = layer('BR');
		br.setTop((dh-br.getHeight())/2);
		br.setZIndex(-1000);
		function showBR() {
			if (!br.getVisibility()) {
				br.setZIndex(1000);
				br.setLeft((getDocumentWidth()-br.getWidth())/2);
				br.show()
			} else {
				br.setZIndex(-1000);
				br.setLeft(-1000);
				br.hide()
			}
		}
	</script>};
	return $out
}

sub formLink {
	my $out;
	$out .= qq{<form method="POST" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl" name="_ffl"><a href="#" onclick="toggFL(this);" alt="Ссылка на форму" title="Ссылка на форму" class="headlink" id="_fl">Ссылка на форму</a>}.logpass(); # document.forms.bug.submit()
	$out .= qq{<div style="min-width: 50px;" id="fl"><div id="_id"></div><table class="tab" cellpadding="0">
	<tr><td class="tal" title="Пользователь"><select name="user_id"><option value="">-- Выберите --</option>}.xModCall('System','user_downlist','e').qq{</select></td><td class="tl"><input type="checkbox" name="wact" value="1" id="wa"/><label for="wa">с действием</label></td><td class="tal"><input type="Image" src="/img/but/apply_s1.gif" title="Получить ссылку" class="but" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"/></td></tr>
	</table></div>};
	$out .= returnact().qq{</form>};
	return $out
}

sub modHead {
	my $mod = $modules::Security::session->param('module');
	my $img = $modules::DBfunctions::dbh->selectrow_array("SELECT headpic_fld FROM module_tbl WHERE module_fld='$mod'") || '/img/common_head.gif';
	my $path = ($img ne '/img/common_head.gif')?$modules::Settings::c{dir}{cgi_ref}.qq{/modules/$mod}:'';
	return qq{<img src="$path$img" border="0">}
}

sub toplist {
	my $out;
	my @sitelist;
	my @sites;
	my %se;
	my $sth = $modules::DBfunctions::dbh->prepare("SELECT DISTINCTROW site_id FROM permission_tbl WHERE user_id=".$modules::Security::session->param('user'));
	$sth->execute();
	while (my @row = $sth->fetchrow_array) {
		push @sites, $row[0] unless $row[0]==256
	}
	$sth = $modules::DBfunctions::dbh->prepare("SELECT site_id,COUNT(site_id) FROM site_module_tbl WHERE site_id IN (".(join ','=>@sites).") GROUP BY site_id");
	$sth->execute();
	while (my @row = $sth->fetchrow_array) {
		$se{$row[0]} = $row[1];
	}
	$sth = $modules::DBfunctions::dbh->prepare("SELECT site_id,site_fld
						  FROM site_tbl
						  WHERE site_id IN (".(join ","=>keys %se).")
						  ORDER BY site_fld");
	$sth->execute();
	$out .= qq{<form method="post" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl" name="gtop"><select name="site" onchange="submit('gtop')" class="top">};
	# Extended permssion
	if ($modules::DBfunctions::dbh->selectrow_array("SELECT extperm_fld FROM user_tbl WHERE user_id=".$modules::Security::session->param('user'))) {
		$out .= qq{<option value="256"}.(($modules::Security::session->param('site')==256)?" selected":"").qq{>System</option>}
	}
	my %site;
	while (my @row = $sth->fetchrow_array) {
		$site{$row[1]} = $row[0]
	}
	my %s;
	foreach (sort { (split ' ',$a)[-1] cmp (split ' ',$b)[-1] || (split ' ',$a)[0] cmp (split ' ',$b)[0]} keys %site) {
		my ($n,$sect) = $_ =~ /(.+)\s(.+)$/; # split ' ';
		$sect =~ s/\(([^)]+)\)/$1/;
		$s{$sect} .= qq{<option value="$site{$_}"}.(($site{$_}==$modules::Security::session->param('site'))?" selected":"").qq{>$_</option>};
	}
	foreach (sort {$a cmp $b} keys %s) {
		$out .= qq{<optgroup label="$_">}.$s{$_}.qq{</optgroup>}
	}
	$out .= qq{</select><input type="hidden" name="_4SITESID" value="}.($modules::Security::session->id).qq{"/>
	<input type="hidden" name="user" value="}.$modules::Security::session->param('user').qq{"/>
	<input type="hidden" name="prev_act" value="}.(($modules::Security::session->param('enabled'))?$modules::Security::session->param('returnact'):$modules::Security::session->param('prev_act')).qq{"/></form>};
	return $out
}

sub link2site {
	my $out;
	my ($s,$u) = $modules::DBfunctions::dbh->selectrow_array("SELECT site_fld,host_fld
						  FROM site_tbl
						  WHERE site_id=".$modules::Security::session->param('site'));
	$out .= qq{<a href="http://$u" alt="http://$u" title="http://$u" target="_blank"><img src="/img/onsite.gif" border="0" align="absmiddle" class="top"><b>На&nbsp;сайт</b></a>};
	return $out
}

sub link2site_mirror {
	my $out;
	my $m = $modules::DBfunctions::dbh->selectrow_array("SELECT mirror_id FROM site_tbl WHERE site_id=".$modules::Security::session->param('site'));
	return unless $m;
	my $mod = lc $modules::Security::session->param('module');
	my $mid = $modules::DBfunctions::dbh->selectrow_array("SELECT module_id FROM module_tbl WHERE module_fld='".$modules::Security::session->param('module')."'");
	my $frm = $modules::DBfunctions::dbh->selectrow_array(sprintf "SELECT %s_forms_id FROM %s_forms_tbl WHERE %s_forms_fld='%s'",$mod,$mod,$mod,$modules::Security::session->param('returnact'));
	my $perm = $modules::DBfunctions::dbh->selectrow_array("SELECT permission_fld FROM permission_tbl WHERE site_id=$m AND form_id=$frm AND user_id=".$modules::Security::session->param('user')." AND module_id=$mid");
	return unless $perm;
	$out .= qq{<td width="4"><img src="/img/1pix.gif" width="4"></td>
<td class="tmenu-off" onMouseOver="this.className='tmenu-on'" onMouseDown="this.className='tmenu-down'" onMouseOut="this.className='tmenu-off'"><p class="tmenu"><a href="#" title="На эту же форму на зеркале" onclick="submit('mrrr')"><img src="/img/onsite.gif" border="0" align="absmiddle" class="top"/><b>На&nbsp;зеркало</b></a></p></td><form method="post" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl" name="mrrr"><input type="hidden" name="_4SITESID" value="}.($modules::Security::session->id).qq{"/><input type="hidden" name="user" value="}.$modules::Security::session->param('user').qq{"/><input type="hidden" name="site" value="$m"/><input type="hidden" name="prev_act" value="}.(($modules::Security::session->param('enabled'))?$modules::Security::session->param('returnact'):$modules::Security::session->param('prev_act')).qq{"/><input type="hidden" name="returnact" value="}.$modules::Security::session->param('returnact').qq{"/></form>};
	return $out
}

sub site_list {
	my $out;
	my @sitelist;
	my @sites;
	my %se;
	my $sth = $modules::DBfunctions::dbh->prepare("SELECT DISTINCTROW site_id FROM permission_tbl WHERE user_id=".$modules::Security::session->param('user'));
	$sth->execute();
	while (my @row = $sth->fetchrow_array) {
		push @sites, $row[0] unless $row[0]==256
	}
	$sth = $modules::DBfunctions::dbh->prepare("SELECT site_id,COUNT(site_id) FROM site_module_tbl WHERE site_id IN (".(join ','=>@sites).") GROUP BY site_id");
	$sth->execute();
	while (my @row = $sth->fetchrow_array) {
		$se{$row[0]} = $row[1];
	}
	$sth = $modules::DBfunctions::dbh->prepare("SELECT site_id,site_fld
						  FROM site_tbl
						  WHERE site_id IN (".(join ","=>keys %se).")
						  ORDER BY site_fld");
	$sth->execute();
	$out .= qq{<form method="post" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl" name="sites">};
	$out .= qq{<table border="0" cellpadding="0" cellspacing="0">};

	my %site;
	while (my @row = $sth->fetchrow_array) {
		$site{$row[1]} = $row[0]
	}
	my %s;
	foreach (sort { (split ' ',$a)[-1] cmp (split ' ',$b)[-1] || (split ' ',$a)[0] cmp (split ' ',$b)[0]} keys %site) {
		my ($n,$sect) = $_ =~ /(.+)\s(.+)$/; # split ' ';
		$sect =~ s/\(([^)]+)\)/$1/;
		$s{$sect} .= qq{<tr><td class="tl-main"><a href="#" onclick="document.forms.sites.site.value='$site{$_}';submit('sites')" class="link"><img src="/img/}.lc($sect||'noname').qq{.gif" border="0" align="absmiddle">$_</a></td></tr>};
	}
	my $out1;
	my $out2;
	foreach (sort {$a cmp $b} keys %s) {
		$out1 .= qq{<td nowrap style="padding-right:35px;"><h3>$_</h3></td>};
		$out2 .= qq{<td nowrap style="padding-right:35px;" valign="top"><table border="0" cellpadding="0" cellspacing="0" width="100%">}.$s{$_}.qq{</table></td>}
	}
	$out .= qq{<tr>$out1</tr><tr>$out2</tr></table>};
	$out .= qq{<input type="hidden" name="site" value=""/>
	<input type="hidden" name="_4SITESID" value="}.($modules::Security::session->id).qq{"/>
	<input type="hidden" name="user" value="}.$modules::Security::session->param('user').qq{"/>
	<input type="hidden" name="prev_act" value="}.(($modules::Security::session->param('enabled'))?$modules::Security::session->param('returnact'):$modules::Security::session->param('prev_act')).qq{"/></form>};
	return $out
}

sub system_button {
	my $uid = $modules::Security::session->param('user');
	return unless $modules::DBfunctions::dbh->selectrow_array("SELECT COUNT(*) FROM permission_tbl
																WHERE user_id=$uid
																AND site_id=256
																AND module_id=19");
	return qq{<p class="tmenu"><img src="/img/system-active.gif" border="0" align="absmiddle" class="top">Система</p>}
}

# Левое меню в интерфейсе
sub left_menu {
	my $out;
	my $select = 0;
	my (@func, @group);
	my $logpass = modules::Comfunctions::logpass();
	my @modlist;
	my %p;
	my $sth = $modules::DBfunctions::dbh->prepare("SELECT DISTINCT module_id FROM permission_tbl WHERE site_id=$modules::Security::FORM{site} AND user_id=$modules::Security::FORM{user}");
	$sth->execute();
	while (my @row = $sth->fetchrow_array) {
		$p{$row[0]}++
	}
	$sth = $modules::DBfunctions::dbh->prepare("SELECT sm.module_id,m.module_fld,m.menuname_fld
						  FROM module_tbl as m, site_module_tbl as sm
						  WHERE m.module_id=sm.module_id AND
						  site_id=$modules::Security::FORM{site}
						  AND m.module_id IN (".(join ','=>keys %p).")
						  ORDER BY m.order_fld");
	$sth->execute();
	while (my @row = $sth->fetchrow_array) {
		push @modlist, \@row
	}

	my $num = scalar @modlist;
	my $act = $modules::Security::FORM{'returnact'};
	if ($modules::Security::FORM{prev_site}) {
		$act = $modules::Security::FORM{prev_act} unless $modules::Security::session->param('enabled')
	}
	my $user_id = $modules::Security::FORM{user};
	my $pa = $modules::Security::FORM{prev_act};
	my $curmid = $modules::DBfunctions::dbh->selectrow_array("SELECT module_id FROM module_tbl WHERE module_fld='".$modules::Security::FORM{module}."'");
	foreach (@modlist) {
		my ($id,$mod,$name) = @$_;
		my $f = $mod;
		$out .= qq{<table border="0" cellpadding="0" cellspacing="0" class="lmenu">
		<tr onclick="toggleSection($id)" style="cursor: pointer">
			<td class="lmenu" nowrap><p class="lmenu1">$name</p></td>
			<td align="right" class="lmenu"><img src="/img/close2.gif" border="0" hspace="5" id="im$id"></td>
		</tr>
		<tr>
			<td colspan="2" valign="top">};
		# Here goes the sub-menu (forms)
		$out .= qq{<form method="POST" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl" name="l$f">}.
				$logpass.
				qq{<input type="hidden" name="returnact" value=""/>}
				.modules::Core::stdate_hidden().modules::Core::enddate_hidden();
		my $mid = $modules::DBfunctions::dbh->selectrow_array("SELECT module_id FROM module_tbl WHERE module_fld='$mod'");

		my $sth = $modules::DBfunctions::dbh->prepare("SELECT ".lc($mod)."_forms_id,".lc($mod)."_forms_fld,menuname_fld,permission_fld FROM ".lc($mod)."_forms_tbl as t, permission_tbl as p WHERE t.".lc($mod)."_forms_id=p.form_id AND p.module_id=$mid AND p.site_id=$modules::Security::FORM{site} AND user_id=$user_id AND t.menuenable_fld='1' ORDER BY t.order_fld");
		$sth->execute();
		$out .= qq{<ul id="m$id" style="display: none" class="lmenu_inner">};
		while (my @function = $sth->fetchrow_array) {
			next unless $function[2];
			my $n = $function[2];
			$n = substr($n,0,22).'...' if length($n)>22;
			if ($function[1] eq $act) {
				$out .= qq{<li}.(!$modules::Security::session->param('enabled')?qq{  onclick="sub_del('l$f','$function[1]')" style="cursor: pointer"}:'').qq{ class="open" alt="$function[2]" title="$function[2]"><img src="/img/select2.gif" border="0" align="absmiddle" style="margin-right: 3px; margin-left: 1px;">};
				$out .= ($modules::Security::session->param('enabled'))?qq{<b class="lmenu2">$n</b>}:qq{$n};
				$out .= qq{</li>};
			} else {
				$out .= qq{<li class="lmenu2"><a href="#" alt="$function[2]" title="$function[2]" onclick="sub_del('l$f','$function[1]')">$n</a></li>}
			}
		}
		$out .= qq{</ul></form>};
		# //End of sub-menu
		$out .= qq{
			</td>
		</table>}.($id==$curmid?qq{<script>
Element.show('m$curmid')
\$('im$curmid').src = '/img/open2.gif'
</script>}:'')
	}
	return $out
} # left_menu

sub fav_button {
	my $out;
	my $act = $modules::Security::FORM{'returnact'};
	my $user_id = $modules::Security::session->param('user');
	my $logpass = modules::Comfunctions::logpass();

	my $m = lc $modules::Security::FORM{module};
	my $modid = $modules::DBfunctions::dbh->selectrow_array("SELECT module_id FROM module_tbl WHERE module_fld='$modules::Security::FORM{module}'");
	my ($frm_id,$enable);
	($frm_id,$enable) = $modules::DBfunctions::dbh->selectrow_array("SELECT ${m}_forms_id,menuenable_fld FROM ${m}_forms_tbl WHERE ${m}_forms_fld='$act'") if $m;
	my $exists;
	$exists = $modules::DBfunctions::dbh->selectrow_array("SELECT favorites_id FROM favorites_tbl WHERE user_id=$modules::Security::FORM{user} AND site_id=$modules::Security::FORM{site} AND module_id=$modid AND form_id=$frm_id") if $modid;
	# Флаг возможности добавления текущей формы в "Избранное"
	my $flg = (!$exists && ($enable eq '1'));
	my $mod;
	$mod = $modules::DBfunctions::dbh->selectrow_array("SELECT module_fld FROM module_tbl WHERE module_id=$modules::Security::FORM{module_id}") if $modules::Security::FORM{module_id};
	$out .= (($flg)?qq{<form method="POST" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl" name="fav">}:'').qq{
	<tr }.(($flg)?qq{onmouseover="hilite(this)" onmouseout="unlite(this)" onclick="submit('fav')" style="cursor: hand"}:'').qq{><td nowrap class="}.(($flg)?'favor':'nofavor').qq{">Добавить в избранное&#133;</td></tr>
	}.(($flg)?qq{<input type="hidden" name="act" value="add_favorites"/>
	<input type="hidden" name="returnact" value="$act"/>
	<input type="hidden" name="function_fld" value="$act"/>
	<input type="hidden" name="module" value="$modules::Security::FORM{module}"/>
	$logpass</form>}:'').qq{
	<tr><td height="1"><img src="/img/1pix.gif" width="2" height="1"><img src="/img/1pix-green.gif" width="97%" height="1"><img src="/img/1pix.gif" width="2" height="1"></td></tr>
};
	return $out
} # fav_button

sub favorites {
	my $out;
	my $i = 1;
	my $logpass = modules::Comfunctions::logpass();
	my $user_id = $modules::Security::FORM{user};
	# "SYSTEM" workaround
	my $sth = $modules::DBfunctions::dbh->prepare("SELECT DISTINCT m.module_id, module_fld, menuname_fld
										FROM `favorites_tbl` as f, module_tbl as m
										WHERE user_id=$user_id
										AND site_id=$modules::Security::FORM{site}
										AND f.module_id=m.module_id
										ORDER BY f.module_id, form_id");
	$sth->execute();
	my @mod;
	while (my @row = $sth->fetchrow_array) {
		$out .= qq{<tr><td class="favor1">$row[2]</td></tr>};
		my $mod = lc $row[1];
		my $sth1 = $modules::DBfunctions::dbh->prepare("SELECT ${mod}_forms_fld,ff.menuname_fld
												 FROM favorites_tbl as f, ${mod}_forms_tbl as ff
												 WHERE user_id=$user_id
												 AND f.module_id=$row[0]
												 AND ${mod}_forms_id=form_id
												 AND site_id=$modules::Security::FORM{site}");
		$sth1->execute();
		while (my ($frm,$name) = $sth1->fetchrow_array) {
			$out .= qq{<tr onmouseover="hilite(this)" onmouseout="unlite(this)" onclick="submit('f$row[0]')" style="cursor: hand">
			<form method="POST" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl" name="f$row[0]">
			$logpass<input type="hidden" name="returnact" value="$frm"/>
			<td class="favor2">$name</td>
			</form>
			</tr>}
		}
	}
	return $out
} # favorites

sub help_button {
	my $out;
	my $mod = lc $modules::Security::FORM{module};
	my $form = $modules::Security::FORM{returnact};
	if ($modules::DBfunctions::dbh->selectrow_array("SELECT help_fld
														FROM ".(lc $mod)."_forms_tbl
														WHERE ".(lc $mod)."_forms_fld='$form'")) {
		$out .= qq{<td width="2"><img src="/img/1pix.gif" width="2"></td><td class="tmenu-off" onmouseover="this.className='tmenu-on'" onmouseout="this.className='tmenu-off'" onclick="this.className='tmenu-down';showHideHelp('help')" style="cursor: hand;"><p class="tmenu"><img src="/img/help.gif" border="0" align="absmiddle" class="top">Помощь</p></td><td width="4"><img src="/img/1pix.gif" width="4"></td>}
	}
	return $out
}

sub help {
	my $out;
	my $mod = lc $modules::Security::FORM{module};
	my $form = $modules::Security::FORM{returnact};
	my $help = $modules::DBfunctions::dbh->selectrow_array("SELECT help_fld
														FROM ".(lc $mod)."_forms_tbl
														WHERE ".(lc $mod)."_forms_fld='$form'");
	$out .= qq{<table border="0" cellpadding="0" cellspacing="0" class="favor" id="_help" style="position: absolute; top: 32px; z-index: 1500; visibility: hidden"><tr><td valign="top"><h2>module '$modules::Security::FORM{module}'</h2><h3>form '$modules::Security::FORM{returnact}'</h3><p class="tl">$help</p></td></tr></table>};
	return $out
}

sub switchBoard {
	my $out;
	$out .= qq{<br/><table border="0" cellpadding="0" cellspacing="0" width="90%" id="main">};
	my (@func, @group);
	my $logpass = modules::Comfunctions::logpass();
	my @modlist;
	my @p;
	my $sth = $modules::DBfunctions::dbh->prepare("SELECT DISTINCT module_id FROM permission_tbl WHERE site_id=".$modules::Security::session->param('site')." AND user_id=".$modules::Security::session->param('user'));
	$sth->execute();
	while (my @row = $sth->fetchrow_array) {
		push @p,$row[0]
	}
	$sth = $modules::DBfunctions::dbh->prepare("SELECT sm.module_id,m.module_fld,
							m.menuname_fld,m.pic_fld
							FROM module_tbl as m, site_module_tbl as sm
							WHERE m.module_id=sm.module_id AND
							site_id=".$modules::Security::session->param('site')."
							AND m.module_id IN (".(join ','=>@p).")
							ORDER BY m.order_fld");
	$sth->execute();
	while (my @row = $sth->fetchrow_array) {
		push @modlist, \@row
	}
	my $mw = 173;
	for my $j (1..(int(scalar(@modlist) / 4)+1)) {
		$out .= qq{<tr valign="top">};
		for my $i (1..4) {
			if (my $mod = shift @modlist) {
				my $out1 = qq{<form method="POST" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl" name="lm$mod->[1]"><table width="$mw" border="0" cellpadding="0" cellspacing="0" class="mod" id="mm$mod->[0]" style="position: absolute; left: 100px; display: none; min-width: ${mw}px">}.logpass.qq{<input type="hidden" name="returnact" value=""/>};
				my $sth1 = $modules::DBfunctions::dbh->prepare("SELECT ".lc($mod->[1])."_forms_id,".lc($mod->[1])."_forms_fld,menuname_fld,permission_fld FROM ".lc($mod->[1])."_forms_tbl as t, permission_tbl as p WHERE t.".lc($mod->[1])."_forms_id=p.form_id AND p.module_id=$mod->[0] AND p.site_id=".$modules::Security::session->param('site')." AND user_id=".$modules::Security::session->param('user')." AND (t.menuenable_fld<>'2' OR t.menuenable_fld<>'0') ORDER BY t.order_fld");
				$sth1->execute();
				my $form = '';
				$out1 .= qq{<tr><td><ul>};
				while (my @function = $sth1->fetchrow_array) {
					next unless $function[2];
					$form = $function[1] unless $form;
					my $n = $function[2];
					$n = substr($n,0,22).'...' if length($n)>22;
					$out1 .= qq{<li class="lmenu2"><a href="#" onclick="sub_del('lm$mod->[1]','$function[1]')" alt="$function[2]" title="$function[2]">$n</a></li>}
				}
				$out1 .= qq{</ul></td></tr></table></form>};
				$mod->[3] ||= qq{/img/common.gif};
				my $path = ($mod->[3] ne '/img/common.gif')?$modules::Settings::c{dir}{cgi_ref}.qq{/modules/$mod->[1]}:'';
				$out .= qq{<td class="tl-green" width="25%" id="tdm$mod->[0]">
				<form method="POST" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl" name="mmm$mod->[0]">
				<a href="#" onclick="submit('mmm$mod->[0]')" class="tl-green"><img src="$path$mod->[3]" border="0"></a><br/><span onclick="toggleSectionM($mod->[0]);return false" id="am$mod->[0]" style="cursor: pointer; cursor: hand">$mod->[2]&nbsp;<img src="/img/close1.gif" border="0" id="imm$mod->[0]"></span>
				<input type="hidden" name="returnact" value="$form"/>
				}.logpass.qq{
				</form>
				<table border="0" cellpadding="0" cellspacing="0" class="mod">
				<tr><tr><td height="1" width="$mw"><img src="/img/1pix.gif" height="1" width="120"></td></tr></table>
				$out1
				</td>};
			}
		}
		$out .= qq{</tr><tr><td colspan="4" height="15"><img src="/img/1pix.gif" height="15" border="0"></td></tr>}
	}
	$out .= qq{</table>};
	return $out
}

sub cgi_ref { modules::Core::cgi_ref() }

sub logpass_user { modules::Comfunctions::logpass_user() }

sub preload_buttons {
	my $out = qq{preloadImages(};
	my @files = glob $modules::Settings::c{dir}{htdocs}.'/img/but/*.gif';
	#modules::Debug::dump(\@files);
	@files = map { m!(/img/but/.+?\.gif)!; qq{'$1'} } @files;
	$out .= (join ','=>@files).qq{);};
	return $out
}

1;
__END__

=head1 NAME

B<Interface.pm> — Модуль отрисовки интерфейса Системы.

=head1 SYNOPSIS

Модуль отрисовки интерфейса Системы.

=head1 DESCRIPTION

Модуль отрисовки интерфейса Системы.

=head2 showForm

Выводит список скриптов и модулей выбранного сайта с отметками и описаниями.

=over 2

=item Примечания:

Вызывается напрямую из 4site.pl.

=item Зависимости:

Нет (или, что равнозначно, все модули 4Site).

=back

=cut
=head2 open_file_result

Выводит результат действия (т.е. B<act>).

=over 2

=item Примечания:

Вызывается из L<showForm>.

=item Зависимости:

Нет.

=back

=head2 formname

Выводит название формы (т.е. то, что соответствует полю B<returnact>).

=over 2

=item Примечания:

Вызывается из L<showForm>.

=item Зависимости:

Нет.

=back

=head2 toplist

Выводит список сайтов, доступных текущему пользователю.

=over 4

=item Вызов:

C<< <!--#include virtual="toplist"--> >>

=item Пример вызова:

C<< <!--#include virtual="toplist"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 left_menu

Выводит список форм, доступных текущему пользователю в выбранном разделе.

=over 4

=item Вызов:

C<< <!--#include virtual="left_menu"--> >>

=item Пример вызова:

C<< <!--#include virtual="left_menu"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 fav_button

Выводит список "Любимых функций" текущего пользователя.

=over 4

=item Вызов:

C<< <!--#include virtual="fav_button"--> >>

=item Пример вызова:

C<< <!--#include virtual="fav_button"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 favorites

Выводит кнопку для добавления текущей формы в список "Любимых функций".

=over 4

=item Вызов:

C<< <!--#include virtual="favorites"--> >>

=item Пример вызова:

C<< <!--#include virtual="favorites"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 htmlarea

В зависимости от настроек, встраивает код для загрузки HTMLArea.

=over 4

=item Вызов:

C<< <!--#include virtual="htmlarea"--> >>

=item Пример вызова:

C<< <!--#include virtual="htmlarea"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 switchBoard

На начальной странице управления сайтом выводит "таблицу" из названий и картинок модулей с выпадающими меню каждого модуля (работает как левое меню).

=over 4

=item Вызов:

C<< <!--#include virtual="switchBoard"--> >>

=item Пример вызова:

C<< <!--#include virtual="switchBoard"--> >>

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

E<copy> Copyright 2003, Method Lab

=cut
