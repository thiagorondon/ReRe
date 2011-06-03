
BEGIN {
    unless ( $ENV{RELEASE_TESTING} ) {
        require Test::More;
        Test::More::plan( skip_all => 'these tests are for release candidate testing' );
    }
}

use Test::More tests => 15;
use Test::Mojo;

use FindBin;
require "$FindBin::Bin/../bin/rere_server.pl";

my $t = Test::Mojo->new;
$t->get_ok('/redis/set/foo/1')->status_is(200)->content_like(qr/OK/);

$t->get_ok('/redis/incr/foo')->status_is(200)->content_like(qr/2/);

$t->get_ok('/redis/get/foo')->status_is(200)->content_like(qr/2/);

$t->get_ok('/redis/decr/foo')->status_is(200)->content_like(qr/1/);

$t->get_ok('/redis/get/foo')->status_is(200)->content_like(qr/1/);

