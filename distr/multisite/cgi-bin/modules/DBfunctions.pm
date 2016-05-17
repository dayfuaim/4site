#!/usr/bin/perl
# Модуль работы с БД

package modules::DBfunctions;
use Exporter;
our @ISA=qw(Exporter);
our @EXPORT=qw($dbh connectDB get_table_hash get_erased_msg_text);
our $VERSION=1.9;

use strict;
use DBI;
use modules::Settings;
use vars qw($dbh);

sub connectDB {
	my $dbi = "dbi:mysql:$modules::Settings::c{mysql}{database}:$modules::Settings::c{mysql}{host}";
	$dbh = DBI->connect( $dbi, $modules::Settings::c{mysql}{user}, $modules::Settings::c{mysql}{pass} );
	$dbh->do("SET NAMES 'cp1251'");
#	$dbh->do("SET CHARACTER SET cp1251");
	return $dbh;
} # connectDB

# get_table_hash  - составление массива
# Вызов: &get_table_hash("table_name w/o '_tbl'","WHERE clause w/o 'WHERE'","ORDER BY clause w/o 'ORDER BY'");
sub get_table_hash {
	my @out = ();
	my @fields;
	my ($main_table,$where_str,$order_str) = @_;
	return () unless $main_table;
	my @r = $modules::Core::soap->getQuery("SHOW COLUMNS FROM ${main_table}_tbl")->paramsout;
	foreach (@r) { push @fields, $_->[0] }
	my $fieldset = join "," => @fields;
	my $sql = "SELECT $fieldset FROM ${main_table}_tbl".(($where_str)?" WHERE $where_str":"").(" ORDER BY ".(($order_str)?"$order_str":"${main_table}_id"));
	@r = $modules::Core::soap->getQueryHash($sql)->paramsout;
	foreach (@r) {
		my $row_ref = $_;
		my %fld_hash = map { $_ => $row_ref->{$_} } @fields;
		#foreach (@fields) { $fld_hash{$_} = $row_ref->{$_}; }
		push @out, \%fld_hash
	}
	return @out
} # get_table_hash

sub get_erased_msg_text {
	my ($table,$id) = @_;
	my ($msg_id,$text) = $dbh->selectrow_array("SELECT actionmsg_id, message_fld FROM actionmsg_tbl WHERE action_fld='$modules::Comfunctions::FORM{act}'");
	return " " unless $text;
	my @flds;
	my %tbl;
	my ($body,$tbl) = $table =~ /([^_]+)_([^_]+)$/;
	my $sth = $modules::Core::soap->getQuery("show columns from $table");
	$sth->execute();
	while (my @row = $sth->fetchrow_array) {
		push @flds,$row[0];
 	}
 	$sth->finish();
	my @vals = $dbh->selectrow_array("SELECT * FROM $table WHERE ${body}_id=$id");
	foreach (0..$#vals) {
		$tbl{$flds[$_]} = $vals[$_];
	}
	while (my ($fid,$ffld) = $text =~ /\{([^|]+)\|([^}]+)\}/) {
		$text =~ s/\{[^}]+\}/$tbl{$ffld}/;
	}
	return $text;
}

1;
__END__

=head1 NAME

B<DBfunctions.pm> — Модуль работы с БД.

=head1 SYNOPSIS

Модуль работы с БД.

=head1 DESCRIPTION

Модуль работы с БД.

=head2 connectDB

Соединение с БД.

=over 4

=item Вызов:

C<&connectDB;>

=item Пример вызова:

C<&connectDB;>

=item Примечания:

Получает параметры из глобального хэша настроек L<%c|::Settings>.

=item Зависимости:

Нет.

=back

=head2 get_table_hash

Составление массива ссылок на хэши с результатами запроса.

=over 4

=item Вызов:

C<&get_table_hash("table_name w/o '_tbl'","WHERE clause w/o 'WHERE'","ORDER BY clause w/o 'ORDER BY'");>

=item Пример вызова:

C<&get_table_hash("page","page_id=8","url_fld");>

=item Примечания:

Нет.

=item Зависимости:

Нет.

=back

=head2 get_erased_msg_text

Получение текста результата действия (action_msg) для операции удаления. Передаётся ID удаляемого элемента.

=over 4

=item Вызов:

C<&get_erased_msg_text("table_name","key ID таблицы");>

=item Пример вызова:

C<&get_erased_msg_text("counter_tbl",$FORM{counter_id});>

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
