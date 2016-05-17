#!/usr/bin/perl

=head1 NAME

B<PageRender.pm> — Модуль работы с файлами для вывода страниц.

=head1 SYNOPSIS

Модуль работы с файлами для вывода страниц.

=head1 DESCRIPTION

Модуль работы с файлами для вывода страниц. Содержит функцию, которая открывает файл шаблона,
разбирает его и подставляет его части в нужные места страницы.

=cut
# Модуль работы с файлами для вывода страниц
package sitemodules::Menu;
use Exporter;
our @ISA=qw(Exporter);
our @EXPORT=qw(tmenu);
our $VERSION=1.00;
use strict;
use sitemodules::Settings;
use sitemodules::DBfunctions;

################################################################################
################################### Elements ###################################
################################################################################

# Определение обработки элементов
sub tmenu { # Вывод меню первого уровня (одного элемента) наверху
	my ($cur_act,@pages) = @_;
	if ($cur_act) {
		return qq{$pages[2]}
	} else {
		return qq{<a class="menu1p" href="$pages[1]" title="$pages[4]">$pages[2]</a>}
	}
} # tmenu

1;

=head1 AUTHOR

MethodLab && DAY.

=head1 BUGS

No known ones yet. ;))

=head1 SEE ALSO

=head1 COPYRIGHT

E<copy> Copyright 2004, MethodLab

=cut

