class UsersController < Scimitar::ActiveRecordBackedResourcesController
  skip_before_action :verify_authenticity_token

  protected

  def storage_class
    User
  end

  def storage_scope
    User.all
  end

end