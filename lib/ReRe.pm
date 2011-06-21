
package ReRe;

use Moose;
use ReRe::User;
use ReRe::Server;
use ReRe::Websocket;
use ReRe::Response;

use Try::Tiny;
use List::Util qw(first);

# ABSTRACT: Simple Redis Rest Interface
# VERSION

for my $item (qw/users server websocket/) {
    has "config_$item" => (
        is      => 'rw',
        isa     => 'Str',
        default => sub {
            my $options = [ "/etc/rere/$item.conf", "etc/$item.conf" ];
            my $found = first { -r } @$options;
            return $found if $found;
            die qq{Couldn't find a config file for $item, tried: }
              . join( ', ', @$options );
        }
    );
}

has user => (
    is   => 'ro',
    isa  => 'ReRe::User',
    lazy => 1,
    default =>
      sub { ReRe::User->new_with_config( configfile => shift->config_users ) }
);

has server => (
    is         => 'rw',
    isa        => 'ReRe::Server',
    lazy_build => 1,
    predicate  => 'has_server',
);

has websocket => (
    is      => 'rw',
    isa     => 'ReRe::Websocket',
    lazy    => 1,
    default => sub {
        ReRe::Websocket->new_with_config(
            configfile => shift->config_websocket );
    }
);

sub _build_server {
    my $self = shift;
    return ReRe::Server->new_with_config( configfile => $self->config_server );

}

=head1 DESCRIPTION

ReRe is a simple redis rest interface write in Perl and L<PSGI> interface,
with some features like:


=head2 What is ReRe ?

=over 4

=item Access your Redis database directly from Javascript.

=item Allows you to plugin other technologies: caching via varnish, proxying via HAProxy, authentication for APIs, etc. because HTTP is well supported.

=item Access control list for methods of redis ;

=item Support to run as daemon (simple web-server), CGI, FastCGI or PSGI ;

=item HTTP Basic Auth security

=item Support for GET and POST.

=item Support for JSONP.

=item HTTP 1.1 pipelining (fastcgi and psgi)

=item CIDR authentication

=item Bad support for Websockets

=item Hooking, you can alter the behavior of an request method.

=item L<ReRe::Client> for write client applications in Perl.

=item REST interface to make your life easy in some world ;

=item Simple to install and use

=back

=head2 What is not ReRe ?

Please, don't use this application if ...

=over 4

=item If you are looking for a local database for cache or key-value

=item If you are looking for performance.

=back

=head1 SYNOPSIS

=head2 Console

    # authentication by ip address.
    curl -L http://127.0.0.1:3000/redis/set/foo/bar
    {"set":{"foo":"bar"}}

    curl -L http://127.0.0.1:3000/redis/get/foo
    {"get":{"foo":"bar"}}

    curl -L http://127.0.0.1:3000/redis/info
    {"info":{"last_save_time":"1306939038", ... }}

    # authentication by http basic.
    curl --basic -u 'userro:userro' -L http://127.0.0.1:3000/redis/get/foo
    {"get":{"foo":"bar"}}

    # JSONP Callback.
    curl --basic -u 'userro:userro' -L
    http://127.0.0.1:3000/redis/get/foo\?callback=MyCB
    MyCB( {"get":{"foo":"bar"}} )

=head2 Perl

    use ReRe::Client;
    my $conn = ReRe::Client->new(
        {   url      => '127.0.0.1:3000',
            username => 'userro',
            password => 'userro'
        } );

    $conn->set( 'foo', '2' );

    $conn->get('foo')


See L<ReRe::Client> for more information.

=head1 Configuration

=head2 users.conf

    <users>
        <userro>
            password userro
            roles get
        </userro>

        <userrw>
            password userrw
            roles get set info
        </userrw>

        <userall>
            allow 127.0.0.1
            password userall
            roles all
        </userall>

        <userlocalnet>
            allow 192.168.0.0/24
            roles get info
        </userlocalnet>
    </users>

=head2 server.conf

    <server>
        host 127.0.0.1
        port 6379
        hooks Log
    </server>


=head1 Hooks

You can alter the behaivor of any method or create your own.

=head2 Example

    package ReRe::Hook::MyHook;
    use Moose::Role;

    sub _hook {
        my $self = shift;

        my $method = $self->method;
        my $args = $self->args;
        my $conn = $self->conn;

        if ( $method eq 'set' ) {
            my ( $key, $value ) = @{$args};

            if ( $key eq 'immutable' ) {
                return { err => 'this object is immutable' }
            }

            if ( $key eq 'semaphoro' ) {
                my $new_value = 0;
                $new_value = 1 if $value eq 'red';
                return $self->conn->set($key, $new_value)
            }
        }

    return 0; # if you want to process the origin method.
    }

    1;

=head1 Documentation

More information, you can read in L<http://www.rere.com.br>.

=head1 Development

ReRe is a open source project for everyone to participate. The code repository
is located on github. Feel free to send a bug report, a pull request, or a
beer.

L<http://www.github.com/maluco/ReRe>


=head1 METHODS

=head2 start

Start ReRe.

=cut

sub start {
    my $self = shift;
    $self->_check_config;
    $self->user->process;
    $self->server;
}

=head2 process

Process the request to redis server.

=cut

sub process {
    my ( $self, $request ) = @_;

    my $dbname   = $request->dbname;
    my $method   = $request->method;
    my $username = $request->username;
 
    return { err => 'no_permission' }
        unless $self->user->has_role( $username, $method );

    my $args     = $request->args;
    my $callback = $request->extra->get('callback');
    my $type     = $callback ? 'JSONP' : $request->type;

    my $ret = $self->server->execute( $method, @{$args} );
    my $data = { $method => ref($ret) eq 'ARRAY' ? [ @{$ret} ] : $ret };

    ReRe::Response->with_traits( '+ReRe::Role::Response', $type )->new(
        response_model => $request->response_model,
        data           => $data,
        args           => [$callback]
    );
}

sub _check_config {
    my $self = shift;

    $self->_error_config_users unless -r $self->config_users();
    try {
        $self->server->execute('ping');
    }
    catch {
        $self->_error_server_ping;
    };
}

sub _error_config_users {
    print "I don't find /etc/rere/users.conf\n";
    print "Please, see http://www.rere.com.br to how create this file.\n";
    exit -1;
}

sub _error_server_ping {
    print "I can't connect to redis server.\n";
    print "Please, see http://www.rere.com.br for more information.\n";
    exit -2;
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

