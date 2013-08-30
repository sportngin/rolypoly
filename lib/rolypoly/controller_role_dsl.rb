require 'rolypoly/role_gatekeeper'
module Rolypoly
  FailedRoleCheckError = Class.new StandardError
  module ControllerRoleDSL
    def self.included(sub)
      sub.send :extend, ClassMethods
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
    end

    def rolypoly_check_role_access!
      failed_role_check! unless rolypoly_role_access?
    end

    def current_roles # OVERRIDE
      []
    end

    def failed_role_check!
      raise Rolypoly::FailedRoleCheckError
    end

    def rolypoly_role_access?
      rolypoly_gatekeepers.any? { |gatekeeper|
        gatekeeper.allow? current_roles, action_name
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

      def publicize(*actions)
        restrict(*actions).to_none
      end

      def rolypoly_gatekeepers
        @rolypoly_gatekeepers ||= []
      end

      def build_gatekeeper(roles, actions)
        RoleGatekeeper.new(roles, actions).tap { |gatekeeper|
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
