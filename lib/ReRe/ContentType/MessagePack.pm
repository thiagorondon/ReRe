
package ReRe::ContentType::MessagePack;

use Moose::Role;
use Data::MessagePack;

# VERSION

sub content_type { 'application/msgpack' }

sub unpack {
    return Data::MessagePack->unpack ( shift->data );
}

sub pack {
    return Data::MessagePack->pack( shift->data );
}

1;

