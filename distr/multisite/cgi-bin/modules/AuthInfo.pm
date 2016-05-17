#!/usr/bin/perl
#
package modules::AuthInfo;
our $VERSION = 1.9;
my @insert;
my $executor;
my @batch;

sub AUTOLOAD {
	my $self = shift;
	my $name = our $AUTOLOAD;
	return if $name =~ /::DESTROY$/;
	$name =~ s/.+::(.+)$/$1/;
	return $executor->$name(@insert,@_);
}

sub new {
	my $invocant = shift;
	my $class = ref($invocant) || $invocant;
	my $self = {};
	bless($self,$class);
	$executor = shift;
	@insert = @_;
	return $self
}

sub debug {
	my $self;
	my $out;
	$out .= qq{<p><b>}.__PACKAGE__.qq{</b>:<br/>};
	$out .= qq{&nbsp;&nbsp;executor: <i>}.$executor.qq{</i><br/>};
	$out .= qq{&nbsp;&nbsp;inserted params: <i>[}.(join ','=>@insert).qq{]</i><br/>};
	$out .= qq{</p>};
	return $out
}

sub addToBatch {
	my $self = shift;
	my $sql = shift;
	return unless $sql;
	push @batch,$sql
}

1;
__END__

=head1 NAME

B<AuthInfo.pm> � �����-"������" ��� SOAP-�����������.

=head1 SYNOPSIS

 my $object = SomeClass->new();
 my @extraParams = ('foo',1,'bar');
 my $newObject = modules::Authinfo->new($object,@extraParams);
 $newObject->method(@params);
 # makes: $object->method(@extraParams,@params)

=head1 DESCRIPTION

������ ������ �������� ������� �������-"�������", ����� ��������� ��������� �������� ������ ���������� ������, �� �� �������� ����� ���������� (����� � ��� ��) ����� ����������� ���� �������. ������, �������� �� ������, ����� ��� ����� ��� �������� � ������� ������������, � ������� ���������� ��������� ���� �� �� � ������ ������, �� � �� �� ����� ������� �������� ����� ���������� (��������� �� ��� ������������ �� ��������� ������ ����).

������� ����� �� C<Class::Wrapper> (F< http://search.cpan.org/~hema/Class-Wrapper-0.22/ >).

��� ������������� ��������� ��������� ������� ������ � ������ ����������, ������� ����� ��������:

 my $object = SomeClass->new();
 my @extraParams = ('foo',1,'bar');
 my $newObject = modules::AuthInfo->new($object,@extraParams);

����� ����� ����� �������� (C<$newObject>) ����� ������������ ��������� ��� ��, ��� � "������" (C<$object>), � ��� ��������, ��� �� ��������, ���� ������ -- ������ ���������� ������� ������ ��� ����������.

=head1 AUTHOR

DAY, Method Lab.

=head1 BUGS

No known ones yet. ;))

=head1 SEE ALSO

=head1 COPYRIGHT

E<copy> Copyright 2004-2008, Method Lab

=cut
