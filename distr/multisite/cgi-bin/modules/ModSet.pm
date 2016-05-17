#!/usr/bin/perl

package modules::ModSet;
use Exporter;
our @ISA=qw(Exporter);
our @EXPORT=qw(get_setting get_setting_hash);
our $VERSION=1.9;
use strict;

sub get_setting {
	my ($module,$name) = @_;
	return undef unless ($module && $name);
	return undef unless module_exists($module);
	my $value = $modules::Core::soap->getQuery("SELECT value_fld FROM ${module}_settings_tbl WHERE ${module}_settings_fld='$name'")->result;
	return $value;
}

sub get_setting_hash {
	my %hash;
	my $module = shift;
	return undef unless $module;
	return undef unless module_exists($module);
	my @r = $modules::Core::soap->getQuery("SELECT ${module}_settings_fld,value_fld FROM ${module}_settings_tbl")->paramsout;
	foreach (@r) {
		$hash{$_->[0]}=$_->[1];
	}
	return \%hash;
}

#### ��������� ������� (�� ��������������) ####
#
#

sub module_exists {
	my $module = shift;
	my $flg;
 	return $flg unless $modules::Core::soap;
	my $mod_exist = $modules::Core::soap->getQuery("SHOW TABLES LIKE '${module}_settings_tbl'")->result;
	$flg = 1 if $mod_exist;
	return $flg
}

1;
__END__

=head1 NAME

B<ModSet.pl> � ������ ��� ������ � ����������� ������ ������� �� �����.

=head1 SYNOPSIS

������ ��� ������ � ����������� ������ ������� �� �����.

=head1 DESCRIPTION

������ ��� ������ � ����������� ������ ������� �� �����.

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

=head1 AUTHOR

DAY, Method Lab.

=head1 BUGS

No known ones yet. ;))

=head1 SEE ALSO

=head1 COPYRIGHT

E<copy> Copyright 2003, Method Lab

=cut
