#!/usr/bin/perl

package modules::Settings;
use strict;
use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION);
@ISA=qw(Exporter);
@EXPORT=qw(%c);
$VERSION=1.9;
use vars qw(%c);

# Настроечный хеш
my $base = "/home/httpd/multisite_clone";
%c = (
    dir => {
		cgi => "$base/pcgi/",
		cgi_ref => "/pcgi",
		template => "$base/pcgi/template/",
		interface => "$base/pcgi/interface/",
		htdocs => "$base/htdocs",
	},

	mysql => {
		user => "root",
		pass => "",
		database => "multisite",
		host => "localhost",
	},

);

1;
__END__

=head1 NAME

B<Settings.pm> — Модуль системных настроек (расположение файлов системы, настройки базы данных,
безопасность.)

=head1 SYNOPSIS

Модуль системных настроек (расположение файлов системы, настройки базы данных,
безопасность.)

=head1 DESCRIPTION

Модуль системных настроек (расположение файлов системы, настройки базы данных,
безопасность.)

=head2 Настроечный хэш C<%c>

В этом хэше собраны все системные настройки. Далее перечислены ключи:

=head3 C<dir>

Содержит хэш настроек путей.

=over 5

=item C<cgi>

Путь к директории C<cgi-bin>.

=item C<template>

Путь к директории с шаблонами форм.

=item C<pagetemplate>

Путь к директории с шаблонами частей страниц.

=item C<interface>

Путь к директории с шаблонами интерфейсов.

=item C<htdocs>

Путь к директории со всеми документами (страницы, стили и т.д.). По умолчанию — корень сайта.

=back

=head3 C<mysql>

Содержит хэш настроек MySQL.

=over 4

=item C<user>

=item C<pass>

=item C<database>

=item C<host>

Понятно, что здесь... :)

=back

=head1 AUTHOR

DAY, Method Lab.

=head1 BUGS

No known ones yet. ;))

=head1 SEE ALSO

=head1 COPYRIGHT

E<copy> Copyright 2003, Method Lab

=cut
