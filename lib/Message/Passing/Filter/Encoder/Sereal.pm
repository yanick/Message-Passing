package Message::Passing::Filter::Encoder::Sereal;
use Moo;
use Sereal::Encoder;
use Scalar::Util qw/ blessed /;
use Try::Tiny;
use Message::Passing::Exception::Encoding;
use namespace::clean -except => 'meta';

with qw/
    Message::Passing::Role::Filter
    Message::Passing::Role::HasErrorChain
/;

has sereal_args => (
    is => 'ro',
    default => sub { {} },
);

has _sereal => (
    is      => 'lazy',
    handles => [ 'encode'  ],
    default => sub {
        my $self = shift;
        return Sereal::Encoder->new( $self->sereal_args );
    },
);

sub filter {
    my ($self, $message) = @_;
    try {
        if (blessed $message) { # FIXME - This should be moved out of here!
            if ($message->can('pack')) {
                $message = $message->pack;
            }
            elsif ($message->can('to_hash')) {
                $message = $message->to_hash;
            }
        }
        $self->encode( $message );
    }
    catch {
        $self->error->consume(Message::Passing::Exception::Encoding->new(
            exception => $_,
            stringified_data => $message,
        ));
        return; # Explicitly drop the message from normal processing
    }
}

1;

=head1 NAME

Message::Passing::Role::Filter::Encoder::Sereal - Encodes data structures as Sereal for output

=head1 DESCRIPTION

This filter takes a hash ref or an object for a message, and serializes it to
L<Sereal>.

Plain refs work as expected, and classes providing either a 
C<pack()> or C<to_hash()> method. This means that anything based on
L<Log::Message::Structures> or L<MooseX::Storage> should be correctly
serialized.

=head1 METHODS

=head2 new( %args )

Constructor. On top of the generic filter arguments, accepts an optional C<sereal_args>, 
which will be used as the arguments for the constructor of the
underlying L<Sereal::Encoder> object.


=head2 filter( $message )

Performs the Serial encoding.


=head1 SEE ALSO

=over

=item L<Message::Passing>

=item L<Message::Passing::Manual::Concepts>

=back

=cut

