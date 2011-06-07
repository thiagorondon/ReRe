
package ReRe;

use Moose;
use ReRe::User;
use ReRe::Server;
use ReRe::Websocket;

# ABSTRACT: Simple Redis Rest Interface
# VERSION


for my $item (qw/users server websocket/) {
    has "config_$item" => (
        is => 'rw',
        isa => 'Str',
        default => sub { -r "/etc/rere/$item.conf" ? "/etc/rere/$item.conf" : "etc/$item.conf" }
    );
}

has user => (
    is => 'ro',
    isa => 'ReRe::User',
    lazy => 1,
    default => sub { ReRe::User->new( { file => shift->config_users }) }
);

has server => (
    is => 'rw',
    isa => 'ReRe::Server',
    predicate => 'has_server',
);

has websocket => (
    is => 'rw',
    isa => 'ReRe::Websocket',
    lazy => 1,
    default => sub { ReRe::Websocket->new( { file => shift->config_websocket }) }
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

    my $instance = ReRe::Server->new;
    $instance->file($self->config_server) if -r $self->config_server;
    $self->server($instance);
}


=head2 process

Process the request to redis server.

=cut

sub process {
    my ($self, $method, $var, $value, $extra, $username) = @_;

    return { err => 'no_permission' }
      unless $self->user->has_role( $username, $method );

    my $ret = ( $self->server->execute( $method, $var, $value, $extra ) );
    return { $method => $ret };
}

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

perldoc ReRe
perldoc ReRe::Config
perldoc ReRe::Server
perldoc ReRe::User

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=ReRe>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/ReRe>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/ReRe>

=item * Search CPAN

L<http://search.cpan.org/dist/ReRe>

=back

=cut 

1;

