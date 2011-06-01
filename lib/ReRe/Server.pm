
package ReRe::Server;

use Moose;
use Redis;

# VERSION

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

=head1 METHODS

=cut

=head2 has_method

Check if method is available in L<Redis>.

=cut

sub has_method {
    my ($self, $method) = @_;
    return $self->conn->can($method);
}

=head2 execute

Wrapper for L<Redis>.

=cut

sub execute {
    my $self = shift;
    my $method = shift;
    $self->conn->$method(@_);
}

1;

