#!/usr/bin/env perl
#
# Thiago Rondon <thiago@aware.com.br>
#

package ReRe::App;

use strict;
use Mojolicious::Lite;
use ReRe;
use Try::Tiny;
use feature ":5.10";
use Mojo::JSON;

# ABSTRACT: ReRe application
# VERSION

plugin 'basic_auth';

my $config_users = -r '/etc/rere/users.conf' ? '/etc/rere/users.conf' : 'etc/users.conf';
my $rere         = ReRe->new;

sub error_config_users {
    say "I don't find $config_users.";
    say "Please, see http://www.rere.com.br to how create this file.";
    exit -1;
}

sub error_server_ping {
    say "I can't connect to redis server.";
    say "Please, see http://www.rere.com.br for more information.";
    exit -2;
}

sub main {
    my $self = shift;
    &error_config_users unless -r $config_users;
    $rere->start;
    try {
        $rere->server->execute('ping');
    }
    catch {
        &error_server_ping;
    };

    app->start;
}

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

any '/redis/:method/:var/:value/:extra' => {
    var   => '',
    value => '',
    extra => ''
  } => sub {
    my $self     = shift;
    my $method   = $self->stash('method') || $self->param('method');
    my $var      = $self->stash('var') || $self->param('var');
    my $value    = $self->stash('value') || $self->param('value');
    my $extra    = $self->stash('extra') || $self->param('extra');
    my $username = $self->session('name') || '';

    $username = $rere->user->auth_ip( $self->tx->remote_address )
      unless $username;

    return $self->render_json( { err => 'no_auth' } )
      unless $username
          or $self->basic_auth(
              realm => sub {
                  my ( $http_username, $http_password ) = @_;
                  $rere->user->auth( $http_username, $http_password );
              }
          );

    $self->render_json(
        $rere->process( $method, $var, $value, $extra, $username ) );

  } => 'redis';

websocket '/ws' => sub {
    my $self = shift;

    warn 'ws';
    my $username = 'userrw';

#    my $username = $rere->user->auth_ip( $self->tx->remote_address );
#
#    return $self->render_json( { err => 'no_auth' } )
#      unless $username
#          or $self->basic_auth(
#              realm => sub {
#                  my ( $http_username, $http_password ) = @_;
#                  $rere->user->auth( $http_username, $http_password );
#              }
#          );
    app->log->debug(sprintf 'Client connected: %s', $self->tx->remote_address);

    $self->on_message(
        sub {
            my ( $self, $message ) = @_;
            warn $message;
            my ( $method, $var, $value, $extra ) = split( ' ', $message );
            $self->send_message(
                $self->render_json(
                    $rere->process( $method, $var, $value, $extra, $username )
                )
            );
        }
    );

};

any '/' => sub {
    my $self = shift;
    return $self->render_json( {} );
} => 'index';

main;
