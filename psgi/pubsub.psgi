

use Redis;

my $app = sub {
    my $env = shift;

    return sub {
        my $respond = shift;
        my $w = $respond->([ 200, ['Content-Type' => 'text/plain'] ]);
    
        my $redis = Redis->new;
        $redis->subscribe(
            'rere',
            sub {
                my ($message, $topic, $subscribed_topic) = @_;
                $w->write(time . ":$message\n");
            }
        );

        $redis->wait_for_messages(60) while 1;
        
    };
};
