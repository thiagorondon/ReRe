
package ReRe::Websocket;

use Moose;
with 'MooseX::SimpleConfig';
use ReRe::Config;

# VERSION

has active => (
    is      => 'rw',
    isa     => 'Bool',
    default => '0'
);

1;

