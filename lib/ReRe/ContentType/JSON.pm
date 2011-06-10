
package ReRe::ContentType::JSON;

use Moose::Role;
use Mojo::JSON;

# VERSION

sub content_type { 'application/json' }

sub unpack {
}

sub pack {
    my $self = shift;
    my $json = Mojo::JSON->new;
    return $json->encode( $self->data );
}

1;

