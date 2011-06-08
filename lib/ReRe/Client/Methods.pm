
package ReRe::Client::Methods;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION @EXPORT_FAIL);
require Exporter;

# VERSION

@ISA       = qw(Exporter);
@EXPORT_OK = qw(method_num_of_args);

my $methods = {
    set => { args => 2 },
    get => { args => 1 },
    'exists' => { args => 1 },
};

=head1 DESCRIPTION

=head2 method_num_of_args

Return the number of arguments the method need.

=cut

sub method_num_of_args {
    my $method = shift;
    return '' unless defined($methods->{$method});
    return $methods->{$method}{args} || 0;
}

1;

