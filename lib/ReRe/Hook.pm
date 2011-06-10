
package ReRe::Hook;

use strict;
use Moose;
with 'MooseX::Traits';

# VERSION

has '+_trait_namespace' => ( default => 'ReRe::Hook' );

=head1 DESCRIPTION

Hooking, you can alter the behavior of an request method. See L<ReRe::Hook::Log> for example.

=cut

no Moose;
1;

