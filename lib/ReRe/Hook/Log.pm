
package ReRe::Hook::Log;
use strict;
use Moose::Role;
use Data::Dumper;

# VERSION

sub _hook {
    my $self = shift;

    warn $self->method;
    my $args = $self->args;
    if ( scalar( @{$args} ) ) {
        warn Dumper($args);
    }

}

1;

