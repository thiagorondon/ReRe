
package ReRe::Request;

use Moose;
use Hash::MultiValue;

=head2 address

Returns the IP address of the client (REMOTE_ADDR).

=cut

has address => (
    is => 'rw',
    isa => 'Str',
    default => '127.0.0.1'
);

=head2 request_method

Contains the request method (GET, POST, HEAD, etc).

=cut

has request_method => (
    is => 'rw',
    isa => 'Str',
);

=head2 path_info

Returns PATH_INFO in the environment. Use this to get the local path for the requests.

=cut

has path_info => (
    is => 'rw',
    isa => 'Str',
    required => 1
);

has dbname => (
    is => 'rw',
    isa => 'Str',
    lazy => 1,
    builder => '_builder_dbname',
);

sub _builder_dbname {
    my $self = shift;
    my @args = split('/', $self->path_info);
    # $self->meta->throw_error() if scalar < 3;
    shift(@args); # root
    my $dbname = shift(@args);
    $self->method(shift(@args));
    $self->args([@args]);
    return $dbname;
};

has method => (
    is => 'rw',
    isa => 'Str',
);

has args => ( 
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [] }
);

=head2 type

Return the type of content_type the client wish.

=cut

has type => (
    is => 'rw',
    isa => 'Str',
    default => 'JSON'
);

=head2 username

Return the username of ReRe.

=cut

has username => (
    is => 'rw',
    isa => 'Str',
    default => ''
);

has parameters => (
    is => 'rw',
    isa => 'Hash::MultiValue',
    default => sub { Hash::MultiValue->new() }
);

around parameters => sub {
    my $orig = shift;
    my $self = shift;
    return $self->$orig() unless @_;
    my ($hash) = @_;
    return $self->$orig($hash);  
};

has extra => (
    is => 'rw',
    isa => 'Hash::MultiValue',
    default => sub { Hash::MultiValue->new() }
);

has response_model => (
    is => 'rw',
    isa => 'Str',
    default => 'pull'
);

1;

