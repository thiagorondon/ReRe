
package ReRe::Server;

use Moose;
use Redis;

has server => (
    is => 'rw',
    isa => 'Str',
    default => '127.0.0.1'
);

has port => (
    is => 'rw',
    isa => 'Int',
    default => '6379'
);

has conn => (
    is => 'rw',
    isa => 'Object',
    lazy => 1,
    default => sub { 
        my $self = shift;
        my $host = join(':', $self->server, $self->port);
        return Redis->new(server => $host);
    }
);

sub execute {
    my $self = shift;
    my $method = shift;
    $self->conn->$method(@_);
}

1;

