require 'set'

module Rolypoly
  class RoleScope
    attr_reader :roles, :actions
    def initialize(roles, actions, resource = nil)
      self.roles = Set.new Array(roles).map(&:to_s)
      self.actions = Set.new Array(actions).map(&:to_s)
      self.resource = resource
      self.all_actions = false
    end

    def initialize_copy(other)
      @roles = @roles.dup
      @actions = @actions.dup
    end

    # on(resource).allow(*roles).to_access(*actions)
    def allow(*roles)
      self.roles = self.roles.merge(roles.flatten.compact.map(&:to_s))
      self
    end

    # allow(*roles).on(resource).to_access(*actions)
    def on(resource)
      self.resource = resource
      self
    end

    # allow(*roles).to_access *actions
    def to_access(*actions)
      self.actions = self.actions.merge actions.flatten.compact.map(&:to_s)
    end

    # allow role access to all actions
    # allow(*roles).to_all
    def to_all
      self.all_actions = true
    end

    def allow?(current_roles, action)
      action?(action) && role?(current_roles)
    end

    def allowed_roles(current_roles, action)
      return [] unless action?(action)
      match_roles(current_roles)
    end

    def role?(check_roles)
      Array(check_roles).any? { |check_role| allowed_role?(check_role) }
    end

    def action?(check_actions)
      check_actions = Set.new Array(check_actions).map(&:to_s)
      all_actions? || !(check_actions & actions).empty?
    end

    def all_actions?
      !!all_actions
    end

    private def allowed_resource?(check_role, required_resource)
      return false unless check_role.respond_to?(:resource?)

      required_resources = type_id_resource?(required_resource) ? [required_resource] : Array(required_resource)
      required_resources.any? { |r| check_role.resource?(r) }
    end

    private def type_id_resource?(required_resource)
      required_resource.is_a?(Array) && %w(String Symbol).include?(required_resource.first.class.name)
    end

    protected
    attr_writer :roles
    attr_writer :actions
    attr_accessor :all_actions
    attr_accessor :resource

    private def match_roles(check_roles)
      Array(check_roles).select do |check_role|
        allowed_role?(check_role)
      end
    end

    private def allowed_role?(role_object)
      role_string = role_object.respond_to?(:to_role_string) ? role_object.to_role_string : role_object.to_s

      roles.include?(role_string.to_s)
    end
  end
end
