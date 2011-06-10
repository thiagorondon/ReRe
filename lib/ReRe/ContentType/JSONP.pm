
package ReRe::ContentType::JSONP;

use Moose::Role;
use Mojo::JSON;

# VERSION

sub content_type { 'application/json' }

sub unpack {
}

sub pack {
    my $self = shift;
    my $args = $self->args;
    my $json = Mojo::JSON->new;
    my ($callback) = @{$args};
    my $output = $json->encode( $self->data );
    $output = "$callback($output)" if $callback;
    return $output;
}

1;

