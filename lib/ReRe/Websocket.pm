
package ReRe::Websocket;

use Moose;
use ReRe::Config;

# VERSION

has file => (
    is  => 'rw',
    isa => 'Str'
);

around 'file' => sub {
    my $orig = shift;
    my $self = shift;
    return $self->$orig() unless @_;
    my ($file) = shift;
    $self->_builder_file( ReRe::Config->new( { file => $file } ) );
};

has active => (
    is      => 'rw',
    isa     => 'Bool',
    default => '0'
);

sub _builder_file {
    my ( $self, $config ) = @_;
    my %parse = $config->parse;
    $self->$_( $parse{websocket}{$_} ) for grep { defined( $parse{server}{$_} ) } qw(active);
}

1;

