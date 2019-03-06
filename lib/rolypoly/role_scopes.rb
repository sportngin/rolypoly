require 'forwardable'
require 'rolypoly/role_scope'

module Rolypoly
  class RoleScopes
    extend Forwardable
    include Enumerable

    def_delegators :build_role_scope, :allow, :on
    def_delegators :@role_scopes, :clear, :each, :empty?

    def initialize(role_scopes = [])
      @role_scopes = Array(role_scopes)
    end

    def initialize_copy(other)
      @role_scopes = @role_scopes.map(&:dup)
    end

    def allowed_roles(user_role_objects, action)
      return [] if empty?

      reduce([]) do |allowed_role_objects, role_scope|
        allowed_role_objects | role_scope.allowed_roles(user_role_objects, action)
      end
    end

    def scope_hash(user_role_objects)
      actions.each_with_object({}) do |action, memo|
        roles = allowed_roles(user_role_objects, action)
        ids = roles.map(&:resource_id).compact.uniq
        memo[action] = ids if ids.any?
        memo
      end
    end

    def all_access?(current_user_roles)
      any? { |role_scope| role_scope.allow?(current_user_roles, nil) }
    end

    def actions
      map(&:actions).each_with_object(Set.new) { |action_set, memo| memo.merge(action_set) }
    end

    private def build_role_scope(roles = nil, actions = nil, resource = nil)
      new_role_scope = Rolypoly::RoleScope.new(roles, actions, resource)
      @role_scopes << new_role_scope
      new_role_scope
    end
  end
end
