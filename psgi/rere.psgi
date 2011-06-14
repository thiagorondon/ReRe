
use strict;
use warnings;
use Hash::MultiValue;
use Plack::Request;
use ReRe::Request;
use ReRe;

my $app = sub {
    my $env = shift;

    #    warn
    #"This app needs a server that supports psgi.streaming and psgi.nonblocking"
    #      unless $env->{'psgi.streaming'} && $env->{'psgi.nonblocking'};

    return sub {
        my $respond = shift;
        my $req     = Plack::Request->new($env);
        my $rere    = ReRe->new;

        my $request = ReRe::Request->new(
            {
                address        => $req->address,
                path_info      => $req->path_info,
                parameters     => $req->parameters,
                request_method => $req->method,
                username       => 'userall',
                type           => $req->param('type') || 'JSON',
                extra          => Hash::MultiValue->new(
                    callback => $req->param('callback') || ''
                ),
            }
        );

        my $w = $respond->(
            [
                200,
                [
                    'X-ReRe-Version' => $ReRe::VERSION,
                    'Content-Type'   => 'application/json' #$response->content_type
                ]
            ]
        );
        my $dbname = $request->dbname; 
        if ($request->method eq 'subscribe') {
            my $cb = sub {
                my ($message, $topic, $subscribed_topic) = @_;
                $w->write("$message\n");
            };
            
            $request->add_arg($cb);
            $rere->process($request);
            $rere->server->execute('wait_for_messages', 60) while 1;

        } else {
            my $response = $rere->process($request);

            return $w->write( $response->pack );
        }
    };
};

