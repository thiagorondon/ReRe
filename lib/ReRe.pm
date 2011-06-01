
package ReRe;

use Moose;
use ReRe::ACL;
use ReRe::Server;

# ABSTRACT: Simple Redis Rest Interface
# VERSION

has acl => (
    is => 'ro',
    isa => 'ReRe::ACL',
    lazy => 1,
    default => sub { ReRe::ACL->new( { file => 'etc/users.conf' }) }
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
    $self->acl->process;
    $self->server(ReRe::Server->new);
}

1;
