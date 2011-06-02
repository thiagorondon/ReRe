
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
    default => sub { ReRe::User->new( { file => '/etc/rere/users.conf' }) }
);

has server => (
    is => 'rw',
    isa => 'ReRe::Server',
    predicate => 'has_server',
);

=head1 DESCRIPTION

ReRe is a simple redis rest interface write in Perl and L<Mojolicious</a>,
with some features like:

=over

=item Access your Redis database directly from Javascript.

=item Config file for store users and access control list.

=item REST interface to make your life more easy in some world.

=item Support to run as daemon (simple web-service), CGI, FastCGI or PSGI.

=item Simple to install and use

=back

More information, you can read in L<http://www.rere.com.br>.

=head1 METHODS

=head2 start

Start ReRe.

=cut

sub start {
    my $self = shift;
    $self->user->process;
    my $config_server = '/etc/rere/server.conf';
    if (-r $config_server) {
        $self->server(ReRe::Server->new({ file => $config_server }));
    } else {
        $self->server(ReRe::Server->new);
    }
}

1;
