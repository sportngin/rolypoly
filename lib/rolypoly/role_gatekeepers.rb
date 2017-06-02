require 'forwardable'
require 'rolypoly/role_gatekeeper'

module Rolypoly
  class RoleGatekeepers

    extend Forwardable
    include Enumerable

    def_delegators :build_gatekeeper, :all_public, :allow, :on, :restrict
    def_delegators :@gatekeepers, :clear, :each, :empty?

    def initialize(gatekeepers = [])
      @gatekeepers = Array(gatekeepers)
    end

    def initialize_copy(other)
      @gatekeepers = @gatekeepers.map(&:dup)
    end

    def publicize(*actions)
      restrict(*actions).to_none
    end

    def allow?(role_objects, action, options = {})
      return true if empty?

      any? { |gatekeeper| gatekeeper.allow?(role_objects, action, options) }
    end

    def allowed_roles(role_objects, action, options = {})
      return [] if empty?

      reduce([]) do |allowed_role_objects, gatekeeper|
        allowed_role_objects | gatekeeper.allowed_roles(role_objects, action, options)
      end
    end

    def public?(action)
      return true if empty?

      any? do |gatekeeper|
        gatekeeper.action?(action) && gatekeeper.public?
      end
    end

    private def build_gatekeeper(roles = nil, actions = nil, resource = nil)
      new_gatekeeper = RoleGatekeeper.new(roles, actions, resource)
      @gatekeepers << new_gatekeeper
      new_gatekeeper
    end

  end
end
