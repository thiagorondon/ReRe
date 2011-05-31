
package ReRe::Server;

use Moose;
use Redis;

has server => (
    is => 'rw',
    isa => 'Str',
    required => 1
);

has port => (
    is => 'rw',
    isa => 'Int',
    required => 1
);

has conn => (
    is => 'rw',
    isa => 'Object',
    lazy => 1,
    default => sub { 
        my $self = shift;
        my $host = join(/:/, $self->server, $self->port);
        return Redis->new(server => $host);
    }
);

1;

