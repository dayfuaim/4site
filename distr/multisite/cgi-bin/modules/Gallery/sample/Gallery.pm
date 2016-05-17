#!/usr/bin/perl
#
#

=head1 NAME

B<Gallery.pm> — Модуль Галереи

=head1 SYNOPSIS

Модуль Галереи

=head1 DESCRIPTION

Модуль для работы с Галереей

=cut

# Модуль обработки Галереи
package sitemodules::Gallery;
use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
our @ISA=qw(Exporter);
our @EXPORT=qw(gallery_head gallery_foot gallery gallery_link gallery_link_foot timg timgtitle gallery_link_head gogallery);
our @EXPORT_OK = qw();
our %EXPORT_TAGS = ();
our $VERSION=1.90;
use strict;
use CGI qw(:all);
use sitemodules::Settings;
use sitemodules::DBfunctions;
use sitemodules::ModSet;
use sitemodules::Debug;

sub gallery_link_head {
	my $q = new CGI;
	my $url = $ENV{DOCUMENT_URI};
	my $pid = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT page_id FROM page_tbl WHERE url_fld='$url'");
	my $cat = $q->param('cat') || $sitemodules::DBfunctions::dbh->selectrow_array("SELECT gallerycategory_id FROM gallerycategory_tbl WHERE page_id=$pid AND enabled_fld='1' LIMIT 1");
	return " " unless $cat;
	my $total = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT COUNT(*) FROM gallery_tbl
									  WHERE gallerycategory_id=$cat");
	return " " unless $total;
	my $tc = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT enabled_fld FROM gallerycategory_tbl
									  WHERE gallerycategory_id=$cat");
	return " " unless $tc;
	my $out = qq{<table border="0" cellpadding="0" cellspacing="0"><tr>};
	# Сделать список категорий
	$out .= qq{<td><h4 style="margin:0px; padding:0px;">};
	if ($sitemodules::DBfunctions::dbh->selectrow_array("SELECT COUNT(*) FROM gallerycategory_tbl WHERE page_id=$pid AND enabled_fld='1'")!=1) {
		$out .= qq{Выберите рубрику:</h4></td><td><select name="cat" onChange="if(this.selectedIndex!=0)submit('gal')">
				<option value="">— рубрики —</option>
			};
		my $sth = $sitemodules::DBfunctions::dbh->prepare("SELECT gallerycategory_id, gallerycategory_fld FROM gallerycategory_tbl WHERE page_id=$pid ORDER BY gallerycategory_id");
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

sub gallery_link {
	my $q = new CGI;
	my $out = qq{<table border="0" cellpadding="0" cellspacing="0">
	<tr><td colspan="10" height="15"><img src="/img/1pix.gif" width="1" height="15"></td></tr>
	};
	my %gal_set = %{get_setting_hash("gallery")};
	my $url = $ENV{DOCUMENT_URI};
	my $pid = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT page_id FROM page_tbl WHERE url_fld='$url'");
	my $cat = $q->param('cat') || $sitemodules::DBfunctions::dbh->selectrow_array("SELECT gallerycategory_id FROM gallerycategory_tbl WHERE page_id=$pid LIMIT 1");
	return " " unless $cat;
	my $total = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT COUNT(*) FROM gallery_tbl
									  WHERE gallerycategory_id=$cat");
	return " " unless $total;
	my $tc = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT enabled_fld FROM gallerycategory_tbl
									  WHERE gallerycategory_id=$cat");
	return " " unless $tc;
	my $curnum = $q->param('curnum') || 0;
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
		$out .= qq{<tr>};
		for (0..$per_line-1) {
			if (my @row = $sth->fetchrow_array()) {
				$t = $gal_set{"pix_template"};
				$t =~ s/{THUMB_WIDTH}/$w/g;
				$t =~ s/{ID}/$row[0]/g;
				$t =~ s/{SMALL_PIC}/$row[1]/g;
				$t =~ s/{TITLE}/$row[2]/g;
				$t =~ s/{GALLERY}/$sitemodules::Settings::c{dir}{gallery_rel}/ge;
				$t =~ s/{SCRIPT}/$sitemodules::Settings::c{dir}{cgi_ref}/ge;
			} else {
				$t = $gal_set{"dummy_pix_template"};
				$t =~ s/{THUMB_WIDTH}/$w/g;
			}
			$out .= $t;
  		}
  		$out .= qq{</tr><tr><td colspan="10" height="15"><img src="/img/1pix.gif" width="1" height="15"></td></tr>};
	}
	$out .= qq{</table>};
	return $out;
} # gallery

=head2 gallery_link_foot

Показ раздела, привязанного к конкретной странице :: Нижная часть (прокрутка по страницам).

=over 4

=item Вызов:

C<< <!--#include virtual="gallery_link_foot"--> >>

=item Пример вызова:

C<< <!--#include virtual="gallery_link_foot"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

L<get_setting_hash|::ModSet/"get_setting_hash">.

=back

=cut
sub gallery_link_foot {
	use POSIX;
	my $q = new CGI;
	my $url = $ENV{DOCUMENT_URI};
	my $pid = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT page_id FROM page_tbl WHERE url_fld='$url'");
	my $cat = $q->param('cat') || $sitemodules::DBfunctions::dbh->selectrow_array("SELECT gallerycategory_id FROM gallerycategory_tbl WHERE page_id=$pid");
	return " " unless $cat;
	my $total = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT COUNT(*) FROM gallery_tbl
									  WHERE gallerycategory_id=$cat");
	return " " unless $total;
	my $tc = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT enabled_fld FROM gallerycategory_tbl
									  WHERE gallerycategory_id=$cat");
	return " " unless $tc;
	my %gal_set = %{get_setting_hash("gallery")};
	my $curnum = $q->param('curnum') || 0;
	my $min_lines = $gal_set{"min_lines"};
	my $lines = $q->param('lines') || $min_lines;
	my $per_line = $gal_set{"count_x"};
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
	my $out = qq{<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr><td class="tl">По&nbsp;этому разделу фотографий <b>$total</b>:};
	# Выбор: либо ссылки "туда/сюда", либо номера миниатюр по страницам.
	if ($gal_set{"advanced"}) {
    	$out .= qq{&nbsp;};
    	if ($prev) {
    		$out .= qq{<a href="$url?lines=$lines&curnum=}.($curnum-$lines*$per_line).qq{&cat=$cat" class="link">&lt;&lt;&nbsp;предыдущие</a>}
    	} else {
    		$out .= qq{&nbsp;};
    	}
    	$out .= qq{&nbsp;};
    	$out .= qq{&nbsp;};
    	if ($next) {
    		$out .= qq{<a href="$url?lines=$lines&curnum=}.($curnum+$lines*$per_line).qq{&cat=$cat" class="link">следующие&nbsp;&gt;&gt;</a>}
    	} else {
    		$out .= qq{&nbsp;};
    	}
    	$out .= qq{&nbsp;};
	} else {
    	$out .= qq{};
    	my @t;
    	for (0..POSIX::ceil($total/($min_lines*$per_line))-1) {
    		my $start = $min_lines*$per_line*$_;
    		my $end   = ($min_lines*$per_line*($_+1)-1 > $total-1)?($total-1):($min_lines*$per_line*($_+1)-1);
    		my ($a_st,$a_end)=qw();
    		unless ($start==$curnum) {
    			$a_st = qq{<a href="$url?curnum=$start&cat=$cat" class="link">};
    			$a_end = qq{</a>};
    		}
    		$start++; $end++;
    		push @t, qq{&nbsp;<nobr>$a_st$start}.(($end==$start)?"":qq{–$end}).qq{$a_end</nobr>&nbsp;};
    	}
    	$out .= join " ",@t;
	}
	$out .= qq{</td></tr></table>};
	return $out;
} # gallery_foot

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

=cut
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

=cut
sub gallery_foot {
	use POSIX;
	my $q = new CGI;
	my $cat = $q->param('cat') || get_setting("gallery","default");
	my $curnum = $q->param('curnum') || 0;
	my $min_lines = get_setting("gallery","min_lines");
	my $lines = $q->param('lines') || $min_lines;
	my $per_line = get_setting("gallery","count_x");
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
	my $out = qq{<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr><td class="tl">По&nbsp;этому разделу фотографий <b>$total</b>:};
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
    	for (0..POSIX::ceil($total/($min_lines*$per_line))-1) {
    		my $start = $min_lines*$per_line*$_;
    		my $end   = ($min_lines*$per_line*($_+1)-1 > $total-1)?($total-1):($min_lines*$per_line*($_+1)-1);
    		my ($a_st,$a_end)=qw();
    		unless ($start==$curnum) {
    			$a_st = qq{<a href="$ENV{DOCUMENT_URI}?curnum=$start&cat=$cat" class="link">};
    			$a_end = qq{</a>};
    		}
    		$start++; $end++;
    		push @t, qq{&nbsp;<nobr>$a_st$start}.(($end==$start)?"":qq{–$end}).qq{$a_end</nobr>&nbsp;};
    	}
    	$out .= join " ",@t;
	}
	$out .= qq{</td></tr></table>};
	return $out;
} # gallery_foot

#### Subroutines ####
##
##
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

=cut
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
	my $out = qq{<table border="0" cellpadding="0" cellspacing="0">
	<tr><td colspan="10" height="15"><img src="/img/1pix.gif" width="1" height="15"></td></tr>
	};
	my $curnum = $q->param('curnum') || 0;
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
		$out .= qq{<tr>};
		for (0..$per_line-1) {
			if (my @row = $sth->fetchrow_array()) {
				$t = $gal_set{"pix_template"};
				$t =~ s/{THUMB_WIDTH}/$w/g;
				$t =~ s/{ID}/$row[0]/g;
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
  		$out .= qq{</tr><tr><td colspan="10" height="15"><img src="/img/1pix.gif" width="1" height="15"></td></tr>};
	}
	$out .= qq{</table><br>};
	return $out;
} # gallery

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

=cut
sub timg {
	my $out;
	my $q = new CGI;
	my $id = $q->param("img_id");
	my @img = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT * FROM gallery_tbl WHERE gallery_id=$id");
	$out .= qq{<img src="$sitemodules::Settings::c{dir}{gallery_rel}$img[2]" border="0" alt="$img[5]" title="$img[5]" onclick="javascript:window.close()" id="_timg_">};
	return $out;
} # tpollprev

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

=cut
sub timgtitle {
	my $q = new CGI;
	my $id = $q->param("img_id");
	my $title = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT descr_fld FROM gallery_tbl WHERE gallery_id=$id");
	$title =~ s!</?[^>]*>!!g;
	return $title || " ";
} # timgtitle

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

=cut
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
	my $host = $ENV{HTTP_HOST};
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

=head1 AUTHOR

MethodLab && DAY.

=head1 BUGS

No known ones yet. ;))

=head1 SEE ALSO

=head1 COPYRIGHT

E<copy> Copyright 2003-2004, MethodLab

=cut

