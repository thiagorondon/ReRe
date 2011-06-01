
use Test::More tests => 3;
use Test::Mojo;

use FindBin;
require "$FindBin::Bin/../bin/rere_server.pl";

my $t = Test::Mojo->new;
$t->get_ok('/login')->status_is(200)->content_like(qr/login/);

