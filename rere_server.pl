#!/usr/bin/env perl
#
# Thiago Rondon <thiago@aware.com.br>
#

BEGIN { push( @INC, './lib' ) }

use Mojolicious::Lite;
use ReRe;

my $rere = ReRe->new;
$rere->start;

get '/login' => sub {
    my $self     = shift;
    my $username = $self->param('username') || '';
    my $password = $self->param('password') || '';

    return $self->render_json( { login => 0 } )
      unless $rere->acl->auth( $username, $password );
    
    $self->session( name => $username );
    $self->render_json( { login => 1 } );
} => 'login';

get '/logout' => sub {
    my $self = shift;
    $self->session( expires => 1 );
    $self->render_json( { logout => 1 } );
} => 'logout';

app->start;

