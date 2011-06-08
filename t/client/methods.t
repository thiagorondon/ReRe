
use Test::More tests => 2;

use ReRe::Client::Methods qw(method_num_of_args);

is(method_num_of_args('set') , 2);
is(method_num_of_args('get') , 1);

