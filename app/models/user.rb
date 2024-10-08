class User < ActiveRecord::Base

  self.primary_key = :primary_key

  # ===========================================================================
  # TEST ATTRIBUTES - see db/migrate/20240807130908_add_users_table.rb etc.
  # ===========================================================================

  READWRITE_ATTRS = %w{
    primary_key
    scim_uid
    username
    password
    first_name
    last_name
    work_email_address
    home_email_address
    work_phone_number
    organization
    department
    manager
    groups
  }

  has_and_belongs_to_many :groups

  # A fixed value read-only attribute, in essence.
  #
  def is_active
    true
  end

  # A test hook to force validation failures.
  #
  INVALID_USERNAME = 'invalid username'
  validates :username, uniqueness: true, exclusion: { in: [INVALID_USERNAME] }

  # ===========================================================================
  # SCIM MIXIN AND REQUIRED METHODS
  # ===========================================================================

  def self.scim_resource_type
    return Scimitar::Resources::User
  end

  def self.scim_attributes_map
    return {
      id:         :primary_key,
      externalId: :scim_uid,
      userName:   :username,
      password:   :password,
      active:     :is_active,
      name:       {
        givenName:  :first_name,
        familyName: :last_name
      },
      emails: [
        {
          match: 'type',
          with:  'work',
          using: {
            value:   :work_email_address,
            primary: true
          }
        },
        {
          match: 'type',
          with:  'home',
          using: {
            value:   :home_email_address,
            primary: false
          }
        },
      ],
      phoneNumbers: [
        {
          match: 'type',
          with:  'work',
          using: {
            value:   :work_phone_number,
            primary: false
          }
        },
      ],
      groups: [
        {
          # Read-only, so no :find_with key. There's no 'class' specified here
          # either, to help test the "/Schemas" endpoint's reflection code.
          #
          list:  :groups,
          using: {
            value:   :id,
            display: :display_name
          }
        }
      ],

      # Custom extension schema - see configuration in
      # "spec/apps/dummy/config/initializers/scimitar.rb".
      #
      organization: :organization,
      department:   :department,
      primaryEmail: :scim_primary_email,

      manager:      :manager,

      userGroups: [
        {
          list:      :groups,
          find_with: ->(value) { Group.find(value["value"]) },
          using: {
            value:   :id,
            display: :display_name
          }
        }
      ]
    }
  end

  def self.scim_mutable_attributes
    return nil
  end

  def self.scim_queryable_attributes
    return {
      'id'                => { column: :primary_key },
      'externalId'        => { column: :scim_uid },
      'meta.lastModified' => { column: :updated_at },
      'name.givenName'    => { column: :first_name },
      'name.familyName'   => { column: :last_name  },
      'groups'            => { column: Group.arel_table[:id] },
      'groups.value'      => { column: Group.arel_table[:id] },
      'emails'            => { columns: [ :work_email_address, :home_email_address ] },
      'emails.value'      => { columns: [ :work_email_address, :home_email_address ] },
      'emails.type'       => { ignore: true }, # We can't filter on that; it'll just search all e-mails
      'primaryEmail'      => { column: :scim_primary_email },
      'userName'          => { column: :username }
    }
  end

  # Custom attribute reader
  #
  def scim_primary_email
    work_email_address
  end

  include Scimitar::Resources::Mixin
end
