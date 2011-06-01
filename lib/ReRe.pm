
package ReRe;

use Moose;
use ReRe::User;
use ReRe::Server;

# ABSTRACT: Simple Redis Rest Interface
# VERSION

has user => (
    is => 'ro',
    isa => 'ReRe::User',
    lazy => 1,
    default => sub { ReRe::User->new( { file => 'etc/users.conf' }) }
);

has server => (
    is => 'rw',
    isa => 'ReRe::Server',
    predicate => 'has_server',
);

=head1 METHODS

=head2 start

Start masterplan.

=cut

sub start {
    my $self = shift;
    $self->user->process;
    $self->server(ReRe::Server->new);
}

1;
