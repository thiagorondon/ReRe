
use Test::More tests => 7;

use FindBin qw($Bin);
my $usersconf = join('/', $Bin, 'etc', 'users.conf');

use_ok ( 'ReRe::ACL' );

my $acl = ReRe::ACL->new({ file => $usersconf });

isa_ok($acl, 'ReRe::ACL');

$acl->process;

ok($acl->has_role('userro', 'get'));
ok(!$acl->has_role('userro', 'set'));
ok($acl->has_role('userrw', 'set'));
ok($acl->has_role('userrw', 'get'));
ok($acl->has_role('userall', 'get'));


