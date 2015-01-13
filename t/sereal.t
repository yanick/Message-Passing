use strict;
use warnings;
use Test::More;
use Try::Tiny;

plan skip_all => "Sereal::Encoder or Sereal::Decoder not present"
    unless eval <<'END';
            use Sereal::Decoder;
            use Sereal::Encoder;
            1;
END

use Message::Passing::Filter::Decoder::Sereal;
use Message::Passing::Filter::Encoder::Sereal;
use Message::Passing::Output::Test;
use Message::Passing::Input::Null;
use Message::Passing::Output::Null;

my $cbct = Message::Passing::Output::Test->new;
my $cbc = Message::Passing::Input::Null->new(
    output_to => Message::Passing::Filter::Encoder::Sereal->new(
        output_to => Message::Passing::Filter::Decoder::Sereal->new(
            output_to => $cbct,
        ),
    ),
);

# Simulate dropping a message!
{
    local $cbc->output_to->{output_to} = Message::Passing::Output::Null->new;
    $cbc->output_to->consume({ foo => 'bar' });
}

is $cbct->message_count, 0;

subtest structure => sub {
    my $struct = { a => 'foo', b => [ 1,2,3] };
    $cbc->output_to->consume( $struct );

    is $cbct->message_count => 1, "message made it";
    is_deeply( ($cbct->messages)[-1], $struct, "content is good" ); 
};

{
    package MyObject;

    use Moo;

    has 'foo' => (
        is => 'ro',
    );

    sub pack { 
        return {
            foo => $_[0]->foo
        }
    }

}


subtest object => sub {
    my $o = MyObject->new( foo => 'bar' );
    $cbc->output_to->consume( $o );

    is $cbct->message_count => 2, "message made it";
    is_deeply( ($cbct->messages)[-1], $o, "content is good" ); 
};


done_testing;

