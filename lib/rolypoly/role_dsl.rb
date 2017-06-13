require 'forwardable'
require 'rolypoly/role_gatekeepers'

module Rolypoly
  module RoleDSL

    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
    end

    module InstanceMethods
      extend Forwardable

      def self.included(base)
        unless base.method_defined?(:current_user_roles)
          define_method(:current_user_roles) do
            []
          end
        end

        unless base.method_defined?(:rolypoly_resource_map)
          define_method(:rolypoly_resource_map) do
            {}
          end
        end
      end

      def_delegators 'self.class', :rolypoly_gatekeepers
      def_delegators :rolypoly_gatekeepers, :public?

      def allow?(action, options = {})
        rolypoly_gatekeepers.allow?(current_user_roles, action, rolypoly_resource_map.merge(options))
      end

      def allowed_roles(action, options = {})
        rolypoly_gatekeepers.allowed_roles(current_user_roles, action, rolypoly_resource_map.merge(options))
      end
    end

    module ClassMethods
      extend Forwardable

      def inherited(subclass)
        super
        subclass.instance_variable_set('@rolypoly_gatekeepers', rolypoly_gatekeepers.dup)
      end

      def_delegators :rolypoly_gatekeepers, :all_public, :restrict, :allow, :allow?, :allowed_roles, :on, :public?, :publicize

      def rolypoly_gatekeepers
        @rolypoly_gatekeepers ||= Rolypoly::RoleGatekeepers.new
      end
    end

  end
end
