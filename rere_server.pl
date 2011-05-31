#!/usr/bin/env perl
#
# Thiago Rondon <thiago@aware.com.br>
#

use Mojolicious::Lite;

get '/login' => sub {
    my $self = shift;
    my $username = $self->param('username') || '';
    my $password = $self->param('password') || '';

    return $self->render unless $username eq 'teste' and $password eq 'teste';
    $self->session(name => $username);
    $self->render_json({ login => 1 });
} => 'login';

get '/logout' => sub {
    my $self = shift;
    $self->session(expires => 1);
    $self->render_json({ logout => 1 });
} => 'logout';

app->start;

