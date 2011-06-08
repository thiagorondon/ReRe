
use Test::More;
use Test::Mock::Redis;

package ReRe::Hook::_Test;
use Moose::Role;

sub test {
  return 'test';
}
1;

package main;

use_ok('ReRe::Hook');

my $conn = Test::Mock::Redis->new( server => 'foo' );
my $hook = ReRe::Hook->with_traits('_Test')->new;

my $method = 'test';
is( $hook->$method($conn), 'test' );

done_testing;
