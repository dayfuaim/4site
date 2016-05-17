#!/usr/bin/perl -W
use strict;
use CGI qw(:all);
use sitemodules::DBfunctions;
use sitemodules::ModSet;
use sitemodules::Debug;

$|++;
print "Content-type: text/html; charset=windows-1251\n\n";
my $q = new CGI;

# Подключение к базе
$sitemodules::DBfunctions::dbh = connectDB();
#unless ($q->param('srch')) {
my %news_set = %{get_setting_hash("news")};
unless ($q->param('id')) {
	my $templ = $news_set{"template"};
	my $w = $news_set{"digest_width"};
	my $mnth = $news_set{"month_word"};
	my $sth = $sitemodules::DBfunctions::dbh->prepare("SELECT  date_format(date_fld,'%Y%m%d%H%i%s'), head_fld, news_id, body_fld FROM news_tbl WHERE date_fld<=NOW() ORDER BY date_fld DESC");
	$sth->execute();
	# Вывод результатов запроса
	while (my @row = $sth->fetchrow_array) {
		my ($mp,$a) = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT url_fld,alt_fld FROM news_pix_tbl WHERE news_id=$row[2] AND main_fld=1");
		my ($year,$month,$day,$h,$minute) = $row[0] =~ /^(\d\d\d\d)(\d\d)(\d\d)(\d\d)(\d\d)/;
		#$month = qw(января февраля марта апреля мая июня июля августа сентября октября ноября декабря)[$month-1] if $mnth;
		my $head = $row[1];
		my $d = sprintf "%02d.%02d.%4d",$day,$month,$year;
		my $t = $templ;

		$mp = qq{<img src="/news/img/$mp" border="0" align="left" class="pic-news1" alt="$a" />} if $mp;
		$t =~ s/{ID}/$row[2]/g;
		$t =~ s/{HEAD}/$head/g;
		$t =~ s/{DATE}/$d/g;
		#$t =~ s/{DAY}/$day/g;
		#$t =~ s/{MONTH}/$month/g;
		#$t =~ s/{YEAR}/$year/g;
		$t =~ s/{BODY}/$row[3]/g;
		$t =~ s/{MAIN_PIC}/$mp/g;
		print $t
	}
} else {
	my $templ = $news_set{"template"};
	my $mnth = $news_set{"month_word"};
	my @row = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT  date_format(date_fld,'%Y%m%d%H%i%s'), head_fld, news_id, body_fld FROM news_tbl WHERE news_id=".$q->param('id'));
	my ($year,$month,$day,$h,$minute) = $row[0] =~ /^(\d\d\d\d)(\d\d)(\d\d)(\d\d)(\d\d)/;
	#$month = $mnth[$month-1] if $mnth;
	my $head = $row[1];
	my $frmt = $mnth?"%d %s %4d г.":"%02d.%02d.%4d";
	my $d = sprintf $frmt,$day,$month,$year;
	my $t = $templ;
	$t =~ s/{HEAD}/$head/g;
	$t =~ s/{DATE}/$d/g;
	#$t =~ s/{DAY}/$day/g;
	#$t =~ s/{MONTH}/$month/g;
	#$t =~ s/{YEAR}/$year/g;
	$t =~ s/{BODY}/$row[3]/g;
	print $t
}
#} else {
#    print qq{<h2>Результаты поиска</h2><br />};
#    my $sql="SELECT date_format(date_fld,'%Y%m%d%H%i%s'), head_fld, news_id, body_fld
#               FROM news_tbl WHERE ";
#    my $stdate = $q->param('stdate');
#    my $enddate = $q->param('enddate');
#    my $lag = $q->param('lag');
#	my @p;
#    if ($lag eq "week") {
#        push @p => "date_fld BETWEEN DATE_SUB(NOW(), INTERVAL 7 DAY) AND NOW()"
#        }
#    elsif ($lag eq "month") {
#        push @p => "date_fld BETWEEN DATE_SUB(NOW(), INTERVAL 1 MONTH) AND NOW()"
#        }
#    elsif ($lag eq "month3") {
#        push @p => "date_fld BETWEEN DATE_SUB(NOW(), INTERVAL 3 MONTH) AND NOW()"
#        }
#    else {
#		if ($stdate and $enddate) {
#			$stdate  =~ s/^(\d\d)\.(\d\d)\.(\d{4})/$3-$2-$1/;
#			$enddate =~ s/^(\d\d)\.(\d\d)\.(\d{4})/$3-$2-$1/;
#			if ($stdate gt $enddate) {
#				($stdate,$enddate) = ($enddate,$stdate);
#			}
#			push @p => "date_fld BETWEEN '$stdate 00:00:00' AND '$enddate 23:59:59'";
#		} elsif ($stdate) {
#			$stdate  =~ s/^(\d\d)\.(\d\d)\.(\d{4})/$3-$2-$1/;
#			push @p => "date_fld >= '$stdate'";
#		} elsif ($enddate) {
#			$enddate =~ s/^(\d\d)\.(\d\d)\.(\d{4})/$3-$2-$1/;
#			push @p => "date_fld <= '$enddate'";
#		}
#    }
#    if (my $content = $q->param('content')) {
#    	push @p => "body_fld LIKE '%".$content."%'";
#	}
#	push @p => "date_fld<=NOW()" if (!$enddate);
#    $sql .= (join ' AND '=>@p)." ORDER BY date_fld DESC";
#    my $sth = $sitemodules::DBfunctions::dbh->prepare($sql);
#    $sth->execute();
#    if ($sth->rows) {
#    	my $templ = get_setting("news","template");
#		my $mnth = get_setting("news","month_word");
#    	while (my @row = $sth->fetchrow_array) {
#			my ($year,$month,$day,$h,$minute) = $row[0] =~ /^(\d\d\d\d)(\d\d)(\d\d)(\d\d)(\d\d)/;
#			#$month = qw(января февраля марта апреля мая июня июля августа сентября октября ноября декабря)[$month-1] if $mnth;
#			my $head = $row[1];
#			my $d = sprintf "%02d.%02d.%4d",$day,$month-1,$year;
#    		my $t = $templ;
#
#    		$t =~ s/{ID}/$row[2]/g;
#    		$t =~ s/{HEAD}/$head/g;
#    		$t =~ s/{DATE}/$d/g;
#			$t =~ s/{DAY}/$day/g;
#			$t =~ s/{MONTH}/$month/g;
#			$t =~ s/{YEAR}/$year/g;
#    		$t =~ s/{BODY}/$row[3]/g;
#    		print $t;
#    	}
#    } else {
#    	print qq{<p>Ничего не найдено.</p>};
#    }
#}

sub trim {
	my ($string,$cnt) = @_;
	my $out = $string;
	return $out if length $out <= $cnt;
	my @t = qw{b i u s p a blockquote table tr td span li ol ul nobr};
	$out =~ s/&nbsp;/ /g;
	$out =~ s/&quot;/"/g;
	$out = substr $out,0,$cnt;
	$out =~ /^((?:.|\r?\n)+)<(\w+).+?$/;
	my $before = $1;
	my $tag = $2;
	$out =~ m!^((?:.|\r?\n)+)</(\w+).+?$!;
	my $bf = $1;
	my $tag1 = $2;
	if (length($bf)<length($before) and length($before)>0) {
		if ($tag1 ne $tag) {
			if (scalar grep { $_ eq $tag } @t) {
				$tag = 'table' if $tag =~ /^t(d|r|able)$/;
				if ($tag eq 'li') {
					if ($before =~ /<ul.+?$/) {
						$tag = 'ul'
					} else {
						$tag = 'ol'
					}
				}
				my $bf = $before;
				$bf =~ s/\n/\\n/g;
				$bf =~ s/\s/\\s/g;
				my $rx = qr{^((?:.|\n)+)<$tag.+?$};
				$out =~ /$rx/;
				$out = $1
			} else {
				$out = $before
			}
		}
	}
	$out .= (length($string)>$cnt)?'...':'';
	return $out
}

sub trimAllTags {
	my ($string,$cnt) = @_;
	my $out = $string;
	$out =~ s/&nbsp;/ /g;
	$out =~ s/&quot;/"/g;
	$out =~ s/<(?!br)[^>]+?>//g;
	return $out if length $out <= $cnt;
	$out = substr $out,0,$cnt;
	$out .= (length($string)>$cnt)?'...':'';
	return $out
}
