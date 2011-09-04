package Schema::Result::ContactTag;
use strict;
use warnings;
use parent 'DBIx::Class';

__PACKAGE__->load_components('Core');
__PACKAGE__->table( 'contact_tag' );
__PACKAGE__->add_columns(
    "id_contact",
    { data_type => 'INT', default_value => 0, is_nullable => 0 },
    "id_tag",
    { data_type => 'INT', default_value => 0, is_nullable => 0 },
);
__PACKAGE__->set_primary_key( 'id_contact', 'id_tag' );
__PACKAGE__->belongs_to( 'contact', 'Schema::Result::Contact', { 'foreign.id' => 'self.id_contact' });
__PACKAGE__->belongs_to( 'tag',     'Schema::Result::Tag',     { 'foreign.id' => 'self.id_tag' });

1;
