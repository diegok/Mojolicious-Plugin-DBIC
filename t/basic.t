#!/usr/bin/env perl
use Mojo::Base -strict;

use File::Basename 'dirname';
use File::Spec;
use lib join '/', File::Spec->splitdir(dirname(__FILE__)), 'lib';

use Test::More tests => 12;

use Mojolicious::Lite;
use Test::Mojo;

my $db_file = File::Spec->catfile(File::Spec->tmpdir(), 'test.db');
Mojo::Log->info($db_file);

plugin 'DBIC' => { Schema => [ "dbi:SQLite:$db_file", '', '', { sqlite_unicode => 1 } ] };

get '/schema_class' => sub {
  my $self = shift;
  $self->render_text(ref $self->schema);
};

get '/rs_class' => sub {
  my $self = shift;
  $self->render_text(ref $self->model('Tag'));
};

get '/insert/:name' => sub {
  my $self = shift;
  my $tag = $self->model('Tag')->create({ name => $self->param('name') });
  $self->render_text($tag->id);
};

get '/find/:id' => sub {
  my $self = shift;
  my $tag = $self->model('Tag')->find( $self->param('id') );
  $self->render_text($tag->name);
};

my $t = Test::Mojo->new;

# helpers
$t->get_ok('/schema_class')->status_is(200)->content_is('Schema');
$t->get_ok('/rs_class')->status_is(200)->content_is('DBIx::Class::ResultSet');

# schema
$t->get_ok('/insert/Test')->status_is(200)->content_is(1);
$t->get_ok('/find/1')->status_is(200)->content_is('Test');

unlink $db_file;
