
BEGIN {
    unless ( $ENV{RELEASE_TESTING} ) {
        require Test::More;
        Test::More::plan( skip_all => 'these tests are for release candidate testing' );
    }
}

use Test::More tests => 3;
use Test::Mojo;
use Mojo::IOLoop;
use FindBin;
require "$FindBin::Bin/../bin/rere_server.pl";

my $t = Test::Mojo->new;

$t->get_ok('/ws')->status_is(404);

my $ua = $t->ua;
my $loop = Mojo::IOLoop->singleton;
my $result;
$ua->websocket(
    '/ws' => sub {
        my $tx = pop;
        $tx->on_finish(sub { $loop->stop } );
        $tx->on_message(
            sub {
                my ($tx, $message) = @_;
                $result = $message;
                $tx->finish;
            }
        );
        $tx->send_message('ping');

    }
);
$loop->start;
ok $result;

