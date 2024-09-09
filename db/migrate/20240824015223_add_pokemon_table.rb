class AddPokemonTable < ActiveRecord::Migration[7.1]
  def change
    create_table :pokemons do |t|
      t.timestamps

      t.text :scim_uid
      t.text :name
      t.text :pokemon_type
      t.integer :pokedex_number
      t.text :image
    end
  end
end
