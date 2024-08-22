Rails.application.config.to_prepare do
  Scimitar.engine_configuration = Scimitar::EngineConfiguration.new({
    application_controller_mixin: Module.new do
      def self.included(base)
        base.class_eval do
          def test_hook; end

          before_action :test_hook
        end
      end

      def scim_schemas_url(options)
        super(test: 1, **options)
      end

      def scim_resource_type_url(options)
        super(test: 1, **options)
      end
    end,

    basic_authenticator: Proc.new do |username, password|
      if username == 'admin' && password == 'admin'
        true
      else
        false
      end
    end
  })

  module ScimSchemaExtensions
    module User

      # This "looks like" part of the standard Enterprise extension.
      class Enterprise < Scimitar::Schema::Base
        def initialize(options = {})
          super(
            name: 'EnterpriseExtendedUser',
            description: 'Enterprise extension for a User',
            id: self.class.id,
            scim_attributes: self.class.scim_attributes
          )
        end

        def self.id
          'urn:ietf:params:scim:schemas:extension:enterprise:2.0:User'
        end

        def self.scim_attributes
          [
            Scimitar::Schema::Attribute.new(name: 'organization', type: 'string'),
            Scimitar::Schema::Attribute.new(name: 'department', type: 'string'),
            Scimitar::Schema::Attribute.new(name: 'primaryEmail', type: 'string'),
          ]
        end
      end

      class Manager < Scimitar::Schema::Base
        def initialize(options = {})
          super(
            name: 'ManagementExtendedUser',
            description: 'Management extension for a User',
            id: self.class.id,
            scim_attributes: self.class.scim_attributes
          )
        end

        def self.id
          'urn:ietf:params:scim:schemas:extension:manager:1.0:User'
        end

        def self.scim_attributes
          [
            Scimitar::Schema::Attribute.new(name: 'manager', type: 'string')
          ]
        end
      end
    end
  end

  Scimitar::Resources::User.extend_schema ScimSchemaExtensions::User::Enterprise
  Scimitar::Resources::User.extend_schema ScimSchemaExtensions::User::Manager
end
