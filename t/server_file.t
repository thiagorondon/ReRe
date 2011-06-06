
use Test::More tests => 2;
use ReRe::Server;

use FindBin qw($Bin);
my $server_config = "$Bin/etc/server.conf";

my $rere = ReRe::Server->new({ file => $server_config });
is($rere->host(), '127.0.0.1');
is($rere->port(), '6379');

