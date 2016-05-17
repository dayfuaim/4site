#!/usr/bin/perl -W
#
# News SSI
use DBI;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use strict;
use sitemodules::Settings;
use sitemodules::DBfunctions;
use vars qw($dbh);

print "Content-type: text/html; charset=windows-1251\n\n";

$|++;
# Подключение к базе
$dbh = connectDB();

my $q = new CGI;

# Показать форму для поиска
my $stdate = $q->param('stdate') || $dbh->selectrow_array("SELECT CURDATE()");
$stdate =~ s/(\d{4})-(\d\d)-(\d\d)/$3.$2.$1/ if $stdate ne $q->param('stdate');

my $enddate = $q->param('enddate') || $dbh->selectrow_array("SELECT CURDATE()");
$enddate =~ s/(\d{4})-(\d\d)-(\d\d)/$3.$2.$1/ if $enddate ne $q->param('enddate');

print <<EOTH;
<!-- search in news -->
<form name="period" method="get" action="/news/index.shtml">
<input type="hidden" name="srch" value="1">
<table align="left" cellpadding="0" cellspacing="0" border="0" width="100%">
    <tr>
        <td rowspan="5">&nbsp;</td>
        <td colspan="2" width="117" height="21" align="left" style="background:url(/img/index/top2.gif) repeat-x bottom;" valign="bottom"><img src="/img/index/find_news.gif" alt="" width="119" height="21" border="0"></td>
        <td>&nbsp;</td>
    </tr>
    <tr>
        <td colspan="2"></td>
        <td height="10" width="10" valign="top"><img src="/img/index/p_top3.gif" width="10" height="10" border="0"></td>
    </tr>
    <tr>
        <td style="background: url(/img/index/center.gif) repeat-y right;"  colspan="3" valign="top">
            <h5>по дате:</h5>
            <table align="left" cellpadding="0" cellspacing="0" border="0">
                <tr>
                    <td colspan="3" class="find-news"><b>приблизительно:</b></td>
                </tr>
                <tr>
                    <td class="tl" colspan="3"><select name="lag">
EOTH
my $lag = $q->param('lag');
    print qq{
    <option value=""},($lag !~ /week|month|month3/)?" selected":"",qq{>Выберите диапазон</option>
    <option value="week"},($lag eq "week")?" selected":"",qq{>Неделя</option>
    <option value="month"},($lag eq "month")?" selected":"",qq{>Месяц</option>
    <option value="month3"},($lag eq "month3")?" selected":"",qq{>Три месяца</option>
    };
my $content = $q->param('content');
print <<EOTH;
                    </select></td>
                </tr>
                <tr>
                    <td colspan="3" class="find-news"><b>в точном диапазоне</b></td>
                </tr>
                <tr>
                    <td class="tl">начало:</td>
                    <td align="left"><input type="text" name="stdate" size="10" maxlength="10" value="$stdate" class="input-txt"></td>
                    <td align="left">&nbsp;<input type="image" src="/img/date.gif" alt="Задать дату" value="задать" name="button" onclick="javascript:document.period.lag.selectedIndex=0;window.open('/cgi-bin/setdate.pl?elnum=stdate&formname=period','cal','width=300,height=200,scrollbars=no'); return false;">&nbsp;&nbsp;</td>
                </tr>
                <tr>
                    <td class="tl">конец:</td>
                    <td align="left"><input type="text" name="enddate" size="10" maxlength="10" value="$enddate" class="input-txt"></td>
                    <td align="left">&nbsp;<input type="image" src="/img/date.gif" alt="Задать дату" value="задать" name="button" onclick="javascript:document.period.lag.selectedIndex=0;window.open('/cgi-bin/setdate.pl?elnum=enddate&formname=period','cal','width=300,height=200,scrollbars=no'); return false;">&nbsp;&nbsp;</td>
                </tr>
            </table>
        </td>
    </tr>
    <tr>
        <td style="background: url(/img/index/center.gif) repeat-y right;" colspan="3" valign="top">
            <h6>либо</h6>
            <h5>по содержимому:</h5>
            <table align="left" cellpadding="0" cellspacing="0" border="0">
                <tr>
                    <td colspan="3" class="find-news"><b>введите текст</b></td>
                </tr>
                <tr>
                    <td colspan="3" align="left">
                    <input type="text" name="content" size="25" value="$content" class="input-txt"></td>
                </tr>
            </table>
        </td>
    </tr>
    <tr>
        <td width="150">&nbsp;</td>
        <td align="right">
        <a href="javascript:period.submit()" class="link-arc">Найти</a>&nbsp;<img src="/img/index/p_bot1.gif" width="31" height="27" border="0"></td>
        <td valign="top" align="right"><img src="/img/index/p_bot2.gif" width="10" height="27" border="0"></td>
    </tr>
</table>
<!-- search in news -->
EOTH

$dbh->disconnect;

