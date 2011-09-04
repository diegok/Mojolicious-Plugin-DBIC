package Schema::Result::Tag;
use strict;
use warnings;
use parent 'DBIx::Class';

__PACKAGE__->load_components('Core');
__PACKAGE__->table( 'tag' );
__PACKAGE__->add_columns(
    id   => { data_type => 'INT', is_nullable => 0, is_auto_increment => 1 },
    name => { data_type => 'VARCHAR', default_value => "", is_nullable => 0, size => 64 },
);
__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->add_unique_constraint( 'name', ['name'] );
__PACKAGE__->has_many( 'tag_contacts', 'Schema::Result::ContactTag', { 'foreign.id_tag' => 'self.id' } );
__PACKAGE__->many_to_many( 'contacts', 'tag_contacts', 'contact' );

1;

