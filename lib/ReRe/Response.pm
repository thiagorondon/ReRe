
package ReRe::Response;

use strict;
use Moose;
with 'MooseX::Traits';

# VERSION

has '+_trait_namespace' => ( default => 'ReRe::Response' );

has response_model => (
    is      => 'rw',
    isa     => 'Str',
    default => 'pull'
);

no Moose;
1;

