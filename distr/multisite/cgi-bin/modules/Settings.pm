#!/usr/bin/perl

package modules::Settings;
use strict;
use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION);
@ISA=qw(Exporter);
@EXPORT=qw(%c);
$VERSION=1.9;
use vars qw(%c);

# ����������� ���
my $base = "/home/httpd/multisite_clone";
%c = (
    dir => {
		cgi => "$base/pcgi/",
		cgi_ref => "/pcgi",
		template => "$base/pcgi/template/",
		interface => "$base/pcgi/interface/",
		htdocs => "$base/htdocs",
	},

	mysql => {
		user => "root",
		pass => "",
		database => "multisite",
		host => "localhost",
	},

);

1;
__END__

=head1 NAME

B<Settings.pm> � ������ ��������� �������� (������������ ������ �������, ��������� ���� ������,
������������.)

=head1 SYNOPSIS

������ ��������� �������� (������������ ������ �������, ��������� ���� ������,
������������.)

=head1 DESCRIPTION

������ ��������� �������� (������������ ������ �������, ��������� ���� ������,
������������.)

=head2 ����������� ��� C<%c>

� ���� ���� ������� ��� ��������� ���������. ����� ����������� �����:

=head3 C<dir>

�������� ��� �������� �����.

=over 5

=item C<cgi>

���� � ���������� C<cgi-bin>.

=item C<template>

���� � ���������� � ��������� ����.

=item C<pagetemplate>

���� � ���������� � ��������� ������ �������.

=item C<interface>

���� � ���������� � ��������� �����������.

=item C<htdocs>

���� � ���������� �� ����� ����������� (��������, ����� � �.�.). �� ��������� � ������ �����.

=back

=head3 C<mysql>

�������� ��� �������� MySQL.

=over 4

=item C<user>

=item C<pass>

=item C<database>

=item C<host>

�������, ��� �����... :)

=back

=head1 AUTHOR

DAY, Method Lab.

=head1 BUGS

No known ones yet. ;))

=head1 SEE ALSO

=head1 COPYRIGHT

E<copy> Copyright 2003, Method Lab

=cut
