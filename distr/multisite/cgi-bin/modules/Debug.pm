#!/usr/bin/perl

package modules::Debug;
use Exporter;
our @ISA=qw(Exporter);
our @EXPORT=qw(dump notice getCaller);
our $VERSION=1.9;
use strict;
use Data::Dumper;
use CGI qw(escapeHTML);

sub dump {
	use locale;
	my $obj = shift;
	my $head = shift || "";
	my $offset = shift || 0;
	my $debug = escapeHTML(Dumper($obj));
	$debug =~ s/\\x\{([0-9a-z]+)\}/chr(hex($1))/gei;
	my $out = qq{<pre class="debug"
	style="margin-left: }.(2+$offset*16).qq{px !important;">}.($head?qq{<b><u>$head:</u></b><br/>}:"").$debug."</pre>";
	if (wantarray() or defined wantarray()) {
		return $out
	} else {
		print $out
	}
}

sub notice {
	use locale;
	my $text = shift;
	my $head = shift || "";
	my $offset = shift || 0;
	$text =~ s/\\x\{([0-9a-z]+)\}/chr(hex($1))/gei;
	my $out = qq{<pre class="notice" style="margin-left: }.(2+$offset*16).qq{px !important;">}.($head?qq{<b><u>$head:</u></b><br/>}:"").$text."</pre>";
	if (wantarray() or defined wantarray()) {
		return $out
	} else {
		print $out
	}
}

sub getCaller {
	my @c = caller(1); #@{$_[0]};
	notice(qq{<b>$c[3]()</b> called from <b>$c[0]</b>:<b><u>$c[2]</u></b> ($c[1]).},"CALLER");
}

1;
__END__

=head1 NAME

B<Debug.pm> � ������ ��� ������ ���������� ���������.

=head1 SYNOPSIS

������ ��� ������ ���������� ���������.

=head1 DESCRIPTION

 use modules::Debug;

 my @array = (5,6,7,8);
 modules::Debug::dump(\@array,"ARRAY");

 my %hash = { qwerty => 'tetetetet' };
 modules::Debug::dump(\%hash,"HASH",1);

 modules::Debug::notice("Notice text","TITLE",1);

��������� ��������� � ������� Data::Dumper.

=head2 dump

B< C<dump(Object> >C<[,Title][,Offset]>B< C<)> >

����� �������� ���������� � ���������� ���������. �������� �������.

=over 4

=item Object

������ �� ���������� ���� ������.

=item Title

I<[��������������]> ��������� ���������.

=item Offset

I<[��������������]> ������ ��� ��������� ������, >=1. ���� ������, �� ����� ��� ��� �������.

=item ������ ������:

C<modules::Debug::dump(\%hash,"HASH",1);>

=back

=head2 notice

B< C<notice(Text> >C<[,Title][,Offset]>B< C<)> >

����� ����������� ���������. �������� �������.

=over 5

=item Text

�����.

=item Title

I<[��������������]> ��������� ���������.

=item Offset

I<[��������������]> ������ ��� ��������� ������, >=1. ���� ������, �� ����� ��� ��� �������.

=item ������ ������:

C<modules::Debug::dump("Notice","NOTICE",2);>

=item ����������:

�� L<"dump"> ���������� ���, ��� ��������� �����, � �� ����������.

=back

=head2 getCaller

C<getCaller()>

����� ���������� � ������ ������� �������/������.

=over 1

=item ������ ������:

C<modules::Debug::getCaller();>

=back

=head1 AUTHOR

DAY, Method Lab.

=head1 BUGS

No one at all. ;))

=head1 SEE ALSO

=head1 COPYRIGHT

E<copy> Copyright 2004-2008, Method Lab

=cut
