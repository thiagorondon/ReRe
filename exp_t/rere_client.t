
use Test::More tests => 3;
use ReRe::Client;

my $conn = ReRe::Client->new({ url => '127.0.0.1:3000' });

ok($conn);

is($conn->set('foo', '2'), 2);
is($conn->get('foo'), 2);

