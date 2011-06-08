package ReRe::Server;

use Moose;
with 'MooseX::SimpleConfig';
use Redis;
use ReRe::Hook;
use ReRe::Client::Methods qw(method_num_of_args);

# VERSION

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
  is       => 'rw',
  isa      => 'Object',
  init_arg => undef,
  lazy     => 1,
  builder  => '_builder_conn'
);

has _hooks_args => (
  is        => 'ro',
  predicate => '_has_hooks_args',
  init_arg  => 'hooks'
);

has hooks => (
  is         => 'ro',
  isa        => 'ArrayRef',
  traits     => ['Array'],
  lazy_build => 1,
  handles    => {
    all_hooks => 'elements',
    add_hook  => 'push',
    find_hook => 'first'
  }
);

sub _build_hooks {
  my $self = shift;
  return [] unless $self->_has_hooks_args;
  return [ map { ReRe::Hook->with_traits($_)->new } $self->_hooks_args ];
}

sub _builder_conn {
  my $self = shift;
  my $host = join( ':', $self->host, $self->port );
  my $conn = Redis->new( server => $host );
  $conn->auth( $self->password ) if $self->has_password;
  return $conn;
}

=head1 METHODS

=head2 execute

Wrapper for L<Redis>.

=cut

sub execute {
  my $self    = shift;
  my $method  = shift or return '';
  my @in_args = @_;

# TODO: For performance reasons, this could be a lookup table:
# { method_foo => $hook_foo, method_bar => $hook_bar, method_quux => $hook_bar }

  if ( my $hook = $self->find_hook( sub { $_->can($method) } ) ) {
    my $ret;
    eval { $ret = $hook->$method( $self->conn, [@in_args] ) };
    warn $@ if $@;
    return $ret if $ret;
  }

  my $num_args = method_num_of_args($method);
  my @args;

  if ( $num_args and $num_args != scalar(@in_args) ) {
    $num_args--;
    push( @args, $in_args[$_] ? $in_args[$_] : '' ) for 0 .. $num_args;
  }
  else {
    @args = grep { !/^$/ } @in_args;
  }

  #use Data::Dumper;
  #warn Dumper($method, \@args);

  return @args ? $self->conn->$method(@args) : $self->conn->$method;
}

1;

