#!/usr/bin/perl

=head1 NAME

B<ModSet.pl> � ������ ��� ������ � ����������� ������ ������� �� �����.

=head1 SYNOPSIS

������ ��� ������ � ����������� ������ ������� �� �����.

=head1 DESCRIPTION

������ ��� ������ � ����������� ������ ������� �� �����.

=cut

package sitemodules::ModSet;
use Exporter;
our @ISA=qw(Exporter);
our @EXPORT=qw(get_setting get_setting_hash);
our $VERSION=1.00;
use strict;
use sitemodules::DBfunctions;

=head2 get_setting

���������� �������� ���������� ��������� ������.

=over 4

=item �����:

C<&get_setting("���_������","���_���������");>

=item ������ ������:

 &get_setting("poll","show_results");

=item ����������:

���.

=item �����������:

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

���������� �������� ���� �������� ��� ������ ������.

=over 4

=item �����:

C<&get_setting_hash("���_������");>

=item ������ ������:

 &get_setting_hash("poll");

=item ����������:

���.

=item �����������:

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

#### ��������� ������� (�� ��������������) ####
#
#

=head2 module_exists

��������� ������� � �� ������� �������� ��� ������.

=over 4

=item �����:

C<&module_exists("���_������");>

=item ������ ������:

 &module_exists("poll");

=item ����������:

�� ��������������. ���������� �������.

=item �����������:

���.

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

