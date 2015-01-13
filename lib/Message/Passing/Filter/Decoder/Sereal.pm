package Message::Passing::Filter::Decoder::Sereal;
use Moo;
use Sereal::Decoder;
use Try::Tiny;
use Message::Passing::Exception::Decoding;
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
    handles => [ 'decode' ],
    default => sub {
        my $s = shift;
        return Sereal::Decoder->new( $s->sereal_args );
    },
);

sub filter {
    my ($self, $message) = @_;
    try {
        $self->decode( $message )
    }
    catch {
        $self->error->consume(Message::Passing::Exception::Decoding->new(
            exception => $_,
            packed_data => $message,
        ));
        return; # Explicit return undef
    };
}

1;

=head1 NAME

Message::Passing::Role::Filter::Decoder::Sereal

=head1 DESCRIPTION

Decodes string messages from Sereal into data structures.

=head1 ATTRIBUTES

=head1 METHODS

=head2 new( %args )

Constructor. On top of the generic filter arguments, accepts an optional C<sereal_args>, 
which will be used as the arguments for the constructor of the
underlying L<Sereal::Decoder> object.

=head2 filter( $message )

Sereal-decodes the message supplied as a parameter.

=head1 SEE ALSO

=over

=item L<Message::Passing>

=item L<Message::Passing::Manual::Concepts>

=back

