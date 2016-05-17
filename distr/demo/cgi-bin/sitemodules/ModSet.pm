#!/usr/bin/perl

=head1 NAME

B<ModSet.pl> — Модуль для работы с настройками других модулей на сайте.

=head1 SYNOPSIS

Модуль для работы с настройками других модулей на сайте.

=head1 DESCRIPTION

Модуль для работы с настройками других модулей на сайте.

=cut

package sitemodules::ModSet;
use Exporter;
our @ISA=qw(Exporter);
our @EXPORT=qw(get_setting get_setting_hash);
our $VERSION=1.00;
use strict;
use sitemodules::DBfunctions;

=head2 get_setting

Возвращает значение конкретной настройки модуля.

=over 4

=item Вызов:

C<&get_setting("имя_модуля","имя_настройки");>

=item Пример вызова:

 &get_setting("poll","show_results");

=item Примечания:

Нет.

=item Зависимости:

L<module_exists|"module_exists">.

=back

=cut
sub get_setting {
	my ($module,$name) = @_;
	return undef unless ($module && $name);
	return undef unless module_exists($module);
	my $value = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT value_fld FROM ${module}_settings_tbl WHERE ${module}_settings_fld='$name'");
	return $value;
}

=head2 get_setting_hash

Возвращает значение всех настроек для одного модуля.

=over 4

=item Вызов:

C<&get_setting_hash("имя_модуля");>

=item Пример вызова:

 &get_setting_hash("poll");

=item Примечания:

Нет.

=item Зависимости:

L<module_exists|"module_exists">.

=back

=cut
sub get_setting_hash {
	my %hash;
	my $module = shift;
	return undef unless $module;
	return undef unless module_exists($module);
	my $sth = $sitemodules::DBfunctions::dbh->prepare("SELECT ${module}_settings_fld,value_fld FROM ${module}_settings_tbl");
	$sth->execute();
	while (my @row = $sth->fetchrow_array) {
		$hash{$row[0]}=$row[1];
	}
	return \%hash;
}

#### Сервисные функции (не экспортируются) ####
#
#

=head2 module_exists

Проверяет наличие в БД таблицы настроек для модуля.

=over 4

=item Вызов:

C<&module_exists("имя_модуля");>

=item Пример вызова:

 &module_exists("poll");

=item Примечания:

Не экспортируется. Внутренняя функция.

=item Зависимости:

Нет.

=back

=cut
sub module_exists {
	my $module = shift;
	my $flg;
	my $mod_exist = $sitemodules::DBfunctions::dbh->selectrow_array("SHOW TABLES LIKE '${module}_settings_tbl'");
	$flg = 1 if $mod_exist;
	return ($flg==1)?1:undef;
}

1;

=head1 AUTHOR

MethodLab && DAY.

=head1 BUGS

No known ones yet. ;))

=head1 SEE ALSO

=head1 COPYRIGHT

E<copy> Copyright 2003-2004, MethodLab

=cut

