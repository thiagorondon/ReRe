
package ReRe::Client;

use Moose;
use LWP::UserAgent;
use Data::Dumper;
use JSON;

# VERSION

=head1 DESCRIPTION

This client try to work the same as L<Redis>.

=cut

our $AUTOLOAD;

sub DESTROY { }

sub AUTOLOAD {
    my $self    = shift;
    (my $command = $AUTOLOAD) =~ s/.*://;;

    $self->_get_rere( $command, @_)
}

has url => (
    is       => 'rw',
    isa      => 'Str',
    required => 1
);

has username => (
    is      => 'rw',
    isa     => 'Str',
    default => ''
);

has password => (
    is      => 'rw',
    isa     => 'Str',
    default => ''
);

has ua => (
    is      => 'rw',
    isa     => 'Object',
    lazy    => 1,
    default => sub { LWP::UserAgent->new }
);

sub _get_rere {
    my ( $self, $method, $var, $value, $extra ) = @_;

    my $username = $self->username;
    my $password = $self->password;

    my $userpass = $username && $password ? "$username:$password\@" : '';
    my $base_url = "http://$userpass" . join( '/', $self->url, 'redis', $method, $var || "" );

    $base_url .= '/' . $value if defined($value);
    $base_url .= '/' . $extra if defined($extra);
    
    my $content = $self->ua->get($base_url)->decoded_content;
    my $json = from_json ($content);
    return $json->{$method};
}

=head1 METHODS

The same of L<Redis>.

=cut

1;

