
package ReRe::Response::JSONP;

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
    my $args = $self->args;
    my $json = JSON::XS->new;
    my ($callback) = @{$args};
    my $output = $json->encode( $self->data );
    $output = "$callback($output)" if $callback;
    return $output;
}

1;

