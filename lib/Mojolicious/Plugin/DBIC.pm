package Mojolicious::Plugin::DBIC;
use Mojo::Base 'Mojolicious::Plugin';

our $VERSION = '0.01';

sub register {
    my ( $self, $app, $conf ) = @_;
    #TODO: Handle array config for simplest autoload use.

    keys %$conf
      or die "Can't initialize DBIC plugin without connection parameters.";

    Mojo::Log->info("Initializing DBIC plugin");

    $app->attr( schema => sub {{}} );

    for my $schema_class ( keys %$conf ) {
        $app->schema->{ $schema_class } = 
            $self->_init_schema( $schema_class => $conf->{$schema_class} );
    }

    $app->helper(
        schema => sub {
            my $self = shift;
            if ( my $schema_name = shift ) {
                return $self->app->schema->{$schema_name};
            }
            return ( values(%{$self->app->schema}) )[0];
        }
    );

    $app->helper(
        model => sub {
            my ( $self, $rs_name ) = @_;
            return $rs_name =~ /^ (.+) \. ([^\.]+) $/x 
                    ? $self->schema($1)->resultset($2)
                    : $self->schema->resultset($rs_name);
        }
    );

    return ( values(%{$app->schema}) )[0];
}

# Load & connect a schema
sub _init_schema {
    my ( $self, $schema_class, $options ) = @_;

    my @conn_info;
    if ( ref $options eq 'ARRAY' ) {
        @conn_info = @{$options};
    }
    else {
        @conn_info = $options->{connect_info}
                   ? @{ $options->{connect_info} }
                   : @$options{qw(dsn user pass options)};
    }

    eval "use $schema_class";
    if ($@) {
        Mojo::Log->debug("Can't use '$schema_class': $@");
        #TODO: check if schema doesn't exists or exists but has errors.
        Mojo::Log->debug('Loading schema dynamically');
        eval {
            use DBIx::Class::Schema::Loader;
            DBIx::Class::Schema::Loader->naming('v7');
        };
        if ($@) {
            Mojo::Log->error( 
              "Can't load schema dynamically. It seems you need to install DBIx::Class::Schema::Loader." 
            );
            die $@;
        }
        return DBIx::Class::Schema::Loader->connect(@conn_info);
    }

    Mojo::Log->debug("Connecting schema $schema_class");

    $ENV{DBIC_NO_VERSION_CHECK}++;
    $self->_deploy_schema($schema_class->connect(@conn_info));
}

# Deploy schema if it is deployable (via Schema::Versioned)
sub _deploy_schema {
    my ( $self, $schema ) = @_;
    return $schema unless $schema->can('get_db_version');

    if ( my $db_version = $schema->get_db_version ) {
        unless ( $db_version eq $schema->schema_version ) {
            Mojo::Log->debug("Upgrading schema from version $db_version to " . $schema->schema_version);
            $schema->upgrade();
        }
    } 
    else {
        Mojo::Log->debug("Deploying schema version " . $schema->schema_version);
        $schema->deploy();
    }

    $schema;
}

1;

__END__

=head1 NAME

Mojolicious::Plugin::DBIC - Mojolicious Plugin for DBIx::Class schemas

=head1 SYNOPSIS

  # Mojolicious
  $self->plugin( DBIC => { MySchema => [] } );

  # Mojolicious::Lite
  plugin DBIC => { MySchema => [] };

=head1 DESCRIPTION

L<Mojolicious::Plugin::DBIC> is a L<Mojolicious> plugin for using DBIx::Class
schemas in your Mojolicious apps.

This plugin will load an existing class or, if it doesn't exist it will try to
load the schema using the optional dependency DBIx::Class::Schema::Loader.

When schema exists and uses DBIx::Class::Schema::Versioned it will also check
for the schema version and will try to update or deploy if it needs to.

=head1 METHODS

L<Mojolicious::Plugin::DBIC> inherits all methods from
L<Mojolicious::Plugin> and implements the following new ones.

=head2 register

  $plugin->register;

Register plugin in L<Mojolicious> application.

=head1 HELPERS

This plugin will add these helpers to your application.

=head2 schema

Get a schema by name.

  $app->schema;             # default schema
  $app->schema('MySchema'); # schema by name

=head2 model

Get a resultset by name from a schema class. When you have one schema you only 
pass your model name. If you have several, you should prefix the name with your
schema name as "MySchema.CD".

  $app->model('CD');          # CD resultset on default schema
  $app->model('MySchema.CD'); # CD resultset on MySchema schema


=head1 AUTHOR

Diego Kuperman, C<< <diego at freekeylabs.com > >>


=head1 SEE ALSO

L<DBIx::Class>, L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>.


=head1 COPYRIGHT & LICENSE

Copyright 2011 Diego Kuperman.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut
