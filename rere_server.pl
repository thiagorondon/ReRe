#!/usr/bin/env perl
#
# Thiago Rondon <thiago@aware.com.br>
#

use strict;

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

get '/redis/:method/:var/:value' => sub {
    my $self   = shift;
    my $method = $self->stash('method');
    my $var    = $self->stash('var');
    my $value  = $self->stash('value');    # not here..

    my $username = 'userrw';               #$self->session('name') || '';

    warn $method;

    return $self->render_json( { err => 'no_method' } )
      unless $rere->server->has_method($method);

    return $self->render_json( { err => 'no_permission' } )
      unless $rere->acl->has_role( $username, $method );

    # fix ............
    my $ret;
    if ( $method eq 'set' ) {
        $ret = $rere->server->execute( $method, $var => $value );
    }
    elsif ( $method eq 'get' ) {
        $ret = $rere->server->execute( $method, $var );
    }

    return $self->render_json( { $method => $ret } );
} => 'redis';

app->start;

