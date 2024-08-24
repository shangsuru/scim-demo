class Pokemon < ActiveRecord::Base

  # ===========================================================================
  # TEST ATTRIBUTES - see db/migrate/20240824015223_add_pokemon_table.rb etc.
  # ===========================================================================

  READWRITE_ATTRS = %w{
    id
    scim_uid
    name
    pokemon_type
    image
  }

  def self.scim_resource_type
    return Scim::Resources::Pokemon
  end

  def self.scim_attributes_map
    return {
      id: :id,
      externalId: :scim_uid,
      name: :name,
      pokemon_type: :pokemon_type,
      pokedex_number: :pokedex_number,
      image: :image
    }
  end

  def self.scim_mutable_attributes
    return nil
  end

  def self.scim_queryable_attributes
    return {
      pokedex_number: :pokedex_number,
      name: :name
    }
  end

  include Scimitar::Resources::Mixin
end