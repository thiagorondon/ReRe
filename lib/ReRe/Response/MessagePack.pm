
package ReRe::Response::MessagePack;

use strict;
use Moose::Role;
use Data::MessagePack;

# VERSION

=head1 METHOD

=head2 content_type

=cut
sub content_type { 'application/msgpack' }

=head2 unpack

=cut
sub unpack {
    return Data::MessagePack->unpack ( shift->data );
}

=head2 pack

=cut
sub pack {
    return Data::MessagePack->pack( shift->data );
}

1;

