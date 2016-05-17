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

B<AuthInfo.pm> Ч  ласс-"обЄртка" дл€ SOAP-авторизации.

=head1 SYNOPSIS

 my $object = SomeClass->new();
 my @extraParams = ('foo',1,'bar');
 my $newObject = modules::Authinfo->new($object,@extraParams);
 $newObject->method(@params);
 # makes: $object->method(@extraParams,@params)

=head1 DESCRIPTION

ƒанный модуль €вл€етс€ удобным классом-"обЄрткой", когда требуетс€ прозрачно вызывать методы некоторого класса, но со вставкой своих параметров (одних и тех же) перед параметрами этих методов. ѕричЄм, особенно он удобен, когда тот класс уже усто€лс€ и успешно используетс€, а вставка параметров требуетс€ чуть ли не в каждом методе, но в то же врем€ хочетс€ оставить класс неизменным (поскольку он уже используетс€ во множестве разных мест).

Ќемного похож на C<Class::Wrapper> (F< http://search.cpan.org/~hema/Class-Wrapper-0.22/ >).

ѕри инициализации принимает экземпл€р нужного класса и список параметров, которые нужно вставить:

 my $object = SomeClass->new();
 my @extraParams = ('foo',1,'bar');
 my $newObject = modules::AuthInfo->new($object,@extraParams);

ѕосле этого новым объектом (C<$newObject>) можно пользоватьс€ абсолютно так же, как и "старым" (C<$object>), с той разницей, что мы добились, чего хотели -- теперь происходит вставка нужных нам параметров.

=head1 AUTHOR

DAY, Method Lab.

=head1 BUGS

No known ones yet. ;))

=head1 SEE ALSO

=head1 COPYRIGHT

E<copy> Copyright 2004-2008, Method Lab

=cut
