
use Test::More tests => 13;
Test::More::plan( skip_all => 'need to work');

use FindBin qw($Bin);
my $usersconf = join('/', $Bin, 'etc', 'users.conf');

use_ok ( 'ReRe::User' );

my $acl = ReRe::User->new_with_config( configfile => $usersconf );

isa_ok($acl, 'ReRe::User');

$acl->process;

ok($acl->has_role('userro', 'get'));
ok(!$acl->has_role('userro', 'set'));
ok($acl->has_role('userrw', 'set'));
ok($acl->has_role('userrw', 'get'));
ok($acl->has_role('userall', 'get'));

ok($acl->auth('userro', 'userro'));
ok(!$acl->auth('userrw', 'error'));

ok($acl->has_role('', 'get', '127.0.0.1'));
ok(!$acl->has_role('', 'set', '127.0.0.3'));

ok($acl->has_role('', 'get', '192.168.0.12'));
ok(!$acl->has_role('', 'get', '192.168.1.12'));

