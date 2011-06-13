
use strict;
use warnings;
use Plack::Request;
use ReRe;
use Data::Dumper;
use ReRe::ContentType;
use Try::Tiny;

my $rere = ReRe->new;

sub error_config_users {
    print "I don't find /etc/rere/users.conf\n";
    print "Please, see http://www.rere.com.br to how create this file.\n";
    exit -1;
}

sub error_server_ping {
    print "I can't connect to redis server.\n";
    print "Please, see http://www.rere.com.br for more information.\n";
    exit -2;
}

my $app = sub {
    my $env = shift;

    warn
"This app needs a server that supports psgi.streaming and psgi.nonblocking"
      unless $env->{'psgi.streaming'} && $env->{'psgi.nonblocking'};

    &error_config_users unless -r $rere->config_users();
    $rere->start;
    try {
        $rere->server->execute('ping');
    }
    catch {
        &error_server_ping;
    };

    return sub {
        my $respond   = shift;
        my $req       = Plack::Request->new($env);
        my $path_info = $req->path_info;
        my @chains    = split( '/', $path_info );
        my $query     = $req->param('query');

        my $root = shift(@chains);
        my $db       = shift(@chains) || 'redis';
        my $method   = shift(@chains)          || $req->param('method');
        my $var      = shift(@chains)          || $req->param('var');
        my $value    = shift(@chains)          || $req->param('value');
        my $extra    = shift(@chains)          || $req->param('extra');
        my $callback = $req->param('callback') || '';
        my $type     = $req->param('type')
          || 'JSON';    # text/xml, image/[png,jpeg], ...

        $type = 'JSONP' if $callback;
        
        warn 1;
        warn $method;

        # TODO: use Doorman
        #my $username = $rere->user->auth_ip( '' );
        #return $w->write('err: no_auth') unless $username;
        my $username = 'userall';

        my $data = $rere->process( $username, $method, $var, $value, $extra );
        my $content =
          ReRe::ContentType->with_traits( '+ReRe::Role::ContentType', $type )
          ->new( data => $data, args => [$callback] );

        my $w = $respond->(
            [
                200,
                [
                    'X-ReRe-Version' => 'Plack',
                    'Content-Type'   => $content->content_type
                ]
            ]
        );

        return $w->write( $content->pack );

        #$w->write("path_info: $path_info\n");
        #$w->write("query: $query\n");

    };
};

