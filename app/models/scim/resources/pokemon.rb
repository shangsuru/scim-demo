module Scim
  module Resources
    class Pokemon < Scimitar::Resources::Base

      set_schema Schema::Pokemon

      def self.endpoint
        '/Pokemons'
      end

    end
  end
end
