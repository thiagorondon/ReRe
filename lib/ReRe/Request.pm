
package ReRe::Request;

use Moose;

=head2 remote_address

Returns the IP address of the client (REMOTE_ADDR).

=cut

has remote_address => (
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
    required => 1
);

=head2 path_info

Returns PATH_INFO in the environment. Use this to get the local path for the requests.

=cut

has path_info => (
    is => 'rw',
    isa => 'Str',
    required => 1
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

1;

