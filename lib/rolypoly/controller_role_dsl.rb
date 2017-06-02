require 'rolypoly/role_dsl'

module Rolypoly
  FailedRoleCheckError = Class.new StandardError
  module ControllerRoleDSL

    include RoleDSL::InstanceMethods

    def self.included(sub)
      sub.before_filter(:rolypoly_check_role_access!) if sub.respond_to? :before_filter
      if sub.respond_to? :rescue_from
        sub.rescue_from(FailedRoleCheckError) do
          respond_to do |f|
            f.html { render text: "Not Authorized", status: 401 }
            f.json { render json: { error: "Not Authorized" }, status: 401 }
            f.xml { render xml: { error: "Not Authorized" }, status: 401 }
          end
        end
      end

      sub.extend(ClassMethods)
    end

    def rolypoly_check_role_access!
      failed_role_check! unless rolypoly_role_access?
    end

    def failed_role_check!
      raise Rolypoly::FailedRoleCheckError
    end

    def current_roles
      allowed_roles(action_name)
    end

    def public?
      super(action_name)
    end

    def current_gatekeepers
      rolypoly_gatekeepers.select { |gatekeeper|
        gatekeeper.action? action_name
      }
    end

    def allow?(options = {})
      rolypoly_gatekeepers.allow?(current_roles, action_name, rolypoly_resource_map.merge(options))
    end

    private def rolypoly_role_access?
      allow?
    end

    module ClassMethods
      include RoleDSL::ClassMethods

      private def rolypoly_gatekeepers=(arry)
        @rolypoly_gatekeepers = Rolypoly::RoleGatekeepers.new(arry)
      end
    end

  end
end
