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
package sitemodules::Menu;
use Exporter;
our @ISA=qw(Exporter);
our @EXPORT=qw(tmenu);
our $VERSION=1.00;
use strict;
use sitemodules::Settings;
use sitemodules::DBfunctions;

################################################################################
################################### Elements ###################################
################################################################################

# ����������� ��������� ���������
sub tmenu { # ����� ���� ������� ������ (������ ��������) �������
	my ($cur_act,@pages) = @_;
	if ($cur_act) {
		return qq{$pages[2]}
	} else {
		return qq{<a class="menu1p" href="$pages[1]" title="$pages[4]">$pages[2]</a>}
	}
} # tmenu

1;

=head1 AUTHOR

MethodLab && DAY.

=head1 BUGS

No known ones yet. ;))

=head1 SEE ALSO

=head1 COPYRIGHT

E<copy> Copyright 2004, MethodLab

=cut

