#!/usr/bin/perl

package Calendar;
use Exporter;
use Time::localtime;
use POSIX qw(strftime);
our @ISA=qw(Exporter);
our @EXPORT=qw(mkCalendar);
our $VERSION=1.9;
use strict;
use modules::Debug;

sub new {
	my $class=shift;
	my $self = {};
	bless($self,$class);
	$self->init(@_);
	return $self
}

sub init {
	my $self=shift;
	my $elnum=shift;
	my $formName=shift;

	#* CONFIG **/
	$self->{intCalWidth} = "100%";
	# Element number - where to insert date value
	$self->{intElNumber} = 1;
	# Имя формы в которую вставляется дата
	$self->{strFormName} = undef;

	$self->{intElNumber} = $elnum;

	$self->{selfName} = $ENV{'SCRIPT_NAME'};

	if ($formName) {
		$self->{strFormName}=$formName;
	}
}

#* MAIN sub **/
sub mkCalendar {
	my $self = shift;
	my ($intYear,$intMonth,$intDay) = @_;
	my ($nextYear,$prevYear);

	$intYear ||= localtime->year()+1900;
	$intMonth = localtime->mon() unless defined $intMonth;
	$intDay ||= localtime->day();
	my $daysInYear = strftime("%j",0,0,0,31,11,$intYear);
	my $intMonthTS = int(strftime("%j",0,0,0,1,$intMonth,$intYear));
	my $intNextMonth1 = int(strftime("%j",0,0,0,1,$intMonth+1,$intYear));

	my $intDaysInMonth = ($intNextMonth1>$intMonthTS)?$intNextMonth1-$intMonthTS:$daysInYear+$intNextMonth1-$intMonthTS;
	my $intDayMonthStarts = int(strftime("%w",0,0,0,1,$intMonth,$intYear-1900));

	my $nextMonth = $intMonth + 1;
	if ($nextMonth > 11) {
		$nextMonth = 0;
		$nextYear = $intYear + 1;
	} else {
		$nextYear = $intYear;
	}

	my $prevMonth = $intMonth - 1;
	if ($prevMonth < 0) {
		$prevMonth = 11;
		$prevYear = $intYear - 1;
	} else {
		$prevYear = $intYear;
	}

	my $calWidth = 0 ? $self->{intCalWidth} : qq{width="$self->{intCalWidth}"};
	print qq{<html>
	<head>
		<title>Календарь $VERSION</title>
		<META HTTP-EQUIV="Pragma" CONTENT="no-cache">
		<META HTTP-EQUIV="Expires" CONTENT="-1">
		<link href="/date.css" rel="stylesheet" type="text/css">
	</head>
<!---
class.Calendar by Jurgen Lang - www.getinspired.at
	[ported to Perl by DAY]
--->
	<script language="javascript" src="/js/script.js"></script>
	<script type="text/javascript" language="JavaScript" src="/js/esc.js"></script>
	<script language="javascript" src="/js/klayers.js"></script>
	<script language="javascript" src="/js/prototype.js"></script>
	<script type="text/javascript">
	function centerWin() {
		var ww = getWindowWidth()
		var wh = getWindowHeight()
		var pw = getWindowWidth(window.opener)
		var ph = getWindowHeight(window.opener)
		window.moveTo((pw-ww)/2,(ph-wh)/2)
		window.resizeTo(layer('maincal').getWidth()+26,layer('maincal').getHeight()+48)
	}
	</script>
	<body leftmargin="10" rightmargin="10" topmargin="5" bottommargin="5" onload="centerWin();">
	<TABLE $calWidth id="maincal" border="0" cellpadding="2" cellspacing="0" align="top">
		<TR>
			<TD style="padding-bottom: 8px" valign="top">
				<TABLE border="0" cellpadding="4" cellspacing="0" align="center">
					<FORM name="CalOptions" method="POST">
						<input type="hidden" name="elnum" value="$self->{intElNumber}">
						<input type="hidden" name="formname" value="$self->{strFormName}">
						<TR>
							<TD align="center" nowrap="nowrap"><a href="$self->{selfName}?currYear=$prevYear&currMonth=$prevMonth&elnum=$self->{intElNumber}&formname=$self->{strFormName}"><img src="/img/arrow_left1.gif" border="0" class="button" onmouseover="this.src='/img/arrow_left2.gif'" onmouseout="this.src='/img/arrow_left1.gif'"></a></TD>
							<TD align="center" nowrap="nowrap" class="red">
							<SELECT name="currMonth" class="SelectMisc" onChange="location.href = '$self->{selfName}?currYear=' + document.CalOptions.currYear.value + '&currMonth=' + this.value + '&elnum=$self->{intElNumber}&formname=$self->{strFormName}';">
};

	my @mnth = qw(Январь Февраль Март Апрель Май Июнь Июль Август Сентябрь Октябрь Ноябрь Декабрь);
	for my $m (0..11) {
		print qq{<option value="$m"}.($m==$intMonth?' selected':'').qq{>$mnth[$m]</option>}
	}
	print qq{
		</SELECT>
		<SELECT name="currYear" class="SelectMisc" onChange="location.href='$self->{selfName}?currYear='+this.value+'&currMonth='+document.CalOptions.currMonth.value+ '&elnum=$self->{intElNumber}&formname=$self->{strFormName}'">
	};
	for (localtime->year()-6+1900 .. localtime->year()+10+1900) {
		print qq{<OPTION value="$_"}.(($intYear==$_)?' selected':'').qq{>$_</option>}
	}
	print qq{					</TD>
							<TD align="center" nowrap="nowrap"><a href="$self->{selfName}?currYear=$nextYear&currMonth=$nextMonth&elnum=$self->{intElNumber}&formname=$self->{strFormName}"><img src="/img/arrow_right1.gif" border="0" class="button" onmouseover="this.src='/img/arrow_right2.gif'" onmouseout="this.src='/img/arrow_right1.gif'"></a></TD>
						</TR>
						</FORM>
					</TABLE>
				</TD>
			</TR>
			<TR>
				<TD valign="top">
					<TABLE width="100%" border="0" cellpadding="0" cellspacing="0" class="week">
						<TR>
							<TD align="center" class="week">Пн</TD>
							<TD align="center" class="week">Вт</TD>
							<TD align="center" class="week">Ср</TD>
							<TD align="center" class="week">Чт</TD>
							<TD align="center" class="week">Пт</TD>
							<TD align="center" class="week-end"><B>Сб</B></TD>
							<TD align="center" class="week-end"><B>Вс</B></TD>
						</TR>
						<TR>
	};
	# Check if Sunday is first Day of Month
	if ($intDayMonthStarts == 0) {
		$intDayMonthStarts = 7;
	}

	for (1..($intDayMonthStarts-1)) {
		print qq{<TD align="center" }.(($_<6)?qq{bgcolor="$self->{strEmptyColor}"}:'class="orange"').qq{>&nbsp;</TD>}
	}
	my $intWeekDay=$intDayMonthStarts;

	my $mnth=sprintf "%02d",($intMonth<11)?$intMonth+1:12;
	for (my $i=1; $i<=$intDaysInMonth; $i++) {
		my $id = sprintf("%02d", $i);
		# Current Day
		my $currBGColor = '';
		if ($intWeekDay >= 6) {
			$currBGColor = 'class="orange"';
			# Saturday || Sunday
		}
		if (sprintf("%02d/%02d/%02d",localtime->mon()+1,$id,localtime->year()-100) eq strftime("%x",0,0,0,$intDay,$intMonth,$intYear-2000)) {
			$currBGColor = 'class="green"';
			# Normal Day
		}
		# Highlight selected Day
		my $DayPrepend = "";
		my $DayAppend = "";
		if ($i==$intDay) {
			$DayPrepend = $self->{strHighlightDayPrepend};
			$DayAppend = $self->{strHighlightDayAppend};
		}
		# Write Day
		print qq{
							<TD align="center" $currBGColor onmouseover="dayover(this)" onmouseout="dayout(this)" style="cursor: hand" onclick="opener.document.forms['$self->{strFormName}'].elements['$self->{intElNumber}'].value='$id.$mnth.$intYear';window.close();">$i</TD>
		};
		if ($intWeekDay == 7 && $i < $intDaysInMonth) {
			$intWeekDay = 0;
			print qq{
						</TR>
						<TR>
			};

		} elsif ($intWeekDay == 7 && $i == $intDaysInMonth) {
			$intWeekDay = 0;
			print qq{
						</TR>
			};
		} elsif ($i == $intDaysInMonth) {
			for ($intWeekDay..6) {
				print qq{<TD align="center" }.(($_<5)?qq{bgcolor="$self->{strEmptyColor}"}:'class="orange"').qq{>&nbsp;</TD>}
			}
			print qq{
						</TR>
			}
		}
		$intWeekDay++;
	}
	print qq{
					</TABLE>
				</TD>
			</TR>
		</TABLE>
<script language="JavaScript">
var curClass= '';
function dayover(obj) {
	if (obj.className=='green') { return }
	curClass = obj.className;
	obj.className = 'frame'
}
function dayout(obj) {
	if (obj.className=='green') { return }
	obj.className = curClass
}
</script>
		</body>
		</html>
	}
}

1;
__END__

=head1 NAME

B<Calendar.pm> — Модуль календаря

=head1 SYNOPSIS

Модуль календаря.

=head1 DESCRIPTION

Модуль календаря. лучше открывать в отдельном окне, поскольку при выборе закрывает за собой окно и возвращает значение в конкретный элемент конкретной формы. А точнее, в нужный элемент вызвавшей формы.

=head1 AUTHOR

DAY, Method Lab.

=head1 BUGS

No known ones yet. ;))

=head1 SEE ALSO

=head1 COPYRIGHT

E<copy> Copyright 2003, Method Lab

=cut

