
package ReRe::Websocket;

use Moose;
with 'MooseX::SimpleConfig';

# VERSION

has active => (
    is      => 'rw',
    isa     => 'Bool',
    default => '0'
);

1;

