#!/usr/bin/perl

=head1 NAME

B<Settings.pl> � ������ ��������� �������� (������������ ������ �������, ��������� ���� ������,
������������.)

=head1 SYNOPSIS

������ ��������� �������� (������������ ������ �������, ��������� ���� ������,
������������.)

=head1 DESCRIPTION

������ ��������� �������� (������������ ������ �������, ��������� ���� ������,
������������.)

=cut
package sitemodules::Settings;
use strict;
use Exporter;
our @ISA=qw(Exporter);
our @EXPORT=qw(%c);
our $VERSION=1.80;
use vars qw(%c);

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

=head3 C<secur>

�������� ��� �������� ������������.

=over 3

=item C<check_refer1>

Referer1 ��� �������� �������������� ��������� �������� �������.

=item C<check_refer2>

Referer2 ��� �������� �������������� ��������� �������� �������.

=item C<key>

���� ��� ������� ���������� (L<encrypt|::Comfunctions/"encrypt">, L<decrypt|::Comfunctions/"decrypt">).

=back

=cut
# ����������� ���
my $base = "{site_ROOT}";
%c = (

    dir => {
        cgi => "$base/cgi-bin/",
		cgi_ref => "/cgi-bin",
        pagetemplate => "$base/cgi-bin/pagetemplate/",
		htdocs => "$base/htdocs",
        gallery => "$base/htdocs/img/gallery",
        gallery_rel => "/img/gallery",
           },

	mysql => {
		user => "{DB_user}",
		pass => "{DB_password}",
		database => "{site_DB}",
		host => "{DBhost}",
             },

	soap => {
		login => 'test',
		passwd => 'test',
	},

);

1;

=head1 AUTHOR

MethodLab && DAY.

=head1 BUGS

No known ones yet. ;))

=head1 SEE ALSO

=head1 COPYRIGHT

E<copy> Copyright 2003, MethodLab

=cut

