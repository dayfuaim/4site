#!/usr/bin/perl

=head1 NAME

B<Settings.pl> — Модуль системных настроек (расположение файлов системы, настройки базы данных,
безопасность.)

=head1 SYNOPSIS

Модуль системных настроек (расположение файлов системы, настройки базы данных,
безопасность.)

=head1 DESCRIPTION

Модуль системных настроек (расположение файлов системы, настройки базы данных,
безопасность.)

=cut
package sitemodules::Settings;
use strict;
use Exporter;
our @ISA=qw(Exporter);
our @EXPORT=qw(%c);
our $VERSION=1.80;
use vars qw(%c);

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

=head3 C<secur>

Содержит хэш настроек безопасности.

=over 3

=item C<check_refer1>

Referer1 для проверки принадлежности вызвавшей страницы Системе.

=item C<check_refer2>

Referer2 для проверки принадлежности вызвавшей страницы Системе.

=item C<key>

Ключ для функций шифрования (L<encrypt|::Comfunctions/"encrypt">, L<decrypt|::Comfunctions/"decrypt">).

=back

=cut
# Настроечный хеш
my $base = "{site_ROOT}";
%c = (

    dir => {
        cgi => "$base/cgi-bin/",
		cgi_ref => "/cgi-bin",
        pagetemplate => "$base/cgi-bin/pagetemplate/",
		htdocs => "$base/htdocs",
        gallery => "$base/htdocs/img/gallery",
        gallery_rel => "/img/gallery",
           },

	mysql => {
		user => "{DB_user}",
		pass => "{DB_password}",
		database => "{site_DB}",
		host => "{DBhost}",
             },

	soap => {
		login => 'test',
		passwd => 'test',
	},

);

1;

=head1 AUTHOR

MethodLab && DAY.

=head1 BUGS

No known ones yet. ;))

=head1 SEE ALSO

=head1 COPYRIGHT

E<copy> Copyright 2003, MethodLab

=cut

