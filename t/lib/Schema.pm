package Schema;
use base qw/DBIx::Class::Schema/;

our $VERSION = '1';

$ENV{DBIC_NO_VERSION_CHECK}++;

__PACKAGE__->load_namespaces();
__PACKAGE__->load_components( qw/Schema::Versioned/ );

# add extra attributes to all tables on the schema!
sub sqlt_deploy_hook {
    my ($self, $sqlt_schema) = @_;

    for my $sqlt_table ( $sqlt_schema->get_tables ) {
        $sqlt_table->extra( mysql_charset => 'utf8' );
    }
}

sub connection {
    my $self = shift;
    $self = $self->next::method(@_);

    if ( my $db_version = $self->get_db_version() ) {
        unless ( $db_version eq $VERSION ) {
            print STDERR "Upgrading schema from version $db_version to $VERSION\n";
            $self->upgrade();
        }
    } 
    else {
        print STDERR "Deploying schema version $VERSION\n";
        $self->deploy();
    }

    return $self;
}

1;
