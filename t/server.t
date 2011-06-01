
use Test::More tests => 5;
use Test::Mock::Redis;
use ReRe;

my $rere = ReRe->new;
$rere->start;
$rere->server->conn(Test::Mock::Redis->new(server => 'foo'));
ok($rere->has_server);
ok($rere->server->has_method('get'));
ok(!$rere->server->has_method('oisfjaoij23nsajsaoijd'));
ok($rere->server->execute('set', t => 1));
ok($rere->server->execute('get', 't'));
