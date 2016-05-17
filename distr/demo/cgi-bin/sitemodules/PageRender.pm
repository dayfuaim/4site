#!/usr/bin/perl

package sitemodules::PageRender;
use Exporter;
our @ISA=qw(Exporter);
our @EXPORT=qw(open_file_templ);
our $VERSION=1.80;
use strict;
use sitemodules::Settings;
use sitemodules::DBfunctions;

# open_file_templ - открытие шаблона части страницы
# Использование: &open_file_templ("имя_шаблона");
sub open_file_templ {
	my $file_iface=shift;
	my $fpath = $sitemodules::Settings::c{dir}{pagetemplate}.$file_iface.".htm";
	my $fssi_temp;
	my $out;
	my @params = @_;
	open (FILE_TEM, "$fpath");
		while (<FILE_TEM>) {
		$fssi_temp = "$_";
		while ($fssi_temp =~ /\<\!--\#include\svirtual="([^"]+)"--\>/) {
			my $f = $1;
			my $remove;
			my ($mod,$meth) = split '::'=>$f;
			$remove = eval "use sitemodules::$mod; sitemodules::".$mod."::$meth(\@params)";
			unless ($@) {
				$fssi_temp =~ s/\<\!--\#include\svirtual="$f"--\>/$remove/g;
			} else {
				$fssi_temp =~ s/\<\!--\#include\svirtual="$f"--\>/Ошибка на функции "$f"! ($@)/g;
			}
		}
		#print $fssi_temp;
		$out .= $fssi_temp;
		}
	close (FILE_TEM);
	return $out
} # open_file_templ

sub check_template_exist {
	my $file_iface=shift;
	return (($file_iface) || -e $sitemodules::Settings::c{dir}{pagetemplate}.$file_iface);
} # check_template_exist

1;

__END__

=head1 NAME

B<PageRender.pm> — Модуль работы с файлами для вывода страниц.

=head1 SYNOPSIS

Модуль работы с файлами для вывода страниц.

=head1 DESCRIPTION

Модуль работы с файлами для вывода страниц. Содержит функцию, которая открывает файл шаблона,
разбирает его и подставляет его части в нужные места страницы.

=head2 open_file_templ

Открытие шаблона части страницы.

=over 4

=item Вызов:

C<&open_file_templ("имя_шаблона");>

=item Пример вызова:

 &open_file_templ("tpoll");

=item Примечания:

Нет.

=item Зависимости:

L<check_template_exist|"check_template_exist">, L<%PageElements::HoP|::PageElements>.

=back

=head2 check_template_exist

Проверка существования файла шаблона ("имя.htm").

=over 4

=item Вызов:

C<&check_template_exist("имя_шаблона");>

=item Пример вызова:

 &check_template_exist($file_iface);

=item Примечания:

Нет.

=item Зависимости:

Нет.

=back

=head1 AUTHOR

MethodLab && DAY.

=head1 BUGS

No known ones yet. ;))

=head1 SEE ALSO

=head1 COPYRIGHT

E<copy> Copyright 2004, MethodLab

=cut

