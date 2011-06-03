
package ReRe;

use Moose;
use ReRe::User;
use ReRe::Server;

# ABSTRACT: Simple Redis Rest Interface
# VERSION

my $config_users = -r '/etc/rere/users.conf' ? '/etc/rere/users.conf' : 'etc/users.conf';

has user => (
    is => 'ro',
    isa => 'ReRe::User',
    lazy => 1,
    default => sub { ReRe::User->new( { file => $config_users }) }
);

has server => (
    is => 'rw',
    isa => 'ReRe::Server',
    predicate => 'has_server',
);

=head1 DESCRIPTION

ReRe is a simple redis rest interface write in Perl and L<Mojolicious>,
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


=head2 process

Process

=cut

sub process {
    my ($self, $method, $var, $value, $extra, $username) = @_;

#    return $self->render_json( { err => 'no_method' } )
#      unless $rere->server->has_method($method);

    return { err => 'no_permission' }
      unless $self->user->has_role( $username, $method );

    my $ret;
    if ( $method eq 'set' ) {
        $ret = $self->server->execute( $method, $var => $value );
    }
    elsif ( $extra ) {
        $ret = ( $self->server->execute( $method, $var, $value, $extra ) );
    }
    elsif ( $value ) {
        $ret = $self->server->execute( $method, $var, $value );
    }
    elsif ( $var ) {
        $ret = $self->server->execute( $method, $var );
    }
    else {
        $ret = $self->server->execute( $method );
    }
    return { $method => $ret };
}

1;

