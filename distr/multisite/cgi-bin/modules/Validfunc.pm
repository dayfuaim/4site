#!/usr/bin/perl

package modules::Validfunc;
use Exporter;
our @ISA=qw(Exporter);
our @EXPORT=qw(%Validate);
our $VERSION=1.9;
use strict;
use modules::Validate;
use modules::Debug;
use vars qw(%Validate);

########################### Проверка данных форм ###############################

%Validate = (

page => sub { # Проверка соответствия значений заголовка и адреса требуемым диапазонам
	my $err = 0;
	$err += is_long("$modules::Security::FORM{label_fld}","Заголовок","1","255");
	$err += is_long("$modules::Security::FORM{url_fld}","URL","6","30000");
	if ($_[0]) {
		$err += is_url_valid($modules::Security::FORM{url_fld});
		$err += page_exists("$modules::Security::FORM{url_fld}");
	}
	return $err
}, # page

date => sub {
	my $err = 0;
	$err += is_date_valid($modules::Security::FORM{date_fld});
	return $err
}, # date

datetime => sub {
	my $err = 0;
	$err += is_datetime_valid($modules::Security::FORM{date_fld});
	return $err
}, # date

);

1;
__END__

=head1 NAME

B<Validfunc.pm> — Модуль проверки вводимых в форму данных. Вызывается из модуля L<Actions|Actions>.

=head1 SYNOPSIS

Модуль проверки вводимых в форму данных.

=head1 DESCRIPTION

Модуль проверки вводимых в форму данных. Он представляет собой описание хэша ссылок на анонимные
функции B<L<%Validate|"хэш %validate">>. Вызов всех функций осуществляется соответственно C<< $Validate{ключ}->() >>.
Далее перечислены ключи-ссылки. Пока, собственно, в нём только одна функция. :)

=head1 Хэш C<%Validate>

=head2 page

Проверка соответствия значений заголовка и адреса требуемым диапазонам.

=over 3

=item Вызов:

Способ вызова описан L<выше|"description">.

=item Примечания:

Получает входные данные из глобального хэша B<%FORM>.

=item Зависимости:

Использует функции L<Validate::is_long|::Validate/"is_long">, L<Validate::page_exists|::Validate/"page_exists">.

=back

=head1 AUTHOR

DAY, Method Lab.

=head1 BUGS

No known ones yet. ;))

=head1 SEE ALSO

=head1 COPYRIGHT

E<copy> Copyright 2003, Method Lab

=cut
