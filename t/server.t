
use Test::More tests => 1;
use Test::Mock::Redis;
use ReRe;

my $rere = ReRe->new;
$rere->server(Test::Mock::Redis->new(server => 'foo'));
ok($rere->has_server);


