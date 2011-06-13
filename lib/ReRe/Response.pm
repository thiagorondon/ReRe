
package ReRe::Response;

use strict;
use Moose;
with 'MooseX::Traits';

# VERSION

has '+_trait_namespace' => ( default => 'ReRe::Response' );

no Moose;
1;

