
use Test::More tests => 3;
use Test::Fatal 0.006 qw(dies_ok lives_ok);

use ReRe::Hook;

my $ps = ReRe::Hook->with_traits('PubSubHubbubPublisher')->new;

my $url = 'http://pubsubhubbub.appspot.com/publish';
dies_ok { $ps->add_url('adfa') };
lives_ok { $ps->add_url($url) };
is_deeply( [ $ps->all_urls() ], [$url] );

