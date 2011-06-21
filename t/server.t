
use Test::More tests => 3;
use Test::Mock::Redis;
use ReRe;

my $rere = ReRe->new;
$rere->server->conn(Test::Mock::Redis->new(server => 'foo'));
$rere->start;
ok($rere->has_server);
ok($rere->server->execute('set', t => 1));
ok($rere->server->execute('get', 't'));

