#!/usr/bin/perl -W
#
use CGI qw(:all);
use strict;
use sitemodules::DBfunctions;
use sitemodules::ModSet;

print "Content-type: text/html; charset=windows-1251\n\n";

# Подключение к базе
$sitemodules::DBfunctions::dbh = connectDB();
my %news_set = %{get_setting_hash("news")};
my $templ = $news_set{template};
my $pix_templ = $news_set{news_pix_template};
my $pad = $news_set{pix_padding};
my $quant = $news_set{quant};
my $main = $news_set{mainpic_news};

my $q = new CGI;
# Если в строку для поиска что-то дали, то не выводить список Новостей
unless ($ENV{'QUERY_STRING'}) {
	my $sth = $sitemodules::DBfunctions::dbh->prepare("SELECT date_format(date_fld,'%Y%m%d%H%i%s'), head_fld,
													  news_id, body_fld
													  FROM news_tbl
													  ORDER BY date_fld DESC LIMIT $quant");
	$sth->execute();
	# Вывод результатов запроса
	while (my @row = $sth->fetchrow_array) {
		my ($year,$month,$day,$h,$minute) = $row[0] =~ /(\d{4})(\d\d)(\d\d)(\d\d)(\d\d)/;
		my $head = $row[1];
		my $d = "$day.$month.$year";
		my $t = $templ;

		$t =~ s/{ID}/$row[2]/g;
		$t =~ s/{HEAD}/$head/g;
		$t =~ s/{DATE}/$d/g;
		$t =~ s/{TIME}/$h:$minute/g;
		$t =~ s/{BODY}/$row[3]/g;
		my $sth1 = $sitemodules::DBfunctions::dbh->prepare("SELECT * FROM news_pix_tbl WHERE news_id=$row[2] AND main_fld".($main?'':'!')."=1");
		$sth1->execute();
		if ($sth1->rows) {
			my ($top,$bottom);
			while (my @row1 = $sth1->fetchrow_array) {
				my $ti = $pix_templ;
				$ti =~ s/{ALIGN}/$row1[4]/g;
				$ti =~ s/{PAD}/$pad/g;
				$row1[5] = qq{/news/img/$row1[5]};
				$ti =~ s/{URL}/$row1[5]/g;
				$ti =~ s/{ALT}/$row1[2]/g;
				if ($row1[3] eq 'top') {
					$top .= $ti
				} elsif ($row1[3] eq 'bottom') {
					$bottom .= $ti
				}
			}
			$t =~ s/{TOP}/$top/g;
			$t =~ s/{BOTTOM}/$bottom/g
		} else {
			$t =~ s/{TOP}//g;
			$t =~ s/{BOTTOM}//g
		}
		print $t;
	}
}

if ($q->param('srch')) {
    print qq{<h2>Результаты поиска</h2>
    };

    my $sql="SELECT date_format(date_fld,'%Y%m%d%H%i%s'), head_fld,
													  news_id, body_fld
               FROM news_tbl WHERE ";
    my $stdate = $q->param('stdate');
    my $enddate = $q->param('enddate');
    my $content = $q->param('content');

    my $lag = $q->param('lag');
    $sql .= "date_fld ";
    if ($lag eq "week") {
        $sql .= "BETWEEN DATE_SUB(NOW(), INTERVAL 7 DAY) AND NOW()"
        }
    elsif ($lag eq "month") {
        $sql .= "BETWEEN DATE_SUB(NOW(), INTERVAL 1 MONTH) AND NOW()"
        }
    elsif ($lag eq "month3") {
        $sql .= "BETWEEN DATE_SUB(NOW(), INTERVAL 3 MONTH) AND NOW()"
        }
    else {
    	$stdate  =~ s/^(\d\d)\.(\d\d)\.(\d{4})/$3-$2-$1/;
    	$enddate =~ s/^(\d\d)\.(\d\d)\.(\d{4})/$3-$2-$1/;
    	my ($stdate_real,$enddate_real) = ($stdate,$enddate);
    	if ($stdate ge $enddate) {
    		($stdate_real,$enddate_real) = ($enddate,$stdate);
   		}
        $sql .= "BETWEEN '$stdate_real 00:00:00' AND '$enddate_real 23:59:59'";
        }
    if ($content) {
		$sql .= " AND " if ($stdate||$enddate||$lag);
    	$sql .= "body_fld LIKE '%".$content."%'";
	}
    $sql .= " ORDER BY date_fld DESC";
    my $sth = $sitemodules::DBfunctions::dbh->prepare($sql);
    $sth->execute();
    if ($sth->rows) {
        print qq{<table align="center" border="0" cellpadding="0" cellspacing="0" width="80%">};
    	while (my @row = $sth->fetchrow_array) {
			my ($year,$month,$day,$h,$minute) = $row[0] =~ /(\d{4})(\d\d)(\d\d)(\d\d)(\d\d)/;
			my $head = $row[1];
			my $d = "$day.$month.$year";
			my $t = $templ;

			$t =~ s/{ID}/$row[2]/g;
			$t =~ s/{HEAD}/$head/g;
			$t =~ s/{DATE}/$d/g;
			$t =~ s/{TIME}/$h:$minute/g;
			$t =~ s/{BODY}/$row[3]/g;
			my $sth1 = $sitemodules::DBfunctions::dbh->prepare("SELECT * FROM news_pix_tbl WHERE news_id=$row[2] AND main_fld".($main?'':'!')."=1");
			$sth1->execute();
			if ($sth1->rows) {
				my ($top,$bottom);
				while (my @row1 = $sth1->fetchrow_array) {
					my $ti = $pix_templ;
					$ti =~ s/{ALIGN}/$row1[4]/g;
					$ti =~ s/{PAD}/$pad/g;
					$row1[5] = qq{/news/img/$row1[5]};
					$ti =~ s/{URL}/$row1[5]/g;
					$ti =~ s/{ALT}/$row1[2]/g;
					if ($row1[3] eq 'top') {
						$top .= $ti
					} elsif ($row1[3] eq 'bottom') {
						$bottom .= $ti
					}
				}
				$t =~ s/{TOP}/$top/g;
				$t =~ s/{BOTTOM}/$bottom/g
			} else {
				$t =~ s/{TOP}//g;
				$t =~ s/{BOTTOM}//g
			}
			print $t;
    	}
    	print qq{</table>};
	} else {
        print <<EOHT;
    	<table class="tab">
    		<tr>
    			<th>По Вашему запросу ничего не найдено.<br>Измените запрос и попробуйте ещё раз.</th>
   			</tr>
		</table>
EOHT
	}
}

# Отсоединение от базы данных

#exit;
