
package ReRe::Server;

use Moose;
use Redis;
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
    warn $file;
    my $config = ReRe::Config->new( { file => $file } );
    $self->server( $config->{server}{host} ) if defined( $config->{server}{host} );
    $self->port( $config->{server}{port} )   if defined( $config->{server}{port} );
};

has server => (
    is      => 'rw',
    isa     => 'Str',
    default => '127.0.0.1'
);

has port => (
    is      => 'rw',
    isa     => 'Int',
    default => '6379'
);

has conn => (
    is      => 'rw',
    isa     => 'Object',
    lazy    => 1,
    default => sub {
        my $self = shift;
        my $host = join( ':', $self->server, $self->port );
        return Redis->new( server => $host );
    }
);

=head1 METHODS

=head2 execute

Wrapper for L<Redis>.

=cut

sub execute {
    my $self = shift;
    my $method = shift or return '';
    return @_ ? $self->conn->$method(@_) : $self->conn->$method;
}

1;

