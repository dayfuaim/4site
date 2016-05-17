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

########################### �������� ������ ���� ###############################

%Validate = (

page => sub { # �������� ������������ �������� ��������� � ������ ��������� ����������
	my $err = 0;
	$err += is_long("$modules::Security::FORM{label_fld}","���������","1","255");
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

B<Validfunc.pm> � ������ �������� �������� � ����� ������. ���������� �� ������ L<Actions|Actions>.

=head1 SYNOPSIS

������ �������� �������� � ����� ������.

=head1 DESCRIPTION

������ �������� �������� � ����� ������. �� ������������ ����� �������� ���� ������ �� ���������
������� B<L<%Validate|"��� %validate">>. ����� ���� ������� �������������� �������������� C<< $Validate{����}->() >>.
����� ����������� �����-������. ����, ����������, � �� ������ ���� �������. :)

=head1 ��� C<%Validate>

=head2 page

�������� ������������ �������� ��������� � ������ ��������� ����������.

=over 3

=item �����:

������ ������ ������ L<����|"description">.

=item ����������:

�������� ������� ������ �� ����������� ���� B<%FORM>.

=item �����������:

���������� ������� L<Validate::is_long|::Validate/"is_long">, L<Validate::page_exists|::Validate/"page_exists">.

=back

=head1 AUTHOR

DAY, Method Lab.

=head1 BUGS

No known ones yet. ;))

=head1 SEE ALSO

=head1 COPYRIGHT

E<copy> Copyright 2003, Method Lab

=cut
