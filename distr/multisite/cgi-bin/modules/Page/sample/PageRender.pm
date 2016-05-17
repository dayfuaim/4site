#!/usr/bin/perl

=head1 NAME

B<PageRender.pm> � ������ ������ � ������� ��� ������ �������.

=head1 SYNOPSIS

������ ������ � ������� ��� ������ �������.

=head1 DESCRIPTION

������ ������ � ������� ��� ������ �������. �������� �������, ������� ��������� ���� �������,
��������� ��� � ����������� ��� ����� � ������ ����� ��������.

=cut
# ������ ������ � ������� ��� ������ �������
package sitemodules::PageRender;
use Exporter;
our @ISA=qw(Exporter);
our @EXPORT=qw(open_file_templ);
our $VERSION=1.80;
use strict;
use sitemodules::Settings;
use sitemodules::DBfunctions;

=head2 open_file_templ

�������� ������� ����� ��������.

=over 4

=item �����:

C<&open_file_templ("���_�������");>

=item ������ ������:

 &open_file_templ("tpoll");

=item ����������:

���.

=item �����������:

L<check_template_exist|"check_template_exist">, L<%PageElements::HoP|::PageElements>.

=back

=cut
# open_file_templ - �������� ������� ����� ��������
# �������������: &open_file_templ("���_�������");
sub open_file_templ {
	my $file_iface=shift;
	my $fpath = $sitemodules::Settings::c{dir}{pagetemplate}.$file_iface.".htm";
	my @sm = grep { s/^(.*\/)// } glob "$sitemodules::Settings::c{dir}{cgi}sitemodules/*.pm";
	@sm = grep { s/\.pm$// } @sm;
	foreach my $m (@sm) {
		next if $m eq 'PageRender';
		eval "use sitemodules::$m";
		print $@."<br>" if $@
	}
	my $fssi_temp;
	my $out;
	my @params = @_;
	open (FILE_TEM, "$fpath");
		while (<FILE_TEM>) {
		$fssi_temp = "$_";
		while ($fssi_temp =~ /\<\!--\#include\svirtual="([^"]+)"--\>/) {
			my $f = $1;
			my $remove = eval "$f(\@params)";
			unless ($@) {
				$fssi_temp =~ s/\<\!--\#include\svirtual="$f"--\>/$remove/g;
			} else {
				$fssi_temp =~ s/\<\!--\#include\svirtual="$f"--\>/������ �� ������� "$f"! ($@)/g;
			}
		}
		#print $fssi_temp;
		$out .= $fssi_temp;
		}
	close (FILE_TEM);
	return $out
} # open_file_templ

=head2 check_template_exist

�������� ������������� ����� ������� ("���.htm").

=over 4

=item �����:

C<&check_template_exist("���_�������");>

=item ������ ������:

 &check_template_exist($file_iface);

=item ����������:

���.

=item �����������:

���.

=back

=cut
sub check_template_exist {
	my $file_iface=shift;
	return (($file_iface) || -e $sitemodules::Settings::c{dir}{pagetemplate}.$file_iface);
} # check_template_exist

1;

=head1 AUTHOR

MethodLab && DAY.

=head1 BUGS

No known ones yet. ;))

=head1 SEE ALSO

=head1 COPYRIGHT

E<copy> Copyright 2004, MethodLab

=cut

