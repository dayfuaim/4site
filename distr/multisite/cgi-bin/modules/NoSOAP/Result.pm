package modules::NoSOAP::Result;

our @ISA=qw(Exporter);
our @EXPORT=qw(_die new);
our @EXPORT_OK = qw(setResult result setParams paramsout faultstring);
our %EXPORT_TAGS = (
					result => [qw(setResult setParams new result paramsout faultstring)]
);
our $VERSION=1.00;
use strict;

sub new {
	my $invocant = shift;
	my $class = ref($invocant) || $invocant;
	my $self = {};
	bless($self,$class);
	$self->{result} = '';
	$self->{paramsout} = [];
	$self->{faultstring} = '';
	return $self
}

sub setResult {
	my $self = shift;
	$self->{result} = shift
}

sub result {
	my $self = shift;
	$self->{faultstring} = '';
	return $self->{result}
}

sub setParams {
	my $self = shift;
	$self->{paramsout} = [ @_ ]
}

sub paramsout {
	my $self = shift;
	$self->{faultstring} = '';
	return @{$self->{paramsout}}
}

sub _die {
	my $self = shift;
	$self->{faultstring} = shift;
	return $self->{faultstring}
}

sub fault() {
	my $self = shift;
	return ($self->{faultstring} ne '');
}

sub faultstring() {
	my $self = shift;
	return $self->{faultstring}
}

1;
