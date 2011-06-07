
BEGIN {
    unless ( $ENV{RELEASE_TESTING} ) {
        require Test::More;
        Test::More::plan( skip_all => 'these tests are for release candidate testing' );
    }
}

use Test::More tests => 9;
use Test::Mojo;

use FindBin;
require "$FindBin::Bin/../bin/rere_server.pl";

my $t = Test::Mojo->new;
$t->post_ok('/redis/set/foo/1?callback=Callback')->status_is(200)->content_like(qr/Callback\({\"set\":\"OK\"}\)/);

$t->get_ok('/redis/del/foo?callback=Callback')->status_is(200)->content_like(qr/del/);

$t->post_ok('/redis/get/foo?callback=Callback')->status_is(200)->content_like(qr/null/);

