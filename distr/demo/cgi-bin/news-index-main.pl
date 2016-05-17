#!/usr/bin/perl
use strict;
use sitemodules::DBfunctions;
use sitemodules::ModSet;
use sitemodules::Debug;

# Подключение к базе
$sitemodules::DBfunctions::dbh = connectDB();

$|++;
print "Content-type: text/html; charset=windows-1251\n\n";

my %news_set = %{get_setting_hash("news")};
my $quant = $news_set{"digest_quant"};
my $w = $news_set{"digest_width"};
my $templ = $news_set{"template_digest"};
my $sth = $sitemodules::DBfunctions::dbh->prepare("SELECT date_format(date_fld,'%Y%m%d%H%i%s'), head_fld, news_id, body_fld FROM news_tbl WHERE date_fld<=NOW() ORDER BY date_fld DESC LIMIT $quant");
$sth->execute();
# Вывод результатов запроса
my $i = 0;
while (my @row = $sth->fetchrow_array) {
	my ($mp,$a) = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT url_fld,alt_fld FROM news_pix_tbl WHERE news_id=$row[2] AND main_fld=1");
    my ($year,$month,$day,$h,$minute) = $row[0] =~ /^(\d\d\d\d)(\d\d)(\d\d)(\d\d)(\d\d)/;
	my $d = "$day.$month.$year";
	my $t = $templ;
	#if ($i++==0) {
	#	if ($news_set{"first_in_digest"}) {
	#		$t = $news_set{"first_in_digest_template"};
			$t =~ s/{BODY}/trimAllTags($row[-1],2*$w)/ge;
	#	}
	#}

	$mp = qq{<img src="/news/img/$mp" border="0" align="left" class="pic-news1" alt="$a" />} if $mp;
	$t =~ s/{ID}/$row[2]/g;
	$t =~ s/{HEAD}/$row[1]/g;
	$t =~ s/{DATE}/$d/g;
	$t =~ s/{MAIN_PIC}/$mp/g;

    print $t;
}

sub trim {
	my ($string,$cnt) = @_;
	my $out = $string;
	return $out if length $out <= $cnt;
	my @t = qw{b i u s p a blockquote table tr td span li ol ul img};
	$out =~ s/&nbsp;/ /g;
	$out =~ s/&quot;/"/g;
	$out = substr $out,0,$cnt;
	my ($before,$tag) = $out =~ /^((?:.|\r?\n)+)<(\w+).+?$/;
	my ($bf,$tag1) = $out =~ m!^((?:.|\r?\n)+)</(\w+).+?$!;
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
