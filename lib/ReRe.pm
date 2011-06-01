
package ReRe;

use Moose;
use ReRe::ACL;

# ABSTRACT: Simple Redis Rest Interface
# VERSION

has acl => (
    is => 'ro',
    isa => 'ReRe::ACL',
    lazy => 1,
    default => sub { ReRe::ACL->new( { file => 'etc/users.conf' }) }
);

sub start {
    my $self = shift;
    $self->acl->process;
}


1;




