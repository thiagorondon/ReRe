
package ReRe::Server;

use Moose;
use Redis;
use ReRe::Config;
use ReRe::Hook;
use ReRe::Client::Methods qw(method_num_of_args);

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

has host => (
    is      => 'rw',
    isa     => 'Str',
    default => '127.0.0.1'
);

has port => (
    is      => 'rw',
    isa     => 'Int',
    default => '6379'
);

has password => (
    is        => 'rw',
    isa       => 'Str',
    default   => '',
    predicate => 'has_password'
);

has conn => (
    is      => 'rw',
    isa     => 'Object',
    lazy    => 1,
    builder => '_builder_conn'
);

has hooks => (
    is      => 'ro',
    isa     => 'ArrayRef[Str]',
    traits  => ['Array'],
    default => sub { [] },
    handles => {
        all_hooks => 'elements',
        add_hook  => 'push'
    }
);

sub _builder_conn {
    my $self = shift;
    my $host = join( ':', $self->host, $self->port );
    my $conn = Redis->new( server => $host );
    $conn->auth( $self->password ) if $self->has_password;
    return $conn;
}

sub _builder_file {
    my ( $self, $config ) = @_;
    my %parse = $config->parse;
    $self->$_( $parse{server}{$_} ) for grep { defined( $parse{server}{$_} ) } qw(host port admin);

    map { $self->add_hook($_) } split( ' ', $parse{server}{hooks} )
        if defined( $parse{server}{hooks} );
}

=head1 METHODS

=head2 execute

Wrapper for L<Redis>.

=cut

sub execute {
    my $self    = shift;
    my $method  = shift or return '';
    my @in_args = @_;

    foreach my $hook ( $self->all_hooks ) {
        my $ret;
        eval {
            my $class
                = ReRe::Hook->with_traits( '+ReRe::Role::Hook', $hook )
                ->new( method => $method, args => [@in_args], conn => $self->conn );
            $ret = $class->process;
        };
        warn $@ if $@;
        return $ret if $ret;
    }

    my $num_args = method_num_of_args($method);
    my @args;

    if ($num_args and $num_args != scalar(@in_args)) {
        $num_args--;
        push( @args, $in_args[$_] ? $in_args[$_] : '' ) for 0 .. $num_args;
    }
    else {
        @args = grep { !/^$/ } @in_args;
    }

    #use Data::Dumper;
    #warn Dumper($method, \@args);

    return @args ? $self->conn->$method( @args ) : $self->conn->$method;
}

1;

