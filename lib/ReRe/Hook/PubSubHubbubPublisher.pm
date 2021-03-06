
package ReRe::Hook::PubSubHubbubPublisher;

use Moose::Role;

# VERSION

has ua => (
    is        => 'rw',
    isa       => 'Object',
    predicate => 'has_ua',
);

has hub => (
    is        => 'rw',
    isa       => 'Str',
    predicate => 'has_hub'
);

has urls => (
    is      => 'ro',
    isa     => 'ArrayRef[Str]',
    traits  => ['Array'],
    handles => {
        all_urls => 'elements',
        add_url  => 'push',
        find_url => 'first'
        }

);

before add_url => sub {
    my $self = shift;
    return unless @_;
    my $url = shift;
    $self->meta->throw_error('URL invalid') unless $url and $url =~ m!^https?://\S+$!;
};

has last_res => (
    is      => 'rw',
    isa     => 'Str',
    default => '',
);

=head2 publish_update

...

=cut

sub publish_update {
    my $self = shift;
    return unless $self->has_ua and $self->has_hub and $self->all_urls;
    my @args = ( "hub.mode" => "publish" );
    push @args, map { ( "hub.url" => $_ ) } $self->all_urls;

    #my $req = $ua->post($self->hub, @args);
    #return $req->is_success ? 1 : 0;
}

1;

