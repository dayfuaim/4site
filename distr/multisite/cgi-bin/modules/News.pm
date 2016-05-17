#!/usr/bin/perl

# Модуль
package modules::News;
use Exporter;
our @ISA=qw(Exporter);
our @EXPORT=qw(get_actions);
our %EXPORT_TAGS = (
				actions => [qw(add_news edit_news del_news edit_news_setting
							add_news_group edit_news_group del_news_group
							add_news_pix edit_news_pix del_news_pix
							order_news_group rss_gen
							add_news_tr edit_news_tr del_news_tr)],
				elements => [qw(news_settings_list news_list news_edit news_group_list
							 news_group_downlist news_downlist news_pix_list
							 news_group_order_drag news_tr_list
							 lag_downlist_sel)],
					);
our @EXPORT_OK = (get_actions, @{$EXPORT_TAGS{actions}}, @{$EXPORT_TAGS{elements}});
our $VERSION=1.9;
use CGI;
use CGI(escapeHTML);
use XML::RSS;
use strict;
use modules::DBfunctions;
use modules::ModSet;
#use modules::Core qw(:actions);
use modules::Comfunctions qw(:DEFAULT :elements :records :downlist);
use modules::Gallery qw(:elements);
use modules::Validfunc;
use modules::Debug;
use vars qw(%Validate);

sub get_actions {
	return $EXPORT_TAGS{actions}
}

################################################################################
################################## Elements ####################################
################################################################################

sub news_settings_list { module_settings_list("news") } # news_settings_list

sub news_list { # Список найденных новостей за период
	my $out;
	if ($::SHOW) {
		my $st = $modules::Security::FORM{stdate};
		my $end = $modules::Security::FORM{enddate};

		$st = sprintf "%4d-%02d-%02d 00:00:00",reverse split /\./=>$st;
		$end = sprintf "%4d-%02d-%02d 23:59:59",reverse split /\./=>$end;
		my $sql = "SELECT news_id, date_format(date_fld,'%Y%m%d%H%i%s'),
				   head_fld, body_fld
				   FROM news_tbl
				   WHERE 1";
		unless ($modules::Security::FORM{lag}) {
			$sql .= " AND (date_fld BETWEEN '$st' AND '$end')";
		} else {
			my $int = $modules::Core::soap->getQuery("SELECT sql_fld FROM news_tr_tbl WHERE title_fld='$modules::Security::FORM{lag}'")->result;
			$sql .= " AND (date_fld BETWEEN $int AND NOW())" if $int
		}
		$sql .= " ORDER BY date_fld DESC";
		#print $sql;
		my @r = $modules::Core::soap->getQuery($sql)->paramsout;
		if (scalar @r) {
			$out .= qq{<h2>Найденные новости</h2>}.start_table().head_table('Дата','Заголовок/Текст');
			my $nt = qq(<td class="tl">{DATE}</td><td class="tl"><b>{HEAD}</b><br/>{BODY}</td>); # get_setting("news","template_system");
			my $pl = get_setting("news","preview_length");
			my $i = 1;
			foreach (@r) {
				my @row = @$_;
				my $date = $row[1];
				$date =~ s/^(\d{4})(\d\d)(\d\d)(\d\d)(\d\d).*/$3.$2.$1 $4:$5/;
				my $templ = $nt;
				$row[3] = escapeHTML($row[3]);
				$row[2] = escapeHTML($row[2]);
				my $body = $row[3];
				$body = (length $body < $pl)?$body:(substr($body,0,$pl-3).'...');
				$templ =~ s/{ID}/$row[0]/g;
				$templ =~ s/{HEAD}/$row[2]/g;
				$templ =~ s/{DATE}/$date/g;
				$templ =~ s/{BODY}/$body/g;
				$templ =~ s/checkbox/radio/ unless $modules::Security::FORM{mul};
				my $class = qq{tr_col}.($i++ % 2 +1);
				$out .= qq{<tr class="$class" onmouseover="this.className='tr_col3'" onmouseout="this.className='$class'" style="cursor: hand" id="tr$_->[0]">}.$templ.($modules::Security::FORM{returnact} eq 'del_news'?qq{<td class="tal"><input type="Image" src="/img/but/delete_s1.gif" title="Удалить новость"  onmouseover="b_hilite(this)" onmouseout="b_unlite(this)" id="d$_->[0]"></td>}:'').qq[</tr>
				<script type="text/javascript">
				Ext.EventManager.addListener('tr$_->[0]', 'click', function(e) { newsSub(e,false,'','].($modules::Security::FORM{returnact} eq 'edit_news'?'open_news':'news_pix').qq[',$_->[0]) }); ].($modules::Security::FORM{returnact} eq 'del_news'?qq[Ext.EventManager.addListener('d$_->[0]', 'click', function(e) { newsSub(e,$_->[0],'del_news','$modules::Security::FORM{returnact}',$_->[0]) } )]:'').qq{
				</script>
				};
				#  onclick="subm('','open_news',$row[0]);"
				#  onclick="subm('del_news','$modules::Security::FORM{returnact}',$row[0]);"
			}
			$out .= qq{</table></td></tr></table>
			<input type="hidden" name="news" value="">
			<input type="hidden" name="show" value="1">}
		} else {
			$out .= qq{<br/><br/>}.info_msg(qq{За данный период новостей не найдено})
		}
	}
	return $out
} # news_list

sub news_group_list { # список связанных страниц
	my $logpass = logpass();
	my @r = $modules::Core::soap->getQuery("SELECT * FROM news_group_tbl")->paramsout;
	delete $modules::Security::FORM{page_id};
	my $out;
	if (scalar @r) {
		$out .= start_table().head_table('Название (и RSS)',['&nbsp;',2]);
		my $i = 1;
		foreach (@r) {
			$out .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{">}
			.qq{<form method="POST" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl">}
			.qq{<td class="tal"><input type="text" name="news_group_fld" size="32" value="$_->[1]" style="font-weight: bold"><br/>&nbsp;&nbsp;&nbsp;&nbsp;<textarea name="dateformat_fld" cols="40" rows="5" title="Date format">$_->[3]</textarea><br/>&nbsp;&nbsp;&nbsp;&nbsp;<select name="page_id"><option value="">-- None --</option>}.modules::Page::page_ex_downlist($_->[4]).qq{</select>}.($_->[2]?qq{<br/>&nbsp;&nbsp;&nbsp;&nbsp;<input type="text" name="rss_fld" size="30" value="$_->[2]" title="RSS">}:'').qq{</td>}
			.qq{<td class="tal"><input type="Image" src="/img/but/apply_s1.gif" title="Изменить"  onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"><input type="hidden" name="act" value="edit_news_group"><input type="hidden" name="news_group_id" value="$_->[0]"><input type="hidden" name="returnact" value="news_group">$logpass</td>}
			.qq{</form>}
			.qq{<td class="del-red"><form method="POST" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl" name="dng$_->[0]"><input type="Image" src="/img/but/delete_s1.gif" title="Удалить"  onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"><input type="hidden" name="act" value="del_news_group"><input type="hidden" name="news_group_id" value="$_->[0]"><input type="hidden" name="returnact" value="news_group">$logpass</form></td>};
		}
		$out .= end_table()
	} else {
		$out .= info_msg(qq{Нет ни одной группы Новостей})
	}
	return $out
} # news_list

sub news_tr_list {
	my $logpass = logpass();
	my @r = $modules::Core::soap->getQuery("SELECT * FROM news_tr_tbl")->paramsout;
	my $out;
	if (scalar @r) {
		$out .= start_table().head_table('Название / ID','SQL',['&nbsp;',2]);
		my $i = 1;
		foreach (@r) {
			$out .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{">}
			.qq{<form method="POST" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl">}
			.qq{<td class="tal"><input type="text" name="news_tr_fld" size="20" value="$_->[1]" style="font-weight: bold"><br/>&nbsp;&nbsp;&nbsp;&nbsp;<input type="text"  name="title_fld" size="20" value="$_->[2]"></td>
			<td class="tal"><textarea rows="3" name="sql_fld" cols="30">$_->[3]</textarea></td>}
			.qq{<td class="tal"><input type="Image" src="/img/but/apply_s1.gif" title="Изменить"  onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"><input type="hidden" name="act" value="edit_news_tr"><input type="hidden" name="news_tr_id" value="$_->[0]">}.returnact().logpass().qq{</td>}
			.qq{</form>}
			.qq{<td class="del-red"><form method="POST" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl" name="dng$_->[0]"><input type="Image" src="/img/but/delete_s1.gif" title="Удалить"  onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"><input type="hidden" name="act" value="del_news_tr"><input type="hidden" name="news_tr_id" value="$_->[0]">}.returnact().logpass().qq{</form></td>};
		}
		$out .= end_table()
	} else {
		$out .= info_msg(qq{Нет ни одного диапазона})
	}
	return $out
}

sub lag_downlist_sel {
	my $lag = $modules::Security::FORM{lag};
	my $out;
	$out .= qq{<option value="">Точный период</option>};
	my @r = $modules::Core::soap->getQuery("SELECT * FROM news_tr_tbl")->paramsout;
	foreach (@r) {
		$out .= qq{<option value="$_->[2]"}.($_->[2] eq $lag?' selected':'').qq{>$_->[1]</option>}
	}
	return $out
} # lag_downlist_sel


sub news_group_downlist {
	my $out;
	my $sel = shift || $modules::Security::FORM{news_group_id};
	my $rss = shift||undef;
	my @r = $modules::Core::soap->getQuery("SELECT * FROM news_group_tbl ".($rss?"WHERE rss_fld is not null":""))->paramsout;
	foreach (@r) {
		$out .= qq{<option value="$_->[0]"}.($sel==$_->[0]?qq{ selected}:'').qq{>$_->[1]</option>}
	}
	return $out
}

sub news_downlist {
	my $out;
	my $sel = shift || $modules::Security::FORM{news_id};
	my @r = $modules::Core::soap->getQuery("SELECT news_id,DATE_FORMAT(date_fld,'%Y%m%d%H%i%s'),head_fld FROM news_tbl ORDER BY date_fld")->paramsout;
	foreach (@r) {
		$_->[1] =~ s/(\d\d\d\d)(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)/$3.$2.$1 $4:$5:$6/;
		$_->[2] =~ s/\&nbsp;/ /g;
		$out .= qq{<option value="$_->[0]"}.(($_->[0]==$sel)?" selected":"").qq{>[$_->[1]] }.(length($_->[2])<=32?$_->[2]:substr($_->[2],0,32)."...").qq{</option>}
	}
	return $out
}

sub news_edit { # Редактирование содержания новости
	my $out;
	$modules::Security::FORM{news_id} = $modules::Security::FORM{news};
	if ($modules::Security::FORM{news_id}) {
		my @r = $modules::Core::soap->getQuery("SELECT date_format(date_fld,'%Y%m%d%H%i%s'), head_fld,
								 body_fld,news_group_id
								 FROM news_tbl
								 WHERE news_id=$modules::Security::FORM{news_id}")->paramsout;
		my @row = @{$r[0]};
		#modules::Debug::dump(\@r);
		$row[0] =~ s/(\d\d\d\d)(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)/$3.$2.$1 $4:$5:$6/;
		$row[1] = escapeHTML($row[1]);
		$out .= qq{<table class="nobord">
		<tr><td class="tl">Дата</td>
		<td class="tal"><input type="text"  name="date_fld" id="date_fld" size="22" value="$row[0]"></td></tr>
		<tr><td class="tl">Группа</td>
		<td class="tal"><select name="news_group_id"><option>-- Без группы --</option>}.news_group_downlist($row[3]).qq{</select></td></tr>
		<tr><td class="tl">Заголовок</td>
		<td class="tal"><input type="text"  name="head_fld" size="60" value="$row[1]"></td></tr>
		<tr><td class="tl">Сообщение</td>
		<td class="tal"><textarea rows="20" name="body_fld" cols="60" style="width:700px !important;height:500px">$row[2]</textarea></td></tr>};
		if (grep { 'Gallery' } @::INSTALLED) {
			#modules::Debug::notice("SELECT gallerycategory_id FROM gallery_bind_tbl WHERE table_fld='news_tbl' AND id_fld=$modules::Security::FORM{news_id}");
			my $gc = $modules::Core::soap->getQuery("SELECT gallerycategory_id FROM gallery_bind_tbl WHERE table_fld='news_tbl' AND id_fld=$modules::Security::FORM{news_id}")->result;
			$out .= qq{<tr><td class="tl">Рубрика галереи</td>
		<td class="tal"><select name="gallerycategory_id"><option>-- Нет --</option>}.category_downlist($gc).qq{</select></td></tr>}
		}
		$out .= qq{<tr><td>&nbsp;</td>
		<td class="tar"><input type="Image" src="/img/but/change1.gif" title="Изменить" class="but" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)" onclick="return check_news('period')"></td>
		<input type="hidden" name="act" value="edit_news">
		<input type="hidden" name="news_id" value="$modules::Security::FORM{news_id}">
		<input type="hidden" name="returnact" value="edit_news"></tr></table>};
	}
	return $out
	# if ($modules::Security::FORM{news_id})
} # news_edit

sub news_pix_list {
	my $out;
	$out .= qq{<h3>Добавить картинку</h3>
	<form method="POST" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl" enctype="multipart/form-data">
	<input type="hidden" name="upload" value="url_fld">
	<table class="tab_nobord">
		<tr>
			<td class="tl">Файл</td><td class="tal"><input type="file" name="url_fld" size="30"></td>
		</tr>
		<tr>
			<td class="tl">ALT</td><td class="tal"><input type="text" name="alt_fld" size="30"></td>
		</tr>
		<tr>
			<td class="tl"><label for="m">Главная</label></td><td class="tal"><input type="checkbox" id="m" name="main_fld" value="1"></td>
		</tr>
		<tr>
			<td class="tl">Расположение</td><td class="tal"><select name="valign_fld"><option value="top">Над новостью</option><option value="bottom">Под новостью</option></select></td>
		</tr>
		<tr>
			<td class="tl">Выравнивание</td><td class="tal"><select name="align_fld"><option value="">По умолчанию</option><option value="left">Влево</option><option value="center">По центру</option><option value="right">Вправо</option></select></td>
		</tr>
		<tr>
			<td>&nbsp;</td><td class="tal"><input type="Image" src="/img/but/add1.gif" title="Добавить"  onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"></td>
		</tr>
	</table>
	<input type="hidden" name="news_id" value="$modules::Security::FORM{news}">
	<input type="hidden" name="news" value="$modules::Security::FORM{news}">
	}.logpass().returnact().qq{<input type="hidden" name="act" value="add_news_pix"></form>
	<h3><br/>Список картинок</h3>
	};
	my @r = $modules::Core::soap->getQuery("SELECT * FROM news_pix_tbl WHERE news_id=$modules::Security::FORM{news}")->paramsout;
	if (defined $r[0]->[0]) {
		my $i = 0;
		$out .= qq{<table class="tab" cellspacing="0" cellpadding="0" border="0"><tr><td>
<table class="tab2" cellspacing="0" cellpadding="0" border="0">
	<tr>
		<th>Картинка / Alt</th>
		<th>Главная?</th>
		<th>align / vAlign</th>
		<th colspan="2">&nbsp;</th>
	</tr>};
		foreach (@r) {
			$out .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{">
			<form method="POST" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl">
			<input type="hidden" name="news_pix_id" value="$_->[0]">
			<input type="hidden" name="news_id" value="$modules::Security::FORM{news}">
			<input type="hidden" name="news" value="$modules::Security::FORM{news}">
			<td class="ta"><img src="http://$modules::Security::FORM{host_fld}/news/img/$_->[5]" border="0" width="128"><br/><input type="text" name="alt_fld" value="$_->[2]"></td>
			<td class="ta"><input type="checkbox" name="main_fld" value="1"}.($_->[6]=='1'?' checked':'').qq{></td>
			<td class="tal" nowrap="nowrap"><select name="align_fld">};
			foreach my $a ((['','По умолчанию'],['left','Влево'],['right','Вправо'])) {
				$out .= qq{<option value="$a->[0]"}.(($a->[0] eq $_->[4])?" selected":"").qq{>$a->[1]</option>}
			}
			$out .= qq{</select><br/><select name="valign_fld">};
			foreach my $a ((['top','Над новостью'],['bottom','Под новостью'])) {
				$out .= qq{<option value="$a->[0]"}.(($a->[0] eq $_->[3])?" selected":"").qq{>$a->[1]</option>}
			}
			$out .= qq{</select></td>
			<td class="tal"><input type="Image" src="/img/but/apply_s1.gif" title="Изменить"  onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"></td>
			<input type="hidden" name="act" value="edit_news_pix">
			}.logpass().returnact().qq{</form>
			<form method="POST" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl">
			<input type="hidden" name="news_pix_id" value="$_->[0]">
			<input type="hidden" name="url_fld" value="$_->[5]">
			<input type="hidden" name="news_id" value="$modules::Security::FORM{news}">
			<input type="hidden" name="news" value="$modules::Security::FORM{news}">
			<td class="tal"><input type="Image" src="/img/but/delete_s1.gif" title="Удалить"  onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"></td>
			<input type="hidden" name="act" value="del_news_pix">
			}.logpass().returnact().qq{</form>
			</tr>}
		}
		$out .= qq{</table></td></tr></table>}
	} else {
		$out .= info_msg(qq{Ни одной картинки нет...})
	}
	return $out
}

sub news_group_order_drag { # Изменение порядка картинок
    my $out;
	$out .= qq{<form name="fo" method="post" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl">
			   <input type="hidden" name="move" value="">
			   <input type="hidden" name="order_fld" value="">
			   <input type="hidden" name="show" value="1">
   <p class="note"><b>Примечание:</b> чтобы поменять местами группы новостей, необходимо навести мышку на&nbsp;блок с&nbsp;названием и&nbsp;перетащить в&nbsp;нужное место. Нажать кнопку &laquo;Изменить&raquo;.</p>
   <table class="tab_gal" border="0" cellpadding="0" cellspacing="0"><tr><td>};
   my @r = $modules::Core::soap->getQuery("SELECT * FROM news_group_tbl
										   ORDER BY order_fld")->paramsout;
   $out .= qq{<ul id="gpix" class="gpic">
   };
   my $i = 1;
   foreach (@r) {
	   $out .= qq{<li id="p$i"><table class="tab" width="98%"><tr class="tr_col}.($i++ % 2 +1).qq{" id="pp$_->[0]">};
	   $out .= qq{<td class="tl"><b>$_->[1]</b></td>
	   </tr></table></li>
	   };
   }
   $out .= qq{</ul></td></tr>
   <tr><td class="tar"><input type="Image" src="/img/but/change1.gif" title="Изменить" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)" onclick="this.form.order.value=junkdrawer.serializeList(document.getElementById('gpix'));"></td></tr>
   </table>};
    return $out
}

sub rss_gen {
	my $out;
	my $rss = new XML::RSS (version => '2.0', encoding => 'cp1251');
	my $ts = localtime;
	$ts =  to_rss($ts);
	my $host = $modules::Security::FORM{host_fld};
	my $site = $modules::DBfunctions::dbh->selectrow_array("SELECT site_fld FROM site_tbl WHERE site_id=$modules::Security::FORM{site_id}");
	$rss->channel(
				title          => $site,
				link           => qq{http://$host},
				language       => 'ru',
				description    => 'Новостная лента сайта '.$site,
				copyright      => 'Copyright 2005, Method Lab',
				pubDate        => $ts,
				lastBuildDate  => $ts
    );
	my $count = get_setting('news','rss_count');
	my @r = $modules::Core::soap->getQuery("SELECT news_id, DATE_FORMAT(date_fld,'%a, %d %b %Y %T'),
										   body_fld, head_fld
										   FROM news_tbl ORDER BY date_fld DESC LIMIT $count")->paramsout;
	foreach my $n (@r) {
		my $d = $n->[2];
		#$d = substr $d,0,64;
		#$d .= (length $n->[2] > 64)?'...':'';
		$rss->add_item(
				title		=> $n->[3],
				link		=> qq{http://$host/news/index.shtml#}.$n->[0],
				pubDate		=> $n->[1].' +0300',
				description	=> $d,
		)
	}
	#modules::Debug::dump($rss->as_string);
	$modules::Core::soap->putXMLFile(['/rss.xml',$rss->as_string]);
	sub to_rss {
		my $t = shift;
		$t =~ s/^(\w+) (\w+) (\d+) (\d+:\d+:\d+) (\d+)/$1, $3 $2 $5 $4 +0300/;
		return $t
	}
}
################################################################################
################################### Actions ####################################
################################################################################

sub add_news {
	use modules::Validate;
	$modules::Security::FORM{date_fld} .= " ".$modules::Security::FORM{time_fld};
	my $err = $Validate{datetime}->();
	unless ($err) {
		$modules::Security::FORM{date_fld} =~ /(\d{1,2})\.(\d{1,2})\.(\d{2,4})(\s(\d{1,2}):(\d{1,2})(:(\d{1,2}))?)?/;
		my ($d,$m,$y,$h,$mm,$s) = ($1,$2,$3,$5,$6,$8);
		$s = 0 if $s>59;
		$modules::Security::FORM{date_fld} = sprintf "%4d-%02d-%02d %02d:%02d:%02d",$y,$m,$d,$h,$mm,$s;
		add_record("news_tbl");
		#if (_inst('Mail')) {
		#	delete @modules::Security::FORM{qw(stdate enddate)};
		#	$modules::Security::FORM{count_fld} = 1;
		#	$modules::Security::FORM{ml} = 1;
		#	$modules::Security::FORM{mailtempl_id} = 1;
		#	modules::Core::xModCall('Mail','send_news_delay','a')
		#}
	} else {
		push @{$modules::Security::ERROR{act}}, $modules::Validate::err_msg;
		return "err"
	}
} # add_news

sub edit_news {
	my ($d,$m,$y) = $modules::Security::FORM{date_fld} =~ /(\d{1,2})\.(\d{1,2})\.(\d{2,4})/;
	my ($h,$mm,$s) = (localtime)[2,1,0];
	$modules::Security::FORM{date_fld} = sprintf "%4d-%02d-%02d %02d:%02d:%02d",$y,$m,$d,$h,$mm,$s;
	edit_record("news_tbl");
	if (grep { 'Gallery' } @::INSTALLED) {
		$modules::Core::soap->doQuery("DELETE FROM gallery_bind_tbl WHERE table_fld='news_tbl' AND id_fld=$modules::Security::FORM{news_id}");
		$modules::Core::soap->doQuery("INSERT INTO gallery_bind_tbl SET table_fld='news_tbl', id_fld=$modules::Security::FORM{news_id}, gallerycategory_id=$modules::Security::FORM{gallerycategory_id}")
	}
} # edit_news

sub del_news {
	my @news = (ref $modules::Security::FORM{news} eq 'ARRAY')?@{$modules::Security::FORM{news}}:($modules::Security::FORM{news});
	foreach (@news) {
		$modules::Security::FORM{news_id} = $_;
		del_record("news_tbl")
	}
	return;
}

sub edit_news_setting { edit_record("news_settings_tbl") } # edit_news_setting

sub add_news_group { add_record("news_group_tbl"); delete $modules::Security::FORM{page_id} }

sub edit_news_group { edit_record("news_group_tbl"); delete $modules::Security::FORM{page_id} }

sub del_news_group {
	$modules::Core::soap->doQuery("DELETE FROM news_tbl WHERE news_group_fld=$modules::Security::FORM{news_group_fld}");
	del_record("news_group_tbl")
}

sub add_news_tr { add_record("news_tr_tbl") }

sub edit_news_tr { edit_record("news_tr_tbl") }

sub del_news_tr { del_record("news_tr_tbl") }

sub order_news_group {
	my @order = grep { s/^p// } split /\|/=>$modules::Security::FORM{order};
	my %o;
	@o{@order} = (1..scalar @order);
	unshift @order=>0;
	$o{'0'} = '_';
	# %o = reverse %o;
	my @r = $modules::Core::soap->getQuery("SELECT news_group_id,order_fld
							FROM news_group_tbl
							ORDER BY order_fld")->paramsout;
	my $i = 0;
	foreach (@r) {
		$modules::Core::soap->doQuery("UPDATE news_group_tbl
									  SET order_fld=".$o{$i+1}."
									  WHERE news_group_id=".$_->[0]);
		$i++;
	}
}

sub add_news_pix {
	foreach my $fld (split /,/=>$modules::Security::FORM{upload}) {
		if ($modules::Security::FORM{$fld} ne '') {
			my $fname = $modules::Security::FORM{$fld};
			$fname =~ m!^__tmp_([^,]+),(.+)$! ;
			$modules::Security::FORM{$fld} = $2;
			open(IN,"<".$modules::Settings::c{dir}{cgi}.$fname);
			binmode IN;
			my $content = join "",<IN>;
			close(IN);
			my $r = $modules::Core::soap->putFile(['/news/img/'.$modules::Security::FORM{$fld},$content]);
			if ($r->faultstring) {
				modules::Debug::dump($r->faultstring);
			}
			if ($modules::Security::FORM{main_fld}==1) {
				$modules::Core::soap->doQuery("UPDATE news_pix_tbl SET main_fld=0 WHERE news_id=$modules::Security::FORM{news_id}")
			}
			add_record("news_pix_tbl");
			unlink $modules::Settings::c{dir}{cgi}.$fname;
		}
	}
}

sub edit_news_pix {
	if ($modules::Security::FORM{main_fld}==1) {
		$modules::Core::soap->doQuery("UPDATE news_pix_tbl SET main_fld=0 WHERE news_id=$modules::Security::FORM{news_id}")
	} else {
		$modules::Security::FORM{main_fld}=0
	}
	edit_record("news_pix_tbl")
}

sub del_news_pix {
	$modules::Core::soap->unlinkFile(qq{/news/img/}.$modules::Security::FORM{url_fld});
	del_record("news_pix_tbl")
}

######## Additional Subs ########
####
####

sub adjust_number {
	my $n = shift;
	return ($n<10)?"0".$n:$n
}

1;
__END__

=head1 NAME

B<News.pm> — Модуль Новостей

=head1 SYNOPSIS

Модуль Новостей

=head1 DESCRIPTION

Модуль для работы с Новостями

=head2 news_settings_list

Таблица настроек модуля Новостей.

=over 4

=item Вызов:

C<< <!--#include virtual="news_settings_list"--> >>

=item Пример вызова:

C<< <!--#include virtual="news_settings_list"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

L<module_settings_list|::Comfunctions/"module_settings_list">.

=back

=head2 news_list

Список найденных новостей за некоторый период.

=over 4

=item Вызов:

C<< <!--#include virtual="news_list"--> >>

=item Пример вызова:

C<< <!--#include virtual="news_list"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 news_group_list

Список групп новостей для редактирования.

=over 4

=item Вызов:

C<< <!--#include virtual="news_group_list"--> >>

=item Пример вызова:

C<< <!--#include virtual="news_group_list"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 news(_group)_downlist

Выпадающий список новостей/групп новостей.

=over 4

=item Вызов:

C<< <!--#include virtual="news(_group)_downlist"--> >>

=item Пример вызова:

C<< <!--#include virtual="news(_group)_downlist"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 news_group_list

Список групп новостей для редактирования.

=over 4

=item Вызов:

C<< <!--#include virtual="news_group_list"--> >>

=item Пример вызова:

C<< <!--#include virtual="news_group_list"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 news_pix_list

Список картинок выбранной новости для редактирования.

=over 4

=item Вызов:

C<< <!--#include virtual="news_pix_list"--> >>

=item Пример вызова:

C<< <!--#include virtual="news_pix_list"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 news_edit

Редактирование содержания новости.

=over 4

=item Вызов:

C<< <!--#include virtual="news_edit"--> >>

=item Пример вызова:

C<< <!--#include virtual="news_edit"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 (add|del|edit)_news

Добавление/удаление/изменение новости.

=over 2

=item Примечания:

Напрямую не вызывается. Передаётся только через поле B<act> вызывающей HTML-формы.

=item Зависимости:

L<add_record|::Comfunctions/"add_record">, L<edit_record|::Comfunctions/"edit_record">, L<del_record|::Comfunctions/"del_record"> соответственно.

=back

=head2 (add|del|edit)_news_(group|pix)

Добавление/удаление/изменение группы/картинки новости.

=over 2

=item Примечания:

Напрямую не вызывается. Передаётся только через поле B<act> вызывающей HTML-формы.

=item Зависимости:

L<add_record|::Comfunctions/"add_record">, L<edit_record|::Comfunctions/"edit_record">, L<del_record|::Comfunctions/"del_record"> соответственно.

=back

=head2 edit_news_setting

Изменение настроек Инфо-блоков.

=over 2

=item Примечания:

Напрямую не вызывается. Передаётся только через поле B<act> вызывающей HTML-формы.

=item Зависимости:

L<edit_record|::Comfunctions/"edit_record">.

=back

=head2 adjust_number

Вставка нуля перед числом, если оно меньше 10.

=over 4

=item Вызов:

C<adjust_number($number);>

=item Пример вызова:

 adjust_number($d);

=item Примечания:

Не экспортируется.

=item Зависимости:

Нет.

=back

=head1 AUTHOR

DAY, Method Lab.

=head1 BUGS

No known ones yet. ;))

=head1 SEE ALSO

L<modules::Settings|::Settings>,
L<modules::DBfunctions|::DBfunctions>,
L<modules::ModSet|::ModSet>,
L<modules::Comfunctions|::Comfunctions>.

=head1 COPYRIGHT

E<copy> Copyright 2003, Method Lab

=cut
