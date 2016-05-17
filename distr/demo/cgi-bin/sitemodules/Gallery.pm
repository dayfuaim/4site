#!/usr/bin/perl
#
#

# Модуль обработки Галереи
package sitemodules::Gallery;
use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
our @ISA=qw(Exporter);
our @EXPORT=qw(gallery_head gallery_foot gallery gallery_link gallery_link_foot timg timgtitle gallery_link_head gogallery galleryEx count_all count_cur gal_head cat_list imgurl fulllabel);
our @EXPORT_OK = qw();
our %EXPORT_TAGS = ();
our $VERSION=1.90;
use strict;
use POSIX;
use CGI qw(:all);
use sitemodules::Settings;
use sitemodules::DBfunctions;
use sitemodules::ModSet;
use sitemodules::Debug;

#### New subs ####
sub gal_head {
	my ($cat,$curnum,$doc_URI) = @_;
	my $url = $doc_URI || $ENV{DOCUMENT_URI};
	my $pid = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT page_id FROM page_tbl WHERE url_fld='$url'");
	$cat = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT gallerycategory_fld FROM gallerycategory_tbl WHERE gallerycategory_id=$cat");
	return $cat;
}

sub count_cur {
	my ($cat,$curnum,$doc_URI) = @_;
	my $url = $doc_URI || $ENV{DOCUMENT_URI};
	my $q = new CGI;
	my %gal_set = %{get_setting_hash("gallery")};
	my $pid = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT page_id FROM page_tbl WHERE url_fld='$url'");
	$cat ||= $sitemodules::DBfunctions::dbh->selectrow_array("SELECT gallerycategory_id FROM gallerycategory_tbl WHERE page_id=$pid AND enabled_fld='1' ORDER BY gallerycategory_id LIMIT 1");
	return " " unless $cat;
	my $total = count_all($cat);
	return " " unless $total;
	unless ($curnum) {
		$curnum = $q->param('curnum') || 0
	}
	my $lines = $q->param('lines') || $gal_set{"min_lines"};
	my $per_line = $gal_set{"count_x"};
	my $min = ($curnum+$per_line*$lines)>$total?$total:($curnum+$per_line*$lines);
	my $ct = $gal_set{count_cur_templ};
	$ct =~ s/{START}/$curnum+1/e;
	$ct =~ s/{END}/$min/;
	$ct =~ s/{TOTAL}/$total/;
	return $ct
}

sub count_all {
	use CGI;
	my $q = new CGI;
	my $cat = shift || $q->param('cat');
	return undef unless $cat;
	my $total = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT COUNT(*) FROM gallery_tbl
									  WHERE gallerycategory_id=$cat");
	return $total
}

sub cat_list {
	my ($cat,$curnum,$doc_URI) = @_;
	my $url = $doc_URI || $ENV{DOCUMENT_URI};
	my $q = new CGI;
	my $out;
	my %gal_set = %{get_setting_hash("gallery")};
	my $pid = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT page_id FROM page_tbl WHERE url_fld='$url'");
	$cat ||= $sitemodules::DBfunctions::dbh->selectrow_array("SELECT gallerycategory_id FROM gallerycategory_tbl WHERE page_id=$pid AND enabled_fld='1' ORDER BY gallerycategory_id LIMIT 1");
	return " " unless $cat;
	my $tc = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT COUNT(*) FROM gallerycategory_tbl WHERE page_id=$pid AND enabled_fld='1'");
	return " " unless $tc;
	#if ($tc!=1) {
		$out .= qq{<form method="GET" action="$ENV{DOCUMENT_URI}#gal" name="gal">};
		$out .= qq{<select name="cat" onChange="if(this.selectedIndex!=0)this.form.submit();"><option value="">— рубрики —</option>};
		my $sth = $sitemodules::DBfunctions::dbh->prepare("SELECT gallerycategory_id, gallerycategory_fld FROM gallerycategory_tbl WHERE page_id=$pid ORDER BY parent_id,gallerycategory_id");
		$sth->execute();
		while (my @row = $sth->fetchrow_array) {
			$out .= qq{<option value="$row[0]"}.($row[0]==$cat?' selected':'').qq{>$row[1]</option>};
		}
		$out .= qq{</select></form>};
	#} else {
	#	if ($gal_set{show_one_cat}) {
	#		$out .= $sitemodules::DBfunctions::dbh->selectrow_array("SELECT gallerycategory_fld FROM gallerycategory_tbl WHERE gallerycategory_id=$cat")
	#	} else {
	#		$out = ''
	#	}
	#}
	return $out
}
#### //New subs ####

sub gallery_link_head {
	my ($cat,undef,$doc_URI,$add) = @_;
	my $q = new CGI;
	my $url = $doc_URI || $ENV{DOCUMENT_URI};
	my $pid = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT page_id FROM page_tbl WHERE url_fld='$url'");
	$cat = _get_def_cat($cat,$pid);
	#$cat ||= $sitemodules::DBfunctions::dbh->selectrow_array("SELECT gallerycategory_id FROM gallerycategory_tbl WHERE page_id=$pid AND enabled_fld='1' AND parent_id=0 ORDER BY gallerycategory_id LIMIT 1");
	return " " unless $cat;
	my $total = count_all($cat);
	return " " unless $total;
	my ($gc,$tc) = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT gallerycategory_fld,enabled_fld FROM gallerycategory_tbl
									  WHERE gallerycategory_id=$cat");
	return " " unless $tc;
	my $out;
	# Показать список кол-ва миниатюр на странице либо ничего ;)
	if (get_setting("gallery","advanced")) {
		$out .= qq{<td align="right">}.per_page_list().qq{</td>};
	}
	my $sth = $sitemodules::DBfunctions::dbh->prepare("SELECT gc.gallerycategory_id, gallerycategory_fld,
														COUNT(gallery_id)
														FROM gallerycategory_tbl as gc, gallery_tbl as g
														WHERE page_id=$pid AND enabled_fld='1'
														AND g.gallerycategory_id=gc.gallerycategory_id
														GROUP BY gc.gallerycategory_id");
	$sth->execute();
	while (my @row = $sth->fetchrow_array) {
		$out .= qq{<option value="$row[0]"}.(($row[0]==$cat)?qq{ selected}:"").qq{>$row[1] ($row[2])</option>};
	}
	$out .= qq{</select></td></tr></table></form>};
	# $out .= qq{</tr></table><br>};
	return $out;
} # gallery_head

sub gallery_link {
	my ($cat,$curnum,$doc_URI,$add) = @_;
	my $url = $doc_URI || $ENV{DOCUMENT_URI};
	my $q = new CGI;
	my $out;
	my %gal_set = %{get_setting_hash("gallery")};
	my $pid = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT page_id FROM page_tbl WHERE url_fld='$url'");
	$cat = _get_def_cat($cat,$pid);
	# $cat ||= $sitemodules::DBfunctions::dbh->selectrow_array("SELECT gallerycategory_id FROM gallerycategory_tbl WHERE page_id=$pid AND enabled_fld='1' AND parent_id=0 ORDER BY gallerycategory_id LIMIT 1");
	return " " unless $cat;
	my $total = count_all($cat);
	return " " unless $total;
	my ($tc,$lines,$per_line) = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT enabled_fld,rows_fld,
																				cols_fld FROM gallerycategory_tbl
									  WHERE gallerycategory_id=$cat");
	return " " unless $tc;
	unless ($curnum) {
		$curnum = $q->param('curnum') || 0
	}
	#my $subcat = $q->param('subcat'); # For future use...
	$lines ||= $q->param('lines') || $gal_set{"min_lines"};
	$per_line ||= $gal_set{"count_x"};
	my $sth = $sitemodules::DBfunctions::dbh->prepare("SELECT gallery_id,small_url_fld,
							descr_fld,big_url_fld
							 FROM gallery_tbl
							 WHERE gallerycategory_id=$cat
                             ORDER BY order_fld
                             LIMIT ".($curnum-1).",".($lines*$per_line));
	$sth->execute();
	my $w = $gal_set{"thumb_width"};
	my $t;
	for my $i (0..$lines-1) {
		$out .= qq{<tr>};
		for (0..$per_line-1) {
			if (my @row = $sth->fetchrow_array()) {
				$t = $gal_set{"pix_template"};
				$t =~ s/{THUMB_WIDTH}/$w/g;
				if ($row[3]) {
					$t =~ s/{ID}/$row[0]/g;
				} else {
					$t =~ s!<a\s.+?{PIC}.+?>(.+?)</a>!$1!
				}
				$t =~ s/{GCID}/$cat/g;
				$t =~ s/{PIC}/$row[3]/g;
				$t =~ s/{SMALL_PIC}/$row[1]/g;
				$t =~ s/{TITLE}/$row[2]/g;
				$t =~ s/{GALLERY}/$sitemodules::Settings::c{dir}{gallery_rel}/g;
			} else {
				$t = $gal_set{"dummy_pix_template"};
				$t =~ s/{THUMB_WIDTH}/$w/g;
			}
			$out .= $t;
  		}
  		$out .= qq{</tr>};
	}
	return $out;
} # gallery

sub gallery_link_foot {
	my ($cat,$curnum,$doc_URI,$add) = @_;
	my $url = $doc_URI || $ENV{DOCUMENT_URI};
	use POSIX;
	my $q = new CGI;
	my $pid = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT page_id FROM page_tbl WHERE url_fld='$url'");
	$cat = _get_def_cat($cat,$pid);
	# $cat ||= $sitemodules::DBfunctions::dbh->selectrow_array("SELECT gallerycategory_id FROM gallerycategory_tbl WHERE page_id=$pid AND enabled_fld='1' AND parent_id=0 ORDER BY gallerycategory_id LIMIT 1");
	return " " unless $cat;
	my $total = count_all($cat);
	return " " unless $total;
	my ($tc,$lines,$per_line) = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT enabled_fld,rows_fld,
																				cols_fld FROM gallerycategory_tbl
									  WHERE gallerycategory_id=$cat");
	return " " unless $tc;
	my %gal_set = %{get_setting_hash("gallery")};
	unless ($curnum) {
		$curnum = $q->param('curnum') || 0
	}
	my $min_lines = $gal_set{"min_lines"};
	$lines ||= $q->param('lines') || $min_lines;
	$per_line ||= $gal_set{"count_x"};
	#
	my $next = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT *
									  FROM gallery_tbl
									  WHERE gallerycategory_id=$cat
									  ORDER BY order_fld
									  LIMIT ".($curnum+$lines*$per_line).",".($lines*$per_line));
	my $prev = 0;
	unless ($curnum == 0 || $curnum-$lines*$per_line < 0) {
    	$prev = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT *
									  FROM gallery_tbl
									  WHERE gallerycategory_id=$cat
									  ORDER BY order_fld
									  LIMIT ".($curnum-$lines*$per_line).",".($lines*$per_line));
	}
	my $out;
	my $aa;
	if ($add) {
		foreach my $p (split '&'=>$add) {
			my @p = split '='=>$p;
			$aa .= sprintf qq{<input type="hidden" name="%s" value="%s">},@p;
		}
	}
	$out .= qq{<form method="GET" action="$ENV{DOCUMENT_URI}#gal" name="gal">$aa
	<table border="0" cellspacing="0" cellpadding="0" align="right"><tr><td align="center"><span class="photo">Ещё фотографии:</span></td><td><select name="cat" onChange="if(this.selectedIndex!=0)submit('gal')">
			<option value="">— рубрики —</option>
		};
	my $overall = 0;
	my $sth = $sitemodules::DBfunctions::dbh->prepare("SELECT gc.gallerycategory_id, gallerycategory_fld,
														COUNT(gallery_id)
														FROM gallerycategory_tbl as gc, gallery_tbl as g
														WHERE page_id=$pid AND enabled_fld='1'
														AND g.gallerycategory_id=gc.gallerycategory_id
														GROUP BY gc.gallerycategory_id");
	$sth->execute();
	while (my @row = $sth->fetchrow_array) {
		$out .= qq{<option value="$row[0]"}.(($row[0]==$cat)?qq{ selected}:"").qq{>$row[1] ($row[2])</option>};
		$overall += $row[2];
	}
	$out .= qq{</select></td></tr></table></form><br><br>};
	# [тип объекта] [название объекта]: хх фото, в рубрике [название рубрики]: хх
	my $this_cat = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT gallerycategory_fld FROM gallerycategory_tbl WHERE gallerycategory_id=$cat");
	my $label = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT fulllabel_fld
									   FROM page_tbl
									   WHERE page_id=$pid");
	$out .= qq{<hr size="1" style="color:#d8d8d8;">};
	$out .= qq{<p class="gallery"><i style="color: #111111">$label</i>: <b>$overall</b> фото, в рубрике <i style="color: #111111">$this_cat</i>: <b>$total</b>.};
	# Выбор: либо ссылки "туда/сюда", либо номера миниатюр по страницам.
	if ($gal_set{"advanced"}) {
    	$out .= qq{&nbsp;};
    	if ($prev) {
    		$out .= qq{<a href="$ENV{DOCUMENT_URI}?lines=$lines&curnum=}.($curnum-$lines*$per_line).qq{&cat=$cat}.($add?qq{&$add}:'').qq{" class="link">&lt;&lt;&nbsp;предыдущие</a>}
    	} else {
    		$out .= qq{&nbsp;};
    	}
    	$out .= qq{&nbsp;};
    	$out .= qq{&nbsp;};
    	if ($next) {
    		$out .= qq{<a href="$ENV{DOCUMENT_URI}?lines=$lines&curnum=}.($curnum+$lines*$per_line).qq{&cat=$cat}.($add?qq{&$add}:'').qq{" class="link">следующие&nbsp;&gt;&gt;</a>}
    	} else {
    		$out .= qq{&nbsp;};
    	}
    	$out .= qq{&nbsp;};
	} else {
		my ($page,$this_page,$div) = @gal_set{qw(foot_page_templ foot_this_page_templ foot_div_templ)};
    	my @t;
    	for (0..POSIX::ceil($total/($min_lines*$per_line))-1) {
    		my $start = $min_lines*$per_line*$_;
    		my $end   = ($min_lines*$per_line*($_+1)-1 > $total-1)?($total-1):($min_lines*$per_line*($_+1)-1);
    		$start++; $end++;
			my $tt = ($start==$curnum)?$this_page:$page;
			$tt =~ s/{URL}/qq{$ENV{DOCUMENT_URI}?curnum=$start&cat=$cat}.($add?qq{&$add}:'').qq{#gal}/e;
			$tt =~ s/{PAGE}/qq{$start}.(($end==$start)?"":qq{–$end})/e;
    		push @t, $tt
    	}
    	$out .= join $div,@t
	}
	return $out;
} # gallery_foot

sub _get_def_cat {
	my $cat = shift;
	return $cat if $cat;
	my $pid = shift;
	return $sitemodules::DBfunctions::dbh->selectrow_array("SELECT gallerycategory_id FROM gallerycategory_tbl WHERE page_id=$pid AND enabled_fld='1' AND parent_id=0 ORDER BY gallerycategory_id LIMIT 1")
}

sub gallery_head {
	my $q = new CGI;
	my $cat = $q->param('cat') || get_setting("gallery","default");
	my $out = qq{<table border="0" cellpadding="0" cellspacing="0">};
	# Сделать список категорий
	my $total = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT COUNT(*) FROM gallery_tbl
									  WHERE gallerycategory_id=$cat");
	return " " unless $total;
	$out .= qq{<td><h4 style="margin:0px; padding:0px;">};
	my $tc = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT COUNT(*) FROM gallerycategory_tbl WHERE page_id=0 AND enabled_fld='1'");
	return " " unless $tc;
	if ($tc!=1) {
		$out .= qq{Выберите рубрику:</h4></td><td><select name="cat" onChange="if(this.selectedIndex!=0)submit('gal')">
				<option value="">— рубрики —</option>
			};
		my $sth = $sitemodules::DBfunctions::dbh->prepare("SELECT gallerycategory_id, gallerycategory_fld FROM gallerycategory_tbl WHERE page_id=0 ORDER BY gallerycategory_id");
		$sth->execute();
		while (my @row = $sth->fetchrow_array) {
			if ( $row[0] == $cat ) {
				$out .= qq{<option value="$row[0]" selected>$row[1]</option>};
			} else {
				$out .= qq{<option value="$row[0]">$row[1]</option>};
			}
		}
			$out .= qq{</select>
					</td>};
	} else {
		$out .= qq{Рубрика:</h4></td><td><p class="txt">}.$sitemodules::DBfunctions::dbh->selectrow_array("SELECT gallerycategory_fld FROM gallerycategory_tbl WHERE gallerycategory_id=$cat").qq{</p></td>}
	}
	# Показать список кол-ва миниатюр на странице либо ничего ;)
	if (get_setting("gallery","advanced")) {
		$out .= qq{<td align="right">}.per_page_list().qq{</td>};
	}
	$out .= qq{</tr></table><br>};
	return $out;
} # gallery_head

sub gallery_foot {
	use POSIX;
	my $q = new CGI;
	my $cat = $q->param('cat') || get_setting("gallery","default");
	my $curnum = $q->param('curnum') || 0;
	my $min_lines = get_setting("gallery","min_lines");
	my $lines = $q->param('lines') || $min_lines;
	my $per_line = get_setting("gallery","count_x");
	my $pid = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT page_id FROM page_tbl WHERE url_fld='$ENV{DOCUMENT_URI}'");
	#
	my $total = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT COUNT(*) FROM gallery_tbl
									  WHERE gallerycategory_id=$cat");
	return " " unless $total;
	my $tc = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT enabled_fld FROM gallerycategory_tbl
									  WHERE gallerycategory_id=$cat");
	return " " unless $tc;
	my $next = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT *
									  FROM gallery_tbl
									  WHERE gallerycategory_id=$cat
									  ORDER BY order_fld
									  LIMIT ".($curnum+$lines*$per_line).",".($lines*$per_line));
	my $prev = 0;
	unless ($curnum == 0 || $curnum-$lines*$per_line < 0) {
    	$prev = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT *
									  FROM gallery_tbl
									  WHERE gallerycategory_id=$cat
									  ORDER BY order_fld
									  LIMIT ".($curnum-$lines*$per_line).",".($lines*$per_line));
	}
	my $overall = 0;
	my $sth = $sitemodules::DBfunctions::dbh->prepare("SELECT gc.gallerycategory_id, gallerycategory_fld,
														COUNT(gallery_id)
														FROM gallerycategory_tbl as gc, gallery_tbl as g
														WHERE page_id=$pid AND enabled_fld='1'
														AND g.gallerycategory_id=gc.gallerycategory_id
														GROUP BY gc.gallerycategory_id");
	$sth->execute();
	while (my @row = $sth->fetchrow_array) {
		$overall += $row[2];
	}
	my $this_cat = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT gallerycategory_fld FROM gallerycategory_tbl WHERE gallerycategory_id=$cat");
	my $label = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT fulllabel_fld
									   FROM page_tbl
									   WHERE page_id=$pid");
	my $out = qq{<p class="galtxt"><em>$label</em>: <b>$overall</b> фото, в рубрике <em>$this_cat</em>: <b>$total</b>.</p>};
	# Выбор: либо ссылки "туда/сюда", либо номера миниатюр по страницам.
	if (get_setting("gallery","advanced")) {
    	$out .= qq{&nbsp;};
    	if ($prev) {
    		$out .= qq{<a href="$ENV{DOCUMENT_URI}?lines=$lines&curnum=}.($curnum-$lines*$per_line).qq{&cat=$cat" class="link">&lt;&lt;&nbsp;предыдущие</a>}
    	} else {
    		$out .= qq{&nbsp;};
    	}
    	$out .= qq{&nbsp;};
    	$out .= qq{&nbsp;};
    	if ($next) {
    		$out .= qq{<a href="$ENV{DOCUMENT_URI}?lines=$lines&curnum=}.($curnum+$lines*$per_line).qq{&cat=$cat" class="link">следующие&nbsp;&gt;&gt;</a>}
    	} else {
    		$out .= qq{&nbsp;};
    	}
    	$out .= qq{&nbsp;};
	} else {
    	$out .= qq{};
    	my @t;
    	for (0..POSIX::ceil($total/($lines*$per_line))-1) {
    		my $start = $lines*$per_line*$_;
    		my $end   = ($lines*$per_line*($_+1)-1 > $total-1)?($total-1):($lines*$per_line*($_+1)-1);
    		my ($a_st,$a_end)=qw();
    		unless ($start==$curnum) {
    			$a_st = qq{<a href="$ENV{DOCUMENT_URI}?curnum=$start&cat=$cat" class="link">};
    			$a_end = qq{</a>};
    		}
    		$start++; $end++;
    		push @t, qq{&nbsp;<nobr>$a_st$start}.(($end==$start)?"":qq{–$end}).qq{$a_end</nobr>&nbsp;};
    	}
    	$out .= qq{<p class="galtxt">}.(join " ",@t).qq{</p>};
	}
	$out .= qq{};
	return $out;
} # gallery_foot

sub gallery {
	my %gal_set = %{get_setting_hash("gallery")};
	my $q = new CGI;
	my $cat = $q->param('cat') || $gal_set{"default"};
	my $total = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT COUNT(*) FROM gallery_tbl
									  WHERE gallerycategory_id=$cat");
	return " " unless $total;
	my $tc = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT enabled_fld FROM gallerycategory_tbl
									  WHERE gallerycategory_id=$cat");
	return " " unless $tc;
	my $out = qq{};
	my $curnum = shift || 0;
	#my $subcat = $q->param('subcat'); # For future use...
	my $lines = $q->param('lines') || $gal_set{"min_lines"};
	my $per_line = $gal_set{"count_x"};
	my $sth = $sitemodules::DBfunctions::dbh->prepare("SELECT gallery_id,small_url_fld,descr_fld
							 FROM gallery_tbl
							 WHERE gallerycategory_id=$cat
                             ORDER BY order_fld
                             LIMIT $curnum,".($lines*$per_line));
	$sth->execute();
	my $w = $gal_set{"thumb_width"};
	my $t;
	for (0..$lines-1) {
		$out .= qq{<tr align="center" valign="top">};
		for (0..$per_line-1) {
			if (my @row = $sth->fetchrow_array()) {
				$t = $gal_set{"pix_template"};
				if ($row[3]) {
					$t = $gal_set{"pix_big_template"}||$gal_set{"pix_template"};
					$t =~ s/{ID}/$row[0]/g;
					$t =~ s/{SCRIPT}/$sitemodules::Settings::c{dir}{cgi_ref}/g
				}
				$t =~ s/{THUMB_WIDTH}/$w/g;
				$t =~ s/{ID}/$row[0]/g;
				$t =~ s/{GCID}/$row[0]/g;
				$t =~ s/{PIC}/$row[3]/g;
				$t =~ s/{SMALL_PIC}/$row[1]/g;
				$t =~ s/{TITLE}/$row[2]/g;
				$t =~ s/{GALLERY}/$sitemodules::Settings::c{dir}{gallery_rel}/g;
				$t =~ s/{SCRIPT}/$sitemodules::Settings::c{dir}{cgi_ref}/g;
			} else {
				$t = $gal_set{"dummy_pix_template"};
				$t =~ s/{THUMB_WIDTH}/$w/g;
			}
			$out .= $t;
  		}
  		$out .= qq{</tr>};
	}
	$out .= qq{};
	return $out;
} # gallery

sub galleryEx {
	my $cat = shift;
	return unless $cat;
	my $templ = shift;
	return unless $templ;
	my $no_link_templ = get_setting("gallery","no_link_template");
	my $total = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT COUNT(*) FROM gallery_tbl
									  WHERE gallerycategory_id=$cat");
	return " " unless $total;
	my $tc = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT enabled_fld FROM gallerycategory_tbl
									  WHERE gallerycategory_id=$cat");
	return " " unless $tc;
	my $out = qq{<table border="0" cellpadding="0" cellspacing="0" class="gal"><tr><td><ul class="pf-gal">};
	my $curnum = 0;
	my $per_line = 2;
	my $lines = POSIX::floor($total / $per_line);
	$lines += $total % $per_line;
	my $sth = $sitemodules::DBfunctions::dbh->prepare("SELECT gallery_id,small_url_fld,
													  descr_fld,big_url_fld
														FROM gallery_tbl
														WHERE gallerycategory_id=$cat
														ORDER BY order_fld
														LIMIT $curnum,".($lines*$per_line));
	$sth->execute();
	while (my @row = $sth->fetchrow_array()) {
		my $t = ($row[3])?$templ:$no_link_templ;
		$t =~ s/{ID}/$row[0]/g;
		$t =~ s/{PIC}/$row[1]/g;
		$t =~ s/{GALLERY}/$sitemodules::Settings::c{dir}{gallery_rel}/g;
		$t =~ s/{SCRIPT}/$sitemodules::Settings::c{dir}{cgi_ref}/g;
		$t =~ s/{TITLE}/$row[2]/g;
		$out .= qq{<li>$t</li>}
	}
	$out .= qq{</ul></td></tr></table>};
	return $out
}

sub timg {
	my $out;
	my $q = new CGI;
	my $id = $q->param("img_id");
	my @img = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT * FROM gallery_tbl WHERE gallery_id=$id");
	$out .= qq{<img src="$sitemodules::Settings::c{dir}{gallery_rel}$img[2]" border="0" alt="$img[5]" title="$img[5]" onclick="javascript:window.close()" id="_timg_">};
	return $out;
} # tpollprev

sub timgtitle {
	my $q = new CGI;
	my $id = $q->param("img_id");
	my $title = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT descr_fld FROM gallery_tbl WHERE gallery_id=$id");
	$title =~ s!</?[^>]*>!!g;
	return $title || " ";
} # timgtitle

sub per_page_list {
	my $q = new CGI;
	my $out = qq{<select name="lines" onChange="javascript:submit('gal')">
						};
	my $lines = $q->param('lines');
	my $min_lines = get_setting("gallery","min_lines");
	my $max_lines = get_setting("gallery","max_lines");
	my $per_line = get_setting("gallery","count_x");
	my $flg;
	for ($min_lines..$max_lines) {
		my $sel;
		if ($lines==$_){
			$sel = "selected";
    		$flg = ($flg)?$flg:1;
 		}
		$out .= qq{<option value="$_" $sel>}.($_*$per_line).qq{</option>};
	}
	$out .= qq{<option value="-1" }.($flg?"":"selected").qq{>Все</option></select>};
	return $out;
}

sub gogallery {
	my $templ = qq{</tr><tr height="36"><td align="center" valign="top"><a href="%s" class="link-txt" target="_blank" onclick="if(!window.opener){window.close()}">Перейти в Галерею</a></td></tr>};
	my $host = $ENV{HTTP_X_FORWARDED_HOST}||$ENV{HTTP_HOST};
	return if $ENV{HTTP_REFERER} =~ m!//${host}/!;
	my $q = new CGI;
	my $id = $q->param("img_id");
	my $url = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT url_fld
													FROM gallery_tbl as g, gallerycategory_tbl as gc, page_tbl as p
													WHERE gallery_id=$id
													 AND g.gallerycategory_id=gc.gallerycategory_id
													 AND p.page_id=gc.page_id");
	return sprintf $templ,$url;
}

1;
__END__

=head1 NAME

B<Gallery.pm> — Модуль Галереи

=head1 SYNOPSIS

Модуль Галереи

=head1 DESCRIPTION

Модуль для работы с Галереей







=head2 gallery_head

Показ раздела в Основной странице Галереи :: Заголовок (список разделов).

=over 4

=item Вызов:

C<< <!--#include virtual="gallery_head"--> >>

=item Пример вызова:

C<< <!--#include virtual="gallery_head"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

L<get_setting|::ModSet/"get_setting">.

=back

=head2 gallery_foot

Показ раздела в Основной странице Галереи :: Нижняя часть (прокрутка по страницам).

=over 4

=item Вызов:

C<< <!--#include virtual="gallery_foot"--> >>

=item Пример вызова:

C<< <!--#include virtual="gallery_foot"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

L<get_setting|::ModSet/"get_setting">.

=back

=head2 gallery

Основная страница Галереи.

=over 4

=item Вызов:

C<< <!--#include virtual="gallery"--> >>

=item Пример вызова:

C<< <!--#include virtual="gallery"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

L<get_setting_hash|::ModSet/"get_setting_hash">.

=back

=head2 timg

Возвращает саму картинку для показа её отдельно.

=over 4

=item Вызов:

C<< <!--#include virtual="timg"--> >>

=item Пример вызова:

C<< <!--#include virtual="timg"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

L<get_setting_hash|::ModSet/"get_setting_hash">.

=back

=head2 timgtitle

Возвращает описание картинки при показе её отдельно (большой просмотр).

=over 4

=item Вызов:

C<< <!--#include virtual="timgtitle"--> >>

=item Пример вызова:

C<< <!--#include virtual="timgtitle"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

L<get_setting_hash|::ModSet/"get_setting_hash">.

=back

=head2 per_page_list

Выпадающий список с количествами миниатюр на странице Галереи. Ставится в advanced-режиме.

=over 4

=item Вызов:

C<< per_page_list() >>

=item Пример вызова:

 per_page_list();

=item Примечания:

Напрямую не вызывается. Внутренняя функция.

=item Зависимости:

L<get_setting|::ModSet/"get_setting">.

=back

=head1 AUTHOR

MethodLab && DAY.

=head1 BUGS

No known ones yet. ;))

=head1 SEE ALSO

=head1 COPYRIGHT

E<copy> Copyright 2003-2004, MethodLab

=cut
