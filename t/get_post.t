
BEGIN {
    unless ( $ENV{RELEASE_TESTING} ) {
        require Test::More;
        Test::More::plan( skip_all => 'these tests are for release candidate testing' );
    }
}

use Test::More tests => 9;


use FindBin;
require "$FindBin::Bin/../bin/rere_server.pl";

my $t = Test::Mojo->new;
$t->post_ok('/redis/set/foo/1')->status_is(200)->content_like(qr/OK/);

$t->get_ok('/redis/del/foo')->status_is(200)->content_like(qr/del/);

$t->post_ok('/redis/get/foo')->status_is(200)->content_like(qr/null/);

