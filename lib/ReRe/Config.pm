
package ReRe::Config;

use Moose;
use Config::General;

# VERSION

has file => (
    is       => 'rw',
    isa      => 'Str',
    required => 1
);

sub parse {
    my $self = shift;
    my $file = $self->file;
    die "Where is config file: $file ?" unless -r $file;
    my $conf = new Config::General( $file );
    return $conf->getall;
}

1;

