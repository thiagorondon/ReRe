
BEGIN {
    unless ( $ENV{RELEASE_TESTING} ) {
        require Test::More;
        Test::More::plan( skip_all => 'these tests are for release candidate testing' );
    }
}

use Test::More tests => 11;
use Test::Mojo;

use FindBin;
require "$FindBin::Bin/../../bin/rere_server.pl";

my $t = Test::Mojo->new;

$t->get_ok('/redis/del/bar');

$t->get_ok('/redis/rpush/bar/1')->status_is(200);

$t->get_ok('/redis/lpush/bar/2')->status_is(200);

$t->get_ok('/redis/llen/bar')->status_is(200)->content_like(qr/{"llen":/);

$t->get_ok('/redis/lrange/bar/0/2')->status_is(200)->content_like(qr/"lrange":\["2","1"\]}/);

