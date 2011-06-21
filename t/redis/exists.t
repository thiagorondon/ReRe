
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
    my $req =
      HTTP::Request->new( POST => '/redis/set/foo/1' );
    my $res = $cb->($req);
    is $res->code,         200;
    is $res->content,      '{"set":"OK"}';
    is $res->content_type, 'application/json';

  };

test_psgi
  app    => $app,
  client => sub {
    my $cb = shift;
    my $req =
      HTTP::Request->new( GET => '/redis/exists/foo' );
    my $res = $cb->($req);
    is $res->code,         200;
    is $res->content,      '{"exists":"1"}';
    is $res->content_type, 'application/json';

  };

done_testing();


