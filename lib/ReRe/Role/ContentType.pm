
package ReRe::Role::ContentType;

use strict;
use Moose::Role;

# VERSION

requires 'content_type';
requires 'pack';
requires 'unpack';

has data => (
    is      => 'rw',
    isa     => 'Any',
    default => ''
);

has args => (
    is      => 'rw',
    isa     => 'ArrayRef',
    default => sub { [] }
);

1;

