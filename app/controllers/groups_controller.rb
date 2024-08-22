class GroupsController < Scimitar::ActiveRecordBackedResourcesController
  skip_before_action :verify_authenticity_token

  protected

  def storage_class
    Group
  end

  def storage_scope
    Group.all
  end

end