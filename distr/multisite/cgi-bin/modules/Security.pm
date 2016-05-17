#!/usr/bin/perl
#
#

# Модуль
package modules::Security;
use Exporter;
our @ISA=qw(Exporter);
our @EXPORT=qw(extract_act);
our @EXPORT_OK = qw();
our %EXPORT_TAGS = (
				actions => [qw(extract_act clean_session)],
				elements => [qw()],
					);
our $VERSION=1.9;
use strict;
use Digest::MD5 qw(md5_hex);
use HTML::Parser;
use modules::Settings;
use modules::DBfunctions;
our %FORM;
use vars qw(%ERROR $session $error $permission @act);

$modules::DBfunctions::dbh = connectDB();

################################################################################
################################### Actions ####################################
################################################################################

sub extract_act {
	my $exec = 0;
	$|++;
	# Create parser object
	my $p = HTML::Parser->new( api_version => 3,
							start_h => [\&_start, "self, tagname, attr, text"],
							end_h   => [\&_end,   "self, tagname"],
							text_h   => [\&_text,   "self, text"],
							ignore_tags => [qw(select textarea table head html body nobr b i u)]
						  );

	######## HTML::Parser handlers ########
	sub _start {
		my($self, $tagname, $attr, $text) = @_;
		return if $tagname !~ /form|input/;
		if ($tagname eq 'form' and $attr->{action} =~ /4site/) {
			$exec = 1
		}
		if ($tagname eq 'input' and $attr->{name} eq 'act') {
			#print "--> '".$attr->{name}."' -- ".$attr->{value}." ($exec)<br/>";
			push @modules::Security::act, $attr->{value}
		}
		if ($tagname eq 'input') {
			#print "--> '".$attr->{name}."' -- ".$attr->{value}." ($exec)<br/>";
			push @modules::Security::act, $1 if $attr->{onclick} =~ /sub_del\([^,]+,'([^']+)'\)/
		}
	}
	sub _end {
		my($self, $tagname) = @_;
		$exec = 0 if $tagname eq 'form';
	}
	sub _text {
		my($self, $text, $is_cdata) = @_;
	}
	######## //HTML::Parser handlers ########
	use locale;
	my $txt = shift;
#	$txt =~ s!<select[^>]*>.+?</select>!!mig;
#	$txt =~ s!<textarea[^>]*>(|.+?)</textarea>!!mig;
#	$txt =~ s!</(table|tr|td)>!!mig;
#	$txt =~ s!<(table|tr|td)[^>]*?>!!mig;
#	$txt =~ s!<head>(.|\n)+</head>!!mi;
#	$txt =~ s!</?(html|body)[^>]*?>!!mig;
#	$txt =~ s!</?(nobr|b|i)>!!mig;
	$txt =~ s!<input\stype="(submit|text)"[^>]+?>!!mig;
	$txt =~ s!<input\stype="hidden"\sname="(_4SITESID|returnact|show|fform|gc|prev_act|prev_returnact|[^_]+_[ifld])"[^>]+?>!!mig;
	#modules::Debug::dump($txt);

	my @timestamp = (localtime)[0..5];
	$timestamp[5] += 1900;
	$timestamp[4]++;
	@timestamp[0..4] = map { ($_<10)?'0'.$_:$_ } @timestamp[0..4];
	my $ts_now = join "", @timestamp[5,4,3,2,1,0];
	$p->parse($txt);
	my %match;
	foreach (@act) { $match{$_}++ }
	#modules::Debug::dump(\%match);
	@act = keys %match;
	#my $id = $q->param('_4SITESID') || $q->cookie('_4SITESID');
	foreach (@act) {
		$modules::DBfunctions::dbh->do("INSERT INTO sessionactkey_tbl (session_fld,sessionactkey_fld,action_time_fld) VALUES ('".$session->id."','".md5_hex($session->id.$_)."',NOW())");
	}
}

sub clean_session {
	my @sess = glob $modules::Settings::c{dir}{cgi}."_session/cgisess_*";
	push @sess=>glob $modules::Settings::c{dir}{cgi}."_session/_4site_*";
	foreach (@sess) {
		unlink $_ if -M > 1;
	}
}

1;
__END__

=head1 NAME

B<Security.pm> — Модуль управления всеми вопросами, связанными с безопасностью Системы.

=head1 SYNOPSIS

Модуль управления всеми вопросами, связанными с безопасностью Системы.

=head1 DESCRIPTION

Модуль управления всеми вопросами, связанными с безопасностью Системы.

=head2 extract_act

Выжимка полей "act" из формы

=over 4

=item Вызов:

C<extract_act("text_to_extract");>

=item Пример вызова:

 extract_act($out);

=item Примечания:

Нет.

=item Зависимости:

L<HTML::Parser>.

=back

=head2 clean_session

Очистка папки C<_session> от файлов истекших сессий.

=over 4

=item Вызов:

C<clean_session();>

=item Пример вызова:

 clean_session();

=item Примечания:

Нет.

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
