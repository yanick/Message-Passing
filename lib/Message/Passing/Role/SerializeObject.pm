package Message::Passing::Role::SerializeObject;

use strict;
use warnings;

use Scalar::Util qw/ blessed /;

use Moo::Role;

around filter => sub {
    my( $next, $self, $message ) = @_;

    if (blessed $message) {
        for ( qw/ pack to_hash / ) {
            next unless $message->can($_);
            $message = $message->$_;
            last;
        }
    }

    $self->$next( $message );

};


1;

__END__

=head1 NAME

Message::Passing::Role::SerializeObject - Automatically serialize objects

=hea1 DESCRIPTION

When used by an encoder filter, any object that implement a C<pack()> 
or C<to_hash()> method will automatically be serialized.


