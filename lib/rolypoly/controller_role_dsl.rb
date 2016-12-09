require 'rolypoly/role_gatekeeper'
module Rolypoly
  FailedRoleCheckError = Class.new StandardError
  module ControllerRoleDSL
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

      unless sub.method_defined? :current_user_roles
        define_method(:current_user_roles) { [] }
      end

      unless sub.method_defined? :role_resource
        define_method(:role_resource) { {} }
      end
      sub.send :extend, ClassMethods
    end

    def rolypoly_check_role_access!
      failed_role_check! unless rolypoly_role_access?
    end

    def failed_role_check!
      raise Rolypoly::FailedRoleCheckError
    end

    def current_roles
      return [] if rolypoly_gatekeepers.empty?
      current_gatekeepers.reduce([]) { |array, gatekeeper|
        if gatekeeper.role?(current_user_roles, role_resource)
          array += Array(gatekeeper.allowed_roles(current_user_roles, action_name, role_resource))
        end
        array
      }
    end

    def public?
      return true if rolypoly_gatekeepers.empty?
      current_gatekeepers.any? &:public?
    end

    def current_gatekeepers
      rolypoly_gatekeepers.select { |gatekeeper|
        gatekeeper.action? action_name
      }
    end

    def rolypoly_role_access?
      rolypoly_gatekeepers.empty? ||
        rolypoly_gatekeepers.any? { |gatekeeper|
          gatekeeper.allow?(current_roles, action_name, role_resource)
        }
    end
    private :rolypoly_role_access?

    def rolypoly_gatekeepers
      self.class.rolypoly_gatekeepers
    end
    private :rolypoly_gatekeepers

    module ClassMethods
      def all_public
        build_gatekeeper(nil, nil).all_public
      end

      def restrict(*actions)
        build_gatekeeper nil, actions
      end

      def allow(*roles)
        build_gatekeeper roles, nil
      end

      def allow_with_resource(*roles)
        build_gatekeeper roles, nil, true
      end

      def publicize(*actions)
        restrict(*actions).to_none
      end

      def rolypoly_gatekeepers
        @rolypoly_gatekeepers ||= Array(try_super(__method__))
      end

      def try_super(mname)
        if superclass.respond_to?(mname)
          super_val = superclass.send(mname)
          super_val.respond_to?(:dup) ? super_val.dup : super_val
        end
      end

      def build_gatekeeper(roles, actions, require_resource = false)
        RoleGatekeeper.new(roles, actions, require_resource).tap { |gatekeeper|
          rolypoly_gatekeepers << gatekeeper
        }
      end
      private :build_gatekeeper

      def rolypoly_gatekeepers=(arry)
        @rolypoly_gatekeepers = Array(arry)
      end
      private :rolypoly_gatekeepers=
    end
  end
end
