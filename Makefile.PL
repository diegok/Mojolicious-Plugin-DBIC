#!/usr/bin/env perl

use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'Mojolicious::Plugin::DBIC',
  VERSION_FROM => 'lib/Mojolicious/Plugin/DBIC.pm',
  AUTHOR       => 'Diego Kuperman <diegok@cpan.org>',
  PREREQ_PM    => {
    'Mojolicious' => '1.90',
    'DBIx::Class' => '0.08195',
    'DBD::SQLite' => '1.33',
    'File::Temp'  => 0
  },
  test         => {TESTS => 't/*.t'}
);
