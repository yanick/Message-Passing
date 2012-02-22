package Log::Stash;
use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Types::Common::String qw/ NonEmptySimpleStr /;
use MooseX::Types::LoadableClass qw/ LoadableClass /;
use String::RewritePrefix;
use AnyEvent;
use JSON::XS;
use namespace::autoclean;
use 5.8.4;

with 'MooseX::Getopt';

our $VERSION = '0.001';
$VERSION = eval $VERSION;

my %things = (
    Input  => 1,
    Filter => 0,
    Output => 1,
);

foreach my $name (keys %things ) {
    my $class = subtype LoadableClass, where { 1 };
    coerce $class,
        from NonEmptySimpleStr,
        via {
            to_LoadableClass(String::RewritePrefix->rewrite({
                '' => 'Log::Stash::' . $name . '::',
                '+' => ''
            }, $_));
        };

    has lc($name) => (
        isa => $class,
        is => 'ro',
        required => $things{$name},
        coerce => 1,
    );
}

my $json_type = subtype
  as "Str",
  where { ref( eval { JSON::XS->new->relaxed->decode($_) } ) ne '' },
  message { "Must be at least relaxed JSON" };

foreach my $name (map { lc($_) . "_filter"  } keys %things) {
    has $name => (
        isa => $json_type,
        is => 'ro'
    );
}

1;

=head1 NAME

Log::Stash - a perl subset of Logstash <http://logstash.net>

=head1 SYNOPSIS

    logstash --input STDIN --output STDOUT
    {"foo": "bar"}
    {"foo":"bar"}

=head1 DESCRIPTION

A lightweight but interoperable interoperable subset of logstash
L<http://logstash.net>

This implementation is currently a sketch, and as such should be considered
pre alpha and subject to change at any point.

=head1 SEE ALSO

=head2 INPUTS

All of the below are coming real soon.

=over

=item L<Log::Stash::Input::STDIN> - For testing!

=item L<Log::Stash::Input::AMQP>

=item L<Log::Stash::Input::ZeroMQ>

=back

=head2 OUTPUTS

=over

=item L<Log::Stash::Output::STDOUT> - For testing!

=item L<Log::Stash::Output::AMQP>

=item L<Log::Stash::Output::ZeroMQ>

=item L<Log::Stash::Output::WebHooks>

=back

=head1 AUTHOR

Tomas (t0m) Doran <bobtfish@bobtfish.net>

=head1 SPONSORSHIP

This module exists due to the wonderful people at
L<Suretec Systems|http://www.suretecsystems.com/> who sponsored it's
development.

=head1 COPYRIGHT

Copyright Suretec Systems 2012.

Logstash (upon which many ideas for this project is based, but
which we do not reuse any code from) is copyright 2010 Jorden Sissel.

=head1 LICENSE

XX - TODO

=cut


