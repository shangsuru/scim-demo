class PokemonsController < Scimitar::ActiveRecordBackedResourcesController
  skip_before_action :verify_authenticity_token

  protected

  def storage_class
    Pokemon
  end

  def storage_scope
    Pokemon.all
  end

end