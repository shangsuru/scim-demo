module Scim
  module Schema
    # Represents the schema for the Pokemon resource
    # See also Scim::Resources::Pokemon
    class Pokemon < Scimitar::Schema::Base

      def initialize(options = {})
        super(name: 'Pokemon',
              id: self.class.id,
              description: 'Represents a Pokemon',
              scim_attributes: self.class.scim_attributes)

      end

      def self.id
        'urn:ietf:params:scim:schemas:core:2.0:Pokemon'
      end

      def self.scim_attributes
        [
          Scimitar::Schema::Attribute.new(name: 'name', type: 'string', uniqueness: 'server', required: true),
          Scimitar::Schema::Attribute.new(name: 'pokemon_type', type: 'string', required: true),
          Scimitar::Schema::Attribute.new(name: 'pokedex_number', type: 'integer', required: true),
          Scimitar::Schema::Attribute.new(name: 'image', type: 'string')
        ]
      end

    end
  end
end
