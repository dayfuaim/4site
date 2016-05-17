#!/usr/bin/perl

package modules::Gallery;
use Exporter;
our @ISA=qw(Exporter);
our @EXPORT=qw(get_actions gallery_head gallery_foot gallery gallery_link gallery_link_foot timg timgtitle);
our %EXPORT_TAGS = (
					elements => [qw{gallery_cat_list category_downlist gallery_edit
								 gallery_order gallery_settings_list gallery_head
								 gallery_foot gallery gallery_cat gallery_order_drag
								 gallery_cat_order_drag category_downlist_ex
								 category_comp_downlist
								 gallery_comp_edit}],
					actions => [qw{add_gallery_cat edit_gallery_cat del_gallery_cat
								add_gallery_pix del_gallery_pix edit_gallery_pix
								edit_gallery_setting order_gallery
								add_bulk_gallery_pix order_gallery_cat
								add_gallery_comp del_gallery_comp}],
					);
our @EXPORT_OK = (get_actions, @{$EXPORT_TAGS{actions}}, @{$EXPORT_TAGS{elements}});
our $VERSION=1.9;
use strict;
use CGI;
use CGI qw(escapeHTML);
use modules::Settings;
use modules::DBfunctions;
use modules::Core;
use modules::Comfunctions qw(:DEFAULT :records :file :elements :downlist);
use modules::Page qw(:elements);
use modules::ModSet;

sub get_actions {
	return $EXPORT_TAGS{actions}
}

################################################################################
################################## Elements ####################################
################################################################################

sub category_downlist { #
	my $out;
	my $sel = shift;
	$sel = $modules::Security::FORM{gallerycategory_id} unless defined $sel;
	my @r = $modules::Core::soap->getQuery("SELECT gallerycategory_id, gallerycategory_fld,
											parent_id
											FROM gallerycategory_tbl
											WHERE compilation_fld!=1
											ORDER BY parent_id,gallerycategory_fld")->paramsout;
	# modules::Debug::dump(\@r);
	my $l = 0;
	$out .= _galcat(\@r,\@r,$l,$sel);
	return $out
} # category_downlist

sub category_comp_downlist {
	my $out;
	my $sel = shift;
	$sel = $modules::Security::FORM{gallerycategory_id} unless defined $sel;
	my @r = $modules::Core::soap->getQuery("SELECT gallerycategory_id, gallerycategory_fld,
											parent_id
											FROM gallerycategory_tbl
											WHERE compilation_fld=1
											ORDER BY gallerycategory_fld")->paramsout;
	# modules::Debug::dump(\@r);
	my $l = 0;
	$out .= _galcat(\@r,\@r,$l,$sel);
	return $out
}

sub category_downlist_ex {
	my $out;
	my $sel = shift;
	$sel = $modules::Security::FORM{parent_id} unless defined $sel;
	my @r = $modules::Core::soap->getQuery("SELECT gallerycategory_id, gallerycategory_fld, parent_id
                             FROM gallerycategory_tbl
							 WHERE compilation_fld!=1
                             ORDER BY gallerycategory_id ASC, parent_id ASC")->paramsout;
	#modules::Debug::dump(\@r);
	my @p;
	my %c;
	foreach (@r) {
		$c{$_->[0]}++ unless exists $c{$_->[0]};
		if ($c{$_->[2]}==1) {
			$c{$_->[2]}++
		}
	}
	#modules::Debug::notice(scalar @r);
	#delete @c{grep { $c{$_}==1 } keys %c};
	modules::Debug::dump(\%c);
	my @r1;
	foreach (@r) {
		push @r1=>$_ unless $c{$_->[0]}==1
	}
	modules::Debug::dump(\@r1);
	my $l = 0;
	$out .= _galcat(\@r1,\@r1,$l,$sel);
	return $out
}

sub _galcat {
	my ($r,$r1,$l,$sel) = @_;
	my $out;
	foreach my $c (@{$r1}) {
		$out .= qq{<option value="$c->[0]"}.(($sel==$c->[0])?" selected":"").qq{>}.('&nbsp;&nbsp;&nbsp;' x $l).qq{$c->[1]</option>};
		my @r1 = grep { $_->[2]==$c->[0] } @{$r};
		next unless scalar @r1;
		@{$r} = grep { $_->[2]!=$c->[0] } @{$r};
		$out .= _galcat($r,\@r1,$l+1,$sel);
	}
	return $out
}

sub gallery_cat_list { # список разделов Галереи
    my @r = $modules::Core::soap->getQuery("SELECT gallerycategory_id, gallerycategory_fld, parent_id
                             FROM gallerycategory_tbl
                             ORDER BY gallerycategory_fld ASC, parent_id ASC")->paramsout;
	my %h;
	foreach (@r) {
		$h{$_->[0]} = [$_->[1],$_->[2]]
	}
 	#modules::Debug::dump(\%h); return;
	my $out = _gc_list(\%h);
	return $out
} # gallery_cat_list

sub _gc_list {
	my ($hr,$parent,$l,$i,$ch) = @_;
	$parent ||= 0;
	$l ||= 0;
	$i ||= 1;
	my @r = grep { $hr->{$_}[1]==$parent } keys %{$hr};
	return undef unless scalar @r;
    my $logpass = logpass();
    my $out;
	my $spacer = qq{<img src="/img/1pix.gif" width="17" height="1" border="0" align="absmiddle">};
	foreach (sort { $hr->{$a}[0] cmp $hr->{$b}[0] } @r) {
		my $sw;
		my $c = $_;
		my $chld = scalar grep { $hr->{$_}[1]==$c } keys %{$hr};
		$sw = $chld?qq{<img src="/img/4site/menu/close.gif" border="0" align="absmiddle" onclick="swGC(this,$_)" style="cursor: pointer">}:$spacer;
		$out .= qq{<form method="POST" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl" name="gc$_">
		<tr class="tr_col}.($i++ % 2 +1).($ch?qq{ $ch}:'').qq{" id="tgc$_" title="p$parent">

		<td class="tl">$sw}.($spacer x $l).qq{<b><a href="#" onclick="submit('gc$_')" class="link">$hr->{$_}[0]</a></b></td><td class="tr">[<b>$_</b>]</td>

		</tr><input type="hidden" name="gallerycategory_id" value="$_"><input type="hidden" name="returnact" value="edit_gallery_cat">$logpass</form>};
		$out .= _gc_list($hr,$_,$l+1,$i,$chld?'cl':'op');
	}
   return $out
}

sub gallery_cat {
	my $out;
	my @r = $modules::Core::soap->getQueryHash("SELECT * FROM gallerycategory_tbl WHERE gallerycategory_id=$modules::Security::FORM{gallerycategory_id}")->paramsout;
	my $r = $r[0];
	$modules::Security::FORM{page_id} = $r->{page_id};
	$out .= qq{<form method="post" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl" name="gallery_cat_edit">
	<input type="hidden" name="gallerycategory_id" value="$r->{gallerycategory_id}">
<table class="tab_nobord">
<tr><td class="tl">Название рубрики</td>
<td class="tal" colspan="2"><input type="text"  name="gallerycategory_fld" size="30" value="$r->{gallerycategory_fld}" onchange="checkEmpty(this)" onkeypress="checkEmpty(this)"></td></tr>
	<tr>
		<td class="tl">Родительская Рубрика</td>
		<td class="tal" colspan="2"><select name="parent_id"><option>-- нет --</option>}.category_downlist($r->{parent_id}).qq{</select></td>
	</tr>
<tr><td class="tl" title="Рубрика, содержащая только ссылки на картинки из разных других рубрик"><label for="cmp">Сборная рубрика?</label></td>
<td class="tal"><input type="checkbox" name="compilation_fld" value="1"}.($r->{compilation_fld}?' checked':'').qq{ id="cmp"></td></tr>
<tr><td class="tl"><label for="shw">Показывать в Галерее?</label></td>
<td class="tal" colspan="2"><input type="checkbox" id="shw" name="enabled_fld" value="1"}.($r->{enabled_fld}?" checked":"").qq{></td></tr>
<tr><td class="tl">Привязка к странице</td>
<td class="tal" colspan="2"><select name="page_id"><option value="">-- нет привязки --</option>}.page_downlist().qq{</select></td></tr>
<tr><td class="tl">Кол-во столбцов</td>
<td class="tal"><input type="text"  name="cols_fld" size="4" value="$r->{cols_fld}"></td></tr>
<tr><td class="tl">Макс. количество строк</td>
<td class="tal"><input type="text"  name="rows_fld" size="4" value="$r->{rows_fld}"></td></tr>
<tr><td>&nbsp;</td><td class="tal" width="20"><input type="Image" src="/img/but/change1.gif" title="Изменить" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)" id="but"><input type="hidden" name="act" value="edit_gallery_cat"><input type="hidden" name="returnact" value="gallery_cat_list">}.logpass().qq{</form>
</td><td class="tal"><form method="post" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl" name="gallery_cat_del"><input type="hidden" name="returnact" value="gallery_cat_list">
<input type="Image" src="/img/but/delete1.gif" title="Удалить" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)" onclick="return confirm('Вы действительно хотите\\nудалить эту рубрику?')"><input type="hidden" name="gallerycategory_id" value="$r->{gallerycategory_id}"><input type="hidden" name="act" value="del_gallery_cat">}.logpass().qq{</form></td>
</tr></table>
};
	return $out
}

sub gallery_comp_edit {
    my $out;
	return unless $::SHOW;
	$out .= qq{<table border="0" cellspacing="0" cellpadding="0"><tr><td align="center" valign="top">};
	my @r = $modules::Core::soap->getQuery("SELECT gcc.gallery_id,small_url_fld,
											descr_fld,gallerycat_comp_id
											FROM `gallerycat_comp_tbl` as gcc
												LEFT JOIN gallery_tbl as g
												ON (g.gallery_id=gcc.gallery_id)
											WHERE gcc.gallerycategory_id=$modules::Security::FORM{gallerycategory_id}")->paramsout;
	my @g;
	if (scalar @r) {
		$out .= start_table().head_table('Миниатюра и Описание',['&nbsp;',2]);
		my $i = 1;
		foreach (@r) {
			push @g=>$_->[0];
			$out .= qq{<form method="post" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl" name="gc$_->[3]"><tr class="tr_col}.($i++ % 2 +1).qq{">
			<td class="tl"><img src="http://}.$modules::Security::session->param('host_fld').qq{/img/gallery$_->[1]" width="37" border="0" vspace="2" align="absmiddle"> $_->[2]</td>
			<td class="tal"><input type="Image" src="/img/but/delete_s1.gif" title="Удалить" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"><input type="hidden" name="gallerycat_comp_id" value="$_->[3]"></td>
			</tr><input type="hidden" name="gallerycategory_id" value="$modules::Security::FORM{gallerycategory_id}"><input type="hidden" name="gc_id" value="$modules::Security::FORM{gc_id}"><input type="hidden" name="show" value="1"><input type="hidden" name="act" value="del_gallery_comp">}.logpass().returnact().qq{</form>}
		}
		$out .= end_table()
	} else {
		$out .= info_msg(qq{В данной рубрике нет ни одной картинки.})
	}
	$out .= qq{</td>
	<td width="10">&nbsp;</td>
	<td valign="top">};
	$out .= start_table().head_table('&nbsp;','Миниатюра и Описание');
	$out .= qq{<form method="post" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl"><input type="hidden" name="gallerycategory_id" value="$modules::Security::FORM{gallerycategory_id}"><input type="hidden" name="show" value="1"><tr class="tr_col4"><td class="tal" colspan="2"><select name="gc_id" onchange="if(this.selectedIndex!=0){this.form.submit()}"><option value=""></option>}.category_downlist($modules::Security::FORM{gc_id}).qq{</select></td></tr>}.logpass().returnact().qq{</form>};
	if ($modules::Security::FORM{gc_id}) {
		my @r1 = $modules::Core::soap->getQuery("SELECT * FROM gallery_tbl WHERE gallerycategory_id=$modules::Security::FORM{gc_id} ORDER BY order_fld")->paramsout;
		my $i = 1;
		my $op = 30;
		$out .= qq{<form method="post" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl"><input type="hidden" name="gallerycategory_id" value="$modules::Security::FORM{gallerycategory_id}"><input type="hidden" name="gc_id" value="$modules::Security::FORM{gc_id}"><input type="hidden" name="show" value="1">};
		foreach my $p (@r1) {
			my ($is) = grep {$p->[0]==$_} @g;
			$out .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{">
			<td class="tal">}.($is?'':qq{<input type="checkbox" name="gallery_id" value="$p->[0]">}).qq{</td>
			<td class="tl"><div style="width:100%}.($is?sprintf qq{; opacity: %f; -moz-opacity: %f; -khtml-opacity: %f; filter: alpha(opacity=%d);},$op/100,$op/100,$op/100,$op:'').qq{"><img src="http://}.$modules::Security::session->param('host_fld').qq{/img/gallery$p->[3]" width="37" border="0" vspace="2" align="absmiddle"> $p->[5]</div></td></tr>}
		}
		$out .= qq{<tr class="tr_col3"><td class="tar" colspan="2"><input type="Image" src="/img/but/add1.gif" title="Добавить" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"></td></tr><input type="hidden" name="act" value="add_gallery_comp">}.logpass().returnact().qq{</form>}
	}
	$out .= end_table();
	$out .= qq{</td>
	</tr></table>};
    return $out
}

sub gallery_edit { # Редактирование картинок
    my $out;
    if ($modules::Security::FORM{show}) {
		my $limit = $modules::Security::FORM{_count};
		$limit ||= $modules::Security::FORM{limit};
		$limit ||= 4;
		my $min = $modules::Security::FORM{min} || 0;
		my $all = $modules::Core::soap->getQuery("SELECT COUNT(*) FROM gallery_tbl
							   WHERE gallerycategory_id=$modules::Security::FORM{gallerycategory_id}")->result;
		if ($all) {
			$out .= qq{<table cellspacing="0" cellpadding="0"><tr><td align="center">};
			$out .= limit_rows_set("SELECT * FROM gallery_tbl
							   WHERE gallerycategory_id=$modules::Security::FORM{gallerycategory_id}
							   ORDER BY gallery_id",$limit,
							   qq{<input type="hidden" name="gallerycategory_id" value="$modules::Security::FORM{gallerycategory_id}"><input type="hidden" name="show" value="1"><input type="hidden" name="limit" value="$limit">});
			my @r = $modules::Core::soap->getQuery("SELECT *
								   FROM gallery_tbl
								   WHERE gallerycategory_id=$modules::Security::FORM{gallerycategory_id}
								   ORDER BY gallery_id
								   LIMIT $min,$limit")->paramsout;
			$out .= start_table().head_table('URL (большая картинка/миниатюра),<br/>Описание,<br/>Комментарий','Миниатюра',['&nbsp;',2]);
			my $i = 1;
			foreach (@r) {
				$out .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{">
				   <form method="post" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl" name="p$_->[0]">}.logpass.qq{
				   <td class="tal" valign="top"><span class="tl">Бол.:</span><input type="text" name="big_url_fld" size="30" value="$_->[2]" >&nbsp;<a href="#" onclick="javascript:fs_open('/img/gallery','gif|jpg|png','p$_->[0]','big_url_fld'); return false;"><img src="/img/4site/folder_open.gif" border="0" align="absmiddle"></a><br/>&nbsp;<span class="tl">мин.:</span><input type="text" name="small_url_fld" size="30" value="$_->[3]" class="input_txt">&nbsp;<a href="#" onclick="javascript:fs_open('/img/gallery','gif|jpg|png','p$_->[0]','small_url_fld'); return false;"><img src="/img/4site/folder_open.gif" border="0" align="absmiddle"></a><br/>
								   <textarea cols="38" rows="5" name="descr_fld">$_->[5]</textarea><br/>
								   <textarea cols="38" rows="3" name="comment_fld">}.escapeHTML($_->[6]).qq{</textarea></td>
				   <td class="ta"><img src="http://}.$modules::Security::session->param('host_fld').qq{/img/gallery$_->[3]" border="0" hspace="2" vspace="2"></td>
				   <td class="tal">
					   <input type="hidden" name="show" value="1">
					   <input type="hidden" name="act" value="edit_gallery_pix">
					   <input type="hidden" name="returnact" value="gallery_pix">
					   <input type="hidden" name="gallery_id" value="$_->[0]">
					   <input type="hidden" name="gallerycategory_id" value="$modules::Security::FORM{gallerycategory_id}">
					   <input type="hidden" name="min" value="$min">
					   <input type="hidden" name="limit" value="$limit">
					   <input type="Image" src="/img/but/apply_s1.gif" title="Изменить" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)">
				   </td>
				   </form>
				   <form method="post" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl">}.&logpass().qq{
				   <td class="ta">
					   <input type="hidden" name="show" value="1">
					   <input type="hidden" name="act" value="del_gallery_pix">
					   <input type="hidden" name="returnact" value="gallery_pix">
					   <input type="hidden" name="gallery_id" value="$_->[0]">
					   <input type="hidden" name="gallerycategory_id" value="$modules::Security::FORM{gallerycategory_id}">
					   <input type="hidden" name="min" value="$min">
					   <input type="hidden" name="limit" value="$limit">
					   <input type="Image" src="/img/but/delete_s1.gif" title="Удалить катринку" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)">
				   </td>
				   </form>
			   </tr>
			   };
			}
			$out .= qq{</table></td></tr></table></td></tr></table>}
		} else {
			$out .= info_msg(qq{В данной рубрике нет ни одной картинки.})
		}
    }
    return $out
} # gallery_edit

sub gallery_cat_order_drag {
    my $out;
	return unless $modules::Security::FORM{show};
	$out .= qq{<input type="hidden" name="parent_id" value="$modules::Security::FORM{parent_id}">
	<p class="note"><b>Примечание:</b> чтобы поменять местами рубрики, необходимо навести мышку на&nbsp;блок с&nbsp;рубрикой и&nbsp;перетащить в&nbsp;нужное место. Нажать кнопку &laquo;Изменить&raquo;.</p>
	<table class="tab_gal" border="0" cellpadding="0" cellspacing="0"><tr><td>};
	my @r = $modules::Core::soap->getQuery("SELECT * FROM gallerycategory_tbl WHERE parent_id=$modules::Security::FORM{parent_id} ORDER BY order_fld")->paramsout;
	$out .= qq{<ul id="gpix" class="gpic">
	};
	my $i = 1;
	foreach (@r) {
	   $out .= qq{<li id="gpix_$i"><table class="tab" width="98%"><tr class="tr_col}.($i++ % 2 +1).qq{" id="pp$_->[0]">};
	   $out .= qq{<td class="tl" valign="middle" nowrap="nowrap" height="22"><b>$_->[1]</b></td>
	   </tr></table></li>
	   };
	}
	$out .= qq{</ul></td></tr>
	<tr><td class="tar"><input type="Image" src="/img/but/change1.gif" title="Изменить" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)" onclick="this.form.order.value=Sortable.serialize('gpix');"></td></tr>
	</table>};
    return $out
}

sub gallery_order_drag { # Изменение порядка картинок
    my $out;
    if ( $modules::Security::FORM{show} ) {
         $out .= qq{<form name="fo" method="post" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl">
                    <input type="hidden" name="move" value="">
                    <input type="hidden" name="order_fld" value="">
                    <input type="hidden" name="show" value="1">
                    <input type="hidden" name="gallerycategory_id" value="$modules::Security::FORM{gallerycategory_id}">
		<p class="note"><b>Примечание:</b> чтобы поменять местами миниатюры, необходимо навести мышку на&nbsp;блок с&nbsp;миниатюрой и&nbsp;перетащить в&nbsp;нужное место. Нажать кнопку &laquo;Изменить&raquo;.</p>
		<table class="tab_gal" border="0" cellpadding="0" cellspacing="0"><tr><td>};
        my @r = $modules::Core::soap->getQuery("SELECT * FROM gallery_tbl
        						WHERE gallerycategory_id=$modules::Security::FORM{gallerycategory_id}
        						ORDER BY order_fld")->paramsout;
		$out .= qq{<ul id="gpix" class="gpic">
		};
		my $i = 1;
    	foreach (@r) {
            $out .= qq{<li id="gpix_$i"><table class="tab" width="98%"><tr class="tr_col}.($i++ % 2 +1).qq{" id="pp$_->[0]">};
			my $title = qq{$_->[2]<br/>$_->[3]};
			$title = qq{<b>$_->[5]</b><br/>}.$title if $_->[5];
            $out .= qq{<td class="tal" width="64"><img src="http://}.$modules::Security::session->param('host_fld').qq{/img/gallery$_->[3]" width="64" border="1" hspace="2" vspace="2"></td><td class="tl" valign="middle" nowrap="nowrap">$title</td>
            </tr></table></li>
            };
        }
        $out .= qq{</ul></td></tr>
		<tr><td class="tar"><input type="Image" src="/img/but/change1.gif" title="Изменить" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)" onclick="this.form.order.value=Sortable.serialize('gpix');"></td></tr>
		</table>};
    }
    return $out
}

sub gallery_settings_list { module_settings_list("gallery") } # gallery_settings_list

################################################################################
################################### Actions ####################################
################################################################################

sub order_gallery {
	my @order = grep { s/^gpix\[\]=// } split /&/=>$modules::Security::FORM{order};
	my %o;
	@o{@order} = (1..scalar @order);
	unshift @order=>0;
	$o{'0'} = '_';
	# %o = reverse %o;
	my @r = $modules::Core::soap->getQuery("SELECT gallery_id,order_fld
							FROM gallery_tbl
							WHERE gallerycategory_id=$modules::Security::FORM{gallerycategory_id}
							ORDER BY order_fld")->paramsout;
	my $i = 0;
	foreach (@r) {
		$modules::Core::soap->doQuery("UPDATE gallery_tbl
									  SET order_fld=".$o{$i+1}."
									  WHERE gallery_id=".$_->[0]);
		$i++;
	}
}

sub order_gallery_cat {
	my @order = grep { s/^gpix\[\]=// } split /&/=>$modules::Security::FORM{order};
	my %o;
	@o{@order} = (1..scalar @order);
	unshift @order=>0;
	$o{'0'} = '_';
	# %o = reverse %o;
	my @r = $modules::Core::soap->getQuery("SELECT gallerycategory_id,order_fld
							FROM gallerycategory_tbl
							WHERE parent_id=$modules::Security::FORM{parent_id}
							ORDER BY order_fld")->paramsout;
	my $i = 0;
	foreach (@r) {
		$modules::Core::soap->doQuery("UPDATE gallerycategory_tbl
									  SET order_fld=".$o{$i+1}."
									  WHERE parent_id=$modules::Security::FORM{parent_id}
									  AND gallerycategory_id=".$_->[0]);
		$i++;
	}
}

sub add_gallery_cat {
	$modules::Security::FORM{enabled_fld} ||= '0';
	add_record("gallerycategory_tbl")
} # add_gallery_cat

sub edit_gallery_cat {
	$modules::Security::FORM{enabled_fld} ||= '0';
	$modules::Security::FORM{compilation_fld} ||= '0';
	if ($modules::Security::FORM{gallerycategory_id}==$modules::Security::FORM{parent_id}) {
		$modules::Validate::err_msg = qq{Вы пытаетесь сделать категорию собственной подкатегорией!<br/>Исправьте, пожалуйста.};
		$modules::Validate::error = 1;
		return
	}
	edit_record("gallerycategory_tbl")
} # edit_gallery_cat

sub add_gallery_comp {
	my @g = get_array($modules::Security::FORM{gallery_id});
	foreach my $g (@g) {
		my $sql = qq{INSERT INTO gallerycat_comp_tbl (gallerycategory_id,gallery_id) VALUES ($modules::Security::FORM{gallerycategory_id},$g)};
		$modules::Core::soap->doQuery($sql)
	}
}

sub del_gallery_comp {
	$modules::Core::soap->doQuery(qq{DELETE FROM gallerycat_comp_tbl WHERE gallerycat_comp_id=$modules::Security::FORM{gallerycat_comp_id}})
}

sub del_gallery_cat {
	$modules::Core::soap->doQuery("DELETE FROM gallery_tbl WHERE gallerycategory_id=$modules::Security::FORM{gallerycategory_id}");
	my $parent = $modules::Core::soap->getQuery("SELECT parent_id
										   FROM gallerycategory_tbl
										   WHERE gallerycategory_id=$modules::Security::FORM{gallerycategory_id}")->result;
	my @r = $modules::Core::soap->getQuery("SELECT gallerycategory_id
										   FROM gallerycategory_tbl
										   WHERE parent_id=$modules::Security::FORM{gallerycategory_id}")->paramsout;
	foreach (@r) {
		$modules::Core::soap->doQuery("UPDATE gallerycategory_tbl SET parent_id=$parent WHERE gallerycategory_id=$_->[0]");
	}
	del_record("gallerycategory_tbl")
} # del_gallery_cat

sub add_gallery_pix { # Создание картинки раздела
	my $q = new CGI;
	my $cat = $modules::Security::FORM{gallerycategory_id};
	my $folder = $modules::Security::FORM{folder_fld} || "";
	$folder =~ s/^\s+//;
	$folder =~ s/\s+$//;
	$folder = _dec2tr($folder);
	foreach my $fld (split /,/=>$modules::Security::FORM{upload}) {
		if ($modules::Security::FORM{$fld} ne '') {
			my $fname = $modules::Security::FORM{$fld};
			$fname =~ m!^__tmp_([^,]+),(.+)$! ;
			my $_n = $2;
			$modules::Security::FORM{$fld} = (($folder)?"/".$folder."/":"/").(($fld =~ /^small/)?'small/':'').$_n;
			$modules::Security::FORM{$fld} =~ s!//!/!g;
			my $ex = $modules::Core::soap->getQuery("SELECT gallerycategory_id
													FROM gallery_tbl
													WHERE $fld='$modules::Security::FORM{$fld}'
													AND gallerycategory_id=$cat")->result;
			if ($ex==$cat) {
				push @{$modules::Security::ERROR{act}}=>qq{В данной рубрике картинка <nobr class="">'$modules::Security::FORM{$fld}'</nobr> уже есть.};
				return "err"
			}

			open(IN,"<".$modules::Settings::c{dir}{cgi}.$fname);
			binmode IN;
			my $content = join "",<IN>;
			close(IN);
			my $r = $modules::Core::soap->putFile(['/img/gallery'.$modules::Security::FORM{$fld},$content]);
			if ($r->faultstring) {
				modules::Debug::dump($r->faultstring);
			}
			unlink $modules::Settings::c{dir}{cgi}.$fname;
		} elsif ($modules::Security::FORM{$fld.'1'} ne '') {
			$modules::Security::FORM{$fld} = $modules::Security::FORM{$fld.'1'};
			$modules::Security::FORM{$fld} =~ s!^/img/gallery!!;
			$modules::Security::FORM{$fld} = (($folder)?"/".$folder:"").$modules::Security::FORM{$fld};
		} else {
			if ($fld ne 'big_url_fld') {
				push @{$modules::Security::ERROR{act}}=>qq{Введите данные в поле '$fld'!};
				return "err"
			}
		}
	}
	$modules::Security::FORM{order_fld} = $modules::Core::soap->getQuery("SELECT max(order_fld)+1
                                                                FROM gallery_tbl
                                                                WHERE gallerycategory_id=$modules::Security::FORM{gallerycategory_id}")->result || 1;
	$modules::Security::FORM{descr_fld} =~ s/'/&#39;/;
	#modules::Debug::dump(\%modules::Security::FORM); return;
	add_record("gallery_tbl");
} # add_gallery_pix

sub add_bulk_gallery_pix {
	my $folder = $modules::Security::FORM{folder_fld} || "";
	my $config = $modules::Security::FORM{config};
	#modules::Debug::notice($config); return;
	return unless $config;
	$folder =~ s/^\s+//;
	$folder =~ s/\s+$//;
	$folder = _dec2tr($folder);
	my %files;
	my @f;
	foreach (split /\r?\n/=>$config) {
		chomp;
		my ($fn,$descr) = (undef,'');
		($fn,$descr) = /([^ ]+)(?:\s+(.+))?$/;
		if (!$modules::Security::FORM{wonam}) {
			$descr =~ s/'/&#39;/
		}
		$files{qq{/$fn}} = $descr;
		push @f=>qq{/$fn}
	}
	#modules::Debug::dump(\@f);
	#modules::Debug::dump(\%files);
	#return;
	my %found;
	my @info;
	foreach my $_f (@f) {
		#$_f =~ s!//!/!g;
		#modules::Debug::notice('/img/gallery/'.$folder.$_f,'',1);
		my $path = '/img/gallery/'.($folder?qq{$folder}:'').$_f;
		$path =~ s!//!/!g;
		my $r = $modules::Core::soap->getStat($path);
		unless (scalar $r->paramsout) {
			s!^/!!;
			if ($modules::Security::FORM{wobig}) {
				push @info, qq{$_f: <b>Картинка не найдена</b>}
			} else {
				push @{$modules::Security::ERROR{act}}, qq{$_f: <b>Картинка не найдена</b>}
			}
		} else {
			$found{$_f}++
		}
		#modules::Debug::notice('/img/gallery/'.$folder.'/small'.$_f,'',1);
		$path = '/img/gallery/'.($folder?qq{$folder}:'').'/small'.$_f;
		$path =~ s!//!/!g;
		$r = $modules::Core::soap->getStat($path);
		unless (scalar $r->paramsout) {
			s!^/!!;
			push @{$modules::Security::ERROR{act}}, qq{$_f: <b>Миниатюра не найдена</b>};
		} else {
			$found{'/small'.$_f}++
		}
		#modules::Debug::dump(\%found,'found'); return;
		my $ex;
		unless ($modules::Security::FORM{wobig}) {
			#modules::Debug::notice("SELECT gallerycategory_id
			#										FROM gallery_tbl
			#										WHERE big_url_fld='/".$folder.$_f."'
			#										AND gallerycategory_id=$modules::Security::FORM{gallerycategory_id}");
			$ex = $modules::Core::soap->getQuery("SELECT gallerycategory_id
													FROM gallery_tbl
													WHERE big_url_fld='/".$folder.$_f."'
													AND gallerycategory_id=$modules::Security::FORM{gallerycategory_id}")->result;
			if ($ex==$modules::Security::FORM{gallerycategory_id}) {
				push @{$modules::Security::ERROR{act}}, qq{$_f: Картинка уже есть в данной рубрике};
			}
		}
		#modules::Debug::notice("SELECT gallerycategory_id
		#										FROM gallery_tbl
		#										WHERE small_url_fld='/".$folder."/small".$_f."'
		#										AND gallerycategory_id=$modules::Security::FORM{gallerycategory_id}");
		$ex = $modules::Core::soap->getQuery("SELECT gallerycategory_id
												FROM gallery_tbl
												WHERE small_url_fld='/".$folder."/small".$_f."'
												AND gallerycategory_id=$modules::Security::FORM{gallerycategory_id}")->result;
		if ($ex==$modules::Security::FORM{gallerycategory_id}) {
			push @{$modules::Security::ERROR{act}}, qq{$_f: Миниатюра уже есть в данной рубрике};
		}
	}

	if (defined $modules::Security::ERROR{act}) {
		return "err"
	} else {
		print info_msg(join '<br/>'=>@info) if scalar @info;
		my $order = $modules::Core::soap->getQuery("SELECT MAX(order_fld) FROM gallery_tbl WHERE gallerycategory_id=$modules::Security::FORM{gallerycategory_id}")->result || 0;
		foreach my $_f (@f) {
			next unless $found{'/small'.$_f};
			next if (!$found{$_f} and !$modules::Security::FORM{wobig});
			$order++;
			my $sql = "INSERT INTO
								gallery_tbl (gallerycategory_id,big_url_fld,small_url_fld,order_fld,descr_fld)
								VALUES ($modules::Security::FORM{gallerycategory_id},
									'".($found{$_f}?"/$folder$_f":'')."',
									'/$folder/small$_f',
									$order,
									'".$files{$_f}."'
								)";
			#modules::Debug::notice($sql);
			$modules::Core::soap->doQuery($sql);
		}
	}
}

sub del_gallery_pix { # Удаление картинки раздела
	my $q = new CGI;
	$modules::Security::FORM{big_url_fld} =~ s!^/img/gallery!!;
	$modules::Security::FORM{small_url_fld} =~ s!^/img/gallery!!;
	my @r = $modules::Core::soap->getQuery("SELECT big_url_fld, small_url_fld FROM gallery_tbl WHERE gallery_id=$modules::Security::FORM{gallery_id}")->paramsout;
	my ($big_url,$small_url) = @{$r[0]};
	my $cbig = $modules::Core::soap->getQuery("SELECT COUNT(gallerycategory_id)
										FROM `gallery_tbl`
										WHERE big_url_fld='$big_url'")->result;
	my $csml = $modules::Core::soap->getQuery("SELECT COUNT(gallerycategory_id)
										FROM `gallery_tbl`
										WHERE small_url_fld='$small_url'")->result;
	if ($cbig==1) {
		$modules::Core::soap->unlinkFile('/img/gallery'.$big_url);
	}
	if ($csml==1) {
		$modules::Core::soap->unlinkFile('/img/gallery'.$small_url);
	}
	del_record("gallery_tbl");
	$q->param('min',0);
} # del_gallery_pix

sub edit_gallery_pix { # Изменение картинки раздела
	#modules::Debug::dump(\%modules::Security::FORM);
	$modules::Security::FORM{comment_fld} =~ s/\x88/&euro;/g;
	$modules::Security::FORM{descr_fld} =~ s/'/&#39;/;
	$modules::Security::FORM{big_url_fld} =~ s!^/img/gallery!!;
	$modules::Security::FORM{big_url_fld} =~ s!//!/!g;
	$modules::Security::FORM{small_url_fld} =~ s!^/img/gallery!!;
	$modules::Security::FORM{small_url_fld} =~ s!//!/!g;
	edit_record("gallery_tbl")
} # edit_gallery_pix

sub edit_gallery_setting { edit_record("gallery_settings_tbl") } # edit_gallery_setting

sub gallery_settings_list { module_settings_list("gallery") } # gallery_settings_list

sub _dec2tr {
	use locale;
	my $str = shift;
	my %map = qw(	щ shh
					ч ch  ш sh  ё jo  ж zh  й jj  х kh  э eh  ю ju  я ja
					а a   б b   в v   г g   д d   е e   з z   и i   к k   л l   м m   н n
					о o   п p   р r   с s   т t   у u   ф f   ц c   ъ "  ы y   ь '
					Щ SHH
					Ч CH  Ш SH  Ё JO  Ж ZH  Й JJ  Х KH  Э EH  Ю JU  Я JA
					А A   Б B   В V   Г G   Д D   Е E   З Z   И I   К K   Л L   М M   Н N
					О O   П P   Р R   С S   Т T   У U   Ф F   Ц C   Ъ "  Ы Y   Ь '
				);
	my (%ru_map, %t_map);
	foreach my $k ( keys %map ) {
		$ru_map{ $k } = $map{ $k };
		$t_map{ $map{ $k } } = $k;
	}
	my $out;
	foreach my $c (split //=>$str) {
		$out .= $ru_map{$c} || $c
	}
	$out =~ tr/+)(*&^%$#@!:;"'?><,/_/;
	return $out
}

1;
__END__

=head1 NAME

B<Gallery.pm> — Модуль Галереи

=head1 SYNOPSIS

Модуль Галереи

=head1 DESCRIPTION

Модуль для работы с Галереей

=head2 category_downlist

Выпадающий список разделов Галереи.

=over 4

=item Вызов:

C<< <!--#include virtual="category_downlist"--> >>

=item Пример вызова:

C<< <!--#include virtual="category_downlist"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 gallery_cat_list

Форма редактирования разделов Галереи. Возможна привязка раздела (в будущем разделI<ов>) к конкретной странице сайта с выключением (по выбору) из показа на основной странице Галереи.

=over 4

=item Вызов:

C<< <!--#include virtual="gallery_cat_list"--> >>

=item Пример вызова:

C<< <!--#include virtual="gallery_cat_list"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

L<downlist_sel|::Comfunctions/"downlist_sel">.

=back

=head2 gallery_edit

Форма (список с прокруткой) редактирования картинок Галереи.

=over 4

=item Вызов:

C<< <!--#include virtual="gallery_edit"--> >>

=item Пример вызова:

C<< <!--#include virtual="gallery_edit"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

L<limit_rows_set|::Comfunctions/"limit_rows_set">.

=back

=head2 gallery_order

Форма изменения порядка картинок в разделе Галереи.

=over 4

=item Вызов:

C<< <!--#include virtual="gallery_order"--> >>

=item Пример вызова:

C<< <!--#include virtual="gallery_order"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 gallery_settings_list

Таблица настроек модуля Галерея.

=over 4

=item Вызов:

C<< <!--#include virtual="gallery_settings_list"--> >>

=item Пример вызова:

C<< <!--#include virtual="gallery_settings_list"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

L<module_settings_list|::Comfunctions/"module_settings_list">.

=back

=head2 (add|del|edit)_gallery_pix

Добавление/удаление/изменение картинки в Галерею.

=over 2

=item Примечания:

Напрямую не вызывается. Передаётся только через поле B<act> вызывающей HTML-формы.

=item Зависимости:

L<add_record|"add_record">, L<edit_record|"edit_record">, L<del_record|"del_record"> соответственно.

=back

=head2 (add|del|edit)_gallery_cat

Добавление/удаление/изменение категории картинок в Галерею.

=over 2

=item Примечания:

Напрямую не вызывается. Передаётся только через поле B<act> вызывающей HTML-формы.

=item Зависимости:

L<add_record|::Comfunctions/"add_record">, L<edit_record|::Comfunctions/"edit_record">, L<del_record|::Comfunctions/"del_record"> соответственно.

=back

=head2 edit_gallery_setting

Изменение настроек Галереи.

=over 2

=item Примечания:

Напрямую не вызывается. Передаётся только через поле B<act> вызывающей HTML-формы.

=item Зависимости:

L<edit_record|::Comfunctions/"edit_record">.

=back

=head1 AUTHOR

DAY, Method Lab.

=head1 BUGS

No known ones yet. ;))

=head1 SEE ALSO

=head1 COPYRIGHT

E<copy> Copyright 2003, Method Lab

=cut
