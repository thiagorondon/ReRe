
package ReRe::Client;

use Moose;
use Mojo::UserAgent;
use Data::Dumper;

# VERSION

=head1 DESCRIPTION

This documentation lists commands which are exercised in test suite,
but additinal commands will work correctly since protocol specifies
enough information to support almost all commands with same peace of
code with a little help of C <AUTOLOAD> .

=cut

our $AUTOLOAD;

sub DESTROY { }

sub AUTOLOAD {
    my $self = shift;
    my $command = $AUTOLOAD;
    $command =~ s/.*://;
    my @args = @_;
    $self->_get_rere($command, @args);
}

has url => (
    is => 'rw',
    isa => 'Str',
    required => 1
);

has username => (
    is => 'rw',
    isa => 'Str',
    default => ''
);

has password => (
    is => 'rw',
    isa => 'Str',
    default => ''
);

has ua => (
    is => 'rw',
    isa => 'Object',
    lazy => 1,
    default => sub { Mojo::UserAgent->new }
);

sub _get_rere {
    my $self = shift;
    my $method = shift;
    my $var = shift;
    my $value = shift;

    my $username = $self->username;
    my $password = $self->password;

    my $userpass = $username && $password ? "$username:$password\@" : '';
    my $base_url = "http://$userpass" .
        join('/', $self->url, 'redis', $method, $var);

    $base_url .= '/' . $value if $value;

    my $json = $self->ua->get($base_url)->res->json;
    return $json->{$method};
}

=head1 METHODS

The same of L<Redis>.

=cut

1;

