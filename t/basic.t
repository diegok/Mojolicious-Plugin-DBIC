#!/usr/bin/env perl
use Mojo::Base -strict;

use File::Basename 'dirname';
use File::Spec;
use lib join '/', File::Spec->splitdir(dirname(__FILE__)), 'lib';

use Test::More tests => 6;

use Mojolicious::Lite;
use Test::Mojo;

my $db_file = File::Spec->catfile(File::Spec->tmpdir(), 'test.db');

plugin 'DBIC' => { Schema => [ "dbi:SQLite:$db_file", '', '', { sqlite_unicode => 1 } ] };

get '/schema_class' => sub {
  my $self = shift;
  $self->render_text(ref $self->schema);
};

get '/rs_class' => sub {
  my $self = shift;
  $self->render_text(ref $self->model('Tag'));
};

my $t = Test::Mojo->new;

# helpers
$t->get_ok('/schema_class')->status_is(200)->content_is('Schema');
$t->get_ok('/rs_class')->status_is(200)->content_is('DBIx::Class::ResultSet');

