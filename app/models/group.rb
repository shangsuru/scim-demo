class Group < ActiveRecord::Base

  # ===========================================================================
  # TEST ATTRIBUTES - see db/migrate/20240807131433_add_groups_table.rb etc.
  # ===========================================================================

  READWRITE_ATTRS = %w{
    id
    scim_uid
    display_name
    scim_users_and_groups
  }

  has_and_belongs_to_many :users

  has_many :child_groups, class_name: 'Group', foreign_key: 'parent_id'

  # ===========================================================================
  # SCIM ADAPTER ACCESSORS
  #
  # Groups in SCIM can contain users or other groups. That's why the :find_with
  # key in the Hash returned by ::scim_attributes_map has to check the type of
  # thing it needs to find. Since the mappings only support a single read/write
  # accessor, we need custom accessors to do what SCIM is expecting by turning
  # the Rails associations to/from mixed, flat arrays of mock users and groups.
  # ===========================================================================

  def scim_users_and_groups
    self.users.to_a + self.child_groups.to_a
  end

  def scim_users_and_groups=(mixed_array)
    self.users        = mixed_array.select { |item| item.is_a?(User)  }
    self.child_groups = mixed_array.select { |item| item.is_a?(Group) }
  end

  # ===========================================================================
  # SCIM MIXIN AND REQUIRED METHODS
  # ===========================================================================

  def self.scim_resource_type
    return Scimitar::Resources::Group
  end

  def self.scim_attributes_map
    return {
      id:          :id,
      externalId:  :scim_uid,
      displayName: :display_name,
      members:     [ # NB read-write, though individual items' attributes are immutable
        list:  :scim_users_and_groups, # See adapter accessors, earlier in this file
        using: {
          value: :id
        },
        find_with: -> (scim_list_entry) {
          id   = scim_list_entry['value']
          type = scim_list_entry['type' ] || 'User' # Some online examples omit 'type' and believe 'User' will be assumed

          case type.downcase
          when 'user'
            User.find_by_primary_key(id)
          when 'group'
            Group.find_by_id(id)
          else
            raise Scimitar::InvalidSyntaxError.new("Unrecognised type #{type.inspect}")
          end
        }
      ]
    }
  end

  def self.scim_mutable_attributes
    return nil
  end

  def self.scim_queryable_attributes
    return {
      displayName: :display_name
    }
  end

  include Scimitar::Resources::Mixin
end
