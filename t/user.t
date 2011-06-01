
use Test::More tests => 11;

use FindBin qw($Bin);
my $usersconf = join('/', $Bin, 'etc', 'users.conf');

use_ok ( 'ReRe::User' );

my $acl = ReRe::User->new({ file => $usersconf });

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

