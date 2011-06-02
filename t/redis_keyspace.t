
use Test::More tests => 11;
use Test::Mojo;

use FindBin;
require "$FindBin::Bin/../bin/rere_server.pl";

my $t = Test::Mojo->new;

$t->get_ok('/redis/set/foo/1')->status_is(200);

$t->get_ok('/redis/dbsize')->status_is(200)->content_like(qr/{"dbsize":/);

$t->get_ok('/redis/randomkey')->status_is(200)->content_like(qr/{"randomkey":/);

$t->get_ok('/redis/keys/foo')->status_is(200)->content_like(qr/{"keys"/);


