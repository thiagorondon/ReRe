use strict;
use warnings;

BEGIN {
    unless ( $ENV{RELEASE_TESTING} ) {
        require Test::More;
        Test::More::plan(
            skip_all => 'these tests are for release candidate testing' );
    }
}

use FindBin qw($Bin);
my $path_app = "$Bin/../../psgi/rere.psgi";

use Test::More;
use Plack::Test;
use Plack::Loader;
use Plack::Request;

skip 'no app' unless -r $path_app;

$Plack::Test::Impl = "Server";
my $app = Plack::Util::load_psgi $path_app;

test_psgi
  app    => $app,
  client => sub {
    my $cb = shift;
    {
        my $req = HTTP::Request->new( POST => '/redis/del/bar' );
        my $res = $cb->($req);
        is $res->code,         200;
        is $res->content_type, 'application/json';
    }
    {
        my $req = HTTP::Request->new( GET => '/redis/rpush/bar/1' );
        my $res = $cb->($req);
        is $res->code,         200;
        is $res->content_type, 'application/json';
    }
    {
        my $req = HTTP::Request->new( GET => '/redis/lpush/bar/2' );
        my $res = $cb->($req);
        is $res->code,         200;
        is $res->content_type, 'application/json';
    }
    {
        my $req = HTTP::Request->new( GET => '/redis/llen/2' );
        my $res = $cb->($req);
        is $res->code, 200;

        #is $res->content, '{"llen":"0"}';
        is $res->content_type, 'application/json';
    }
    {
        my $req = HTTP::Request->new( GET => '/redis/lrange/bar/0/2' );
        my $res = $cb->($req);
        is $res->code,         200;
        is $res->content,      '{"lrange":["2","1"]}';
        is $res->content_type, 'application/json';
    }

  };

done_testing();

