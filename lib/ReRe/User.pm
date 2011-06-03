
package ReRe::User;

use Moose;
use ReRe::Config;
use Net::CIDR::Lite;

# VERSION

has file => (
    is       => 'rw',
    isa      => 'Str',
    required => 1
);

has _users => (
    is      => 'ro',
    isa     => 'HashRef[HashRef]',
    traits  => ['Hash'],
    default => sub { {} },
    handles => {
        _add_user  => 'set',
        _find_user => 'get',
        _all_users => 'elements'
    }
);

sub _parse_config {
    my $self = shift;
    my $config = ReRe::Config->new( { file => $self->file } );
    return $config->parse;
}

sub _setup {
    my $self   = shift;
    my %config = $self->_parse_config;
    return 0 unless defined($config{users});
    foreach my $username ( keys $config{users} ) {
        my $password = $config{users}{$username}{password};
        my $roles    = $config{users}{$username}{roles};
        my $allow    = $config{users}{$username}{allow};
        $self->_add_user(
            $username => {
                $password ? ( password => $password ) : (),
                $allow ? ( allow => [ split( ' ', $allow ) ] ) : (),
                roles => [ split( ' ', $roles ) ]
            }
        );
    }

}

sub _check_cidr {
    my $self  = shift;
    my $ip    = shift;
    my @allow = @_;

    foreach my $network (@allow) {
        my $cidr = Net::CIDR::Lite->new;
        my $flag = 0;
        eval {
            $cidr->add($network);
            $flag++ if $cidr->find($ip);
        };
        return 1 if $flag;
    }
}

=head1 METHODS

=cut

=head2 auth

Authentication

(username, password)

=cut

sub auth {
    my ( $self, $username, $password ) = @_;
    return 0 unless $username and $password;
    my $user = $self->_find_user($username) or return 0;
    my $mem_password = $user->{password};
    return $mem_password eq $password ? $username : 0;
}

=head2 auth_ip

Authentication by IP

($ip)

=cut

sub auth_ip {
    my ( $self, $ip ) = @_;
    return 0 unless $ip;
    my %users = $self->_all_users;
    foreach my $user ( keys %users ) {
        my ( @roles, @allow );
        @allow = @{ $users{$user}{allow} } if defined( $users{$user}{allow} );
        @roles = @{ $users{$user}{roles} } if defined( $users{$user}{roles} );
        return $user if grep( /$ip|all/, @allow );
        return $user if $self->_check_cidr( $ip, @allow );
    }
    return 0;
}

=head2 has_role

Autorization

(username, role)

=cut

sub has_role {
    my ( $self, $username, $role, $ip ) = @_;
    return 0 unless $role;
    return $self->_user_has_role( $username, $role, $ip ) if $username;
    return $self->_ip_has_role( $role, $ip ) if $ip;
    return 0;
}

sub _ip_has_role {
    my ( $self, $role, $ip ) = @_;
    my %users = $self->_all_users;
    foreach my $user ( keys %users ) {
        my ( @roles, @allow );
        @allow = @{ $users{$user}{allow} } if defined( $users{$user}{allow} );
        @roles = @{ $users{$user}{roles} } if defined( $users{$user}{roles} );
        return 1 if grep( /$ip|all/, @allow ) and grep( /$role|all/, @roles );
        return 1 if $self->_check_cidr( $ip, @allow );
    }
    return 0;
}

sub _user_has_role {
    my ( $self, $username, $role, $ip ) = @_;
    my $user = $self->_find_user($username);
    my ( @roles, @allow );
    @roles = @{ $user->{roles} } if defined( $user->{roles} );
    @allow = @{ $user->{allow} } if defined( $user->{allow} );
    return grep( /$role|all/, @roles ) or grep( /$ip|all/, @allow ) ? 1 : 0;
}

=head2 process

Initial process for acl.

=cut

sub process {
    my $self = shift;
    $self->_setup;
}

1;
