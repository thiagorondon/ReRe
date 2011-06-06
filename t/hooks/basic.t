
use Test::More tests => 4;
use Test::Mock::Redis;

package ReRe::Hook::Test;
use Moose::Role;

sub _hook {
    my $self = shift;
    return [ $self->method, $self->args, $self->conn ];
}
1;

package main;

use_ok('ReRe::Hook');

my $conn = Test::Mock::Redis->new(server => 'foo');
my $class = ReRe::Hook->with_traits( '+ReRe::Role::Hook', 'Test' )
    ->new( method => 'set', args => [ ('foo', 'bar') ], conn => $conn  );

my ($p_method, $p_args, $p_conn) = @{$class->process};

is($p_method, 'set');
is(@{$p_args}, 2);
is(ref($p_conn), 'Test::Mock::Redis');

