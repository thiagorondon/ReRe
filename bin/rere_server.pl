#!/usr/bin/env perl
#
# Thiago Rondon <thiago@aware.com.br>
#

package ReRe::App;

use strict;
use Mojolicious::Lite;
use ReRe;

# ABSTRACT: ReRe application
# VERSION

plugin 'basic_auth';

my $rere = ReRe->new;
$rere->start;

get '/login' => sub {
    my $self     = shift;
    my $username = $self->param('username') || '';
    my $password = $self->param('password') || '';

    return $self->render_json( { login => 0 } )
      unless $rere->user->auth( $username, $password );

    $self->session( name => $username );
    $self->render_json( { login => 1 } );
} => 'login';

get '/logout' => sub {
    my $self = shift;
    $self->session( expires => 1 );
    $self->render_json( { logout => 1 } );
} => 'logout';

get '/redis/:method/:var/:value' => { var => '', value => '' } => sub {
    my $self   = shift;
    my $method = $self->stash('method');
    my $var    = $self->stash('var');
    my $value  = $self->stash('value');

    my $username = $self->session('name') || '';

#    return $self->render_json( { err => 'no_method' } )
#      unless $rere->server->has_method($method);

    $username = $rere->user->auth_ip( $self->tx->remote_address )
        unless $username;

    return $self->render_json( { err => 'no_auth' } )
        unless $username or $self->basic_auth( realm => sub {
                my ($http_username, $http_password) = @_;
                $rere->user->auth( $http_username, $http_password);
            } );

    return $self->render_json( { err => 'no_permission' } )
      unless $rere->user->has_role( $username, $method );

    my $ret;
    if ( $method eq 'set' ) {
        $ret = $rere->server->execute( $method, $var => $value );
        return $self->render_json( { $method => { $var => $value } } );
   }
    elsif ( $var ) {
        $ret = $rere->server->execute( $method, $var );
        return $self->render_json( { $method => { $var => $ret } } );
    }
    else {
        $ret = $rere->server->execute( $method );
        return $self->render_json( { $method => $ret } );
    }

} => 'redis';

app->start;

