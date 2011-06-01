
package ReRe::ACL;

use Moose;
use Config::General;
use Data::Dumper;

has file => (
    is => 'rw',
    isa => 'Str',
    required => 1
);

has _users => (
    is => 'ro',
    isa => 'HashRef[HashRef]',
    traits => ['Hash'],
    default => sub { {} },
    handles => {
        _add_user => 'set',
        _find_user => 'get'
    }
);

sub _parse_config {
    my $self = shift;
    die "Where is config file for acl ?" unless -r $self->file;
    my $conf = new Config::General($self->file);
    return $conf->getall;
}

sub _setup {
    my $self = shift;
    my %config = $self->_parse_config;
    foreach my $username (keys $config{users}) {
        my $password = $config{users}{$username}{password};
        my $roles = $config{users}{$username}{roles};
        $self->_add_user(
            $username => { 
                password => $password, 
                roles => [ split(/ /, $roles) ] 
            });
    }

}

sub auth {
    my ($self, $username, $password) = @_;
    return 0 unless $username and $password;
    my $user = $self->_find_user($username) or return 0;
    my $mem_password = $user->{password};
    return $mem_password eq $password ? 1 : 0;
}

sub has_role {
    my ($self, $username, $role) = @_;
    return 0 unless $role;
    my $user = $self->_find_user($username) or return 0;
    my @roles = @{$user->{roles}};
    return grep(/$role|all/, @roles) ? 1 : 0;
}

sub process {
    my $self = shift;
    $self->_setup;
}


1;

