#!/usr/bin/perl
=head1 NAME

B<DBfunctions.pm> � ������ ������ � ��.

=head1 SYNOPSIS

������ ������ � ��.

=head1 DESCRIPTION

������ ������ � ��.

=cut

package sitemodules::DBfunctions;
use Exporter;
our @ISA=qw(Exporter);
our @EXPORT=qw(connectDB get_table_hash);
our $VERSION=1.80;
use strict;
use DBI;
use sitemodules::Settings;
use vars qw($dbh);

=head2 connectDB

���������� � ��.

=over 4

=item �����:

C<&connectDB;>

=item ������ ������:

 &connectDB;

=item ����������:

�������� ��������� �� ����������� ���� �������� L<%c|::Settings>.

=item �����������:

���.

=back

=cut
sub connectDB {
	my $dbi = "dbi:mysql:$sitemodules::Settings::c{mysql}{database}:$sitemodules::Settings::c{mysql}{host}";
	$dbh = DBI->connect( $dbi, $sitemodules::Settings::c{mysql}{user}, $sitemodules::Settings::c{mysql}{pass} );
	$dbh->do("SET NAMES cp1251");
	return $dbh;
	} # connectDB

=head2 get_table_hash

����������� ������� ������ �� ���� � ������������ �������.

=over 4

=item �����:

C<&get_table_hash("table_name w/o '_tbl'","WHERE clause w/o 'WHERE'","ORDER BY clause w/o 'ORDER BY'");>

=item ������ ������:

 &get_table_hash("page","page_id=8","url_fld");

=item ����������:

���.

=item �����������:

���.

=back

=cut
# get_table_hash  - ����������� �������
# �����: &get_table_hash("table_name w/o '_tbl'","WHERE clause w/o 'WHERE'","ORDER BY clause w/o 'ORDER BY'");
sub get_table_hash {
	my @out = ();
	my @fields;
	my ($main_table,$where_str,$order_str) = @_;
	return 0 unless $main_table;
	my $sth = $dbh->prepare("SHOW COLUMNS FROM ${main_table}_tbl");
	$sth->execute();
	while ( my @row = $sth->fetchrow_array ) { push @fields, $row[0] }
	my $fieldset = join "," => @fields;
	my $sql = "SELECT $fieldset FROM ${main_table}_tbl".(($where_str)?" WHERE $where_str":"").(" ORDER BY ".(($order_str)?"$order_str":"${main_table}_id"));
	$sth = $dbh->prepare($sql);
	$sth->execute();
	while (my $row_ref = $sth->fetchrow_hashref) {
		my %fld_hash=();
		foreach (@fields) { $fld_hash{$_}=$row_ref->{$_}; }
		push @out, \%fld_hash;
	}
	return @out;
} # get_table_hash

=head1 AUTHOR

MethodLab && DAY.

=head1 BUGS

No known ones yet. ;))

=head1 SEE ALSO

=head1 COPYRIGHT

E<copy> Copyright 2003-2004, MethodLab

=cut

1;

