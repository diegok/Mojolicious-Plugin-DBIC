package Schema::Result::Contact;
use strict;
use warnings;
use parent 'DBIx::Class';

__PACKAGE__->load_components(qw/ Core /);

__PACKAGE__->table( 'contact' );
__PACKAGE__->add_columns(
    id          => { data_type => 'INT', is_nullable => 0, is_auto_increment => 1 },
    name        => { data_type => 'varchar', is_nullable => 0, size => 255 },
    nationality => { data_type => 'text', is_nullable => 1 },
    comment     => { data_type => 'text', is_nullable => 1 },
);

__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->resultset_attributes({ order_by => [ 'name ASC' ] });

__PACKAGE__->has_many( 'contact_tags', 'Schema::Result::ContactTag', { 'foreign.id_contact' => 'self.id' } );
__PACKAGE__->many_to_many( 'tags', 'contact_tags', 'tag' );

1;
