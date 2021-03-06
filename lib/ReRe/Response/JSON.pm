
package ReRe::Response::JSON;

use strict;
use Moose::Role;
use JSON::XS;

# VERSION

=head1 METHODS

=head2 content_type

=cut

sub content_type { 'application/json' }

=head2 unpack

=cut

sub unpack {
}

=head2 pack

=cut

sub pack {
    my $self = shift;
    my $json = JSON::XS->new;
    return $json->encode( $self->data );
}

1;

