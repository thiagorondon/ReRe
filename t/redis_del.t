
use Test::More tests => 9;
use Test::Mojo;

use FindBin;
require "$FindBin::Bin/../bin/rere_server.pl";

my $t = Test::Mojo->new;
$t->get_ok('/redis/set/foo/1')->status_is(200)->content_like(qr/{"set":{"foo":"1"}}/);

$t->get_ok('/redis/del/foo')->status_is(200)->content_like(qr/{"del":{"foo":"1"}}/);

$t->get_ok('/redis/get/foo')->status_is(200)->content_like(qr/{"get":{"foo":null}}/);

