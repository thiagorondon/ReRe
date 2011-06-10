
package ReRe::ContentType;

use strict;
use Moose;
with 'MooseX::Traits';

# VERSION

has '+_trait_namespace' => ( default => 'ReRe::ContentType' );

no Moose;
1;

