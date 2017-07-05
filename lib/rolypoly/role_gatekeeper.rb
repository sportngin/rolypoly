require 'set'
module Rolypoly
  class RoleGatekeeper
    attr_reader :roles
    def initialize(roles, actions, resource = nil)
      self.roles = Set.new Array(roles).map(&:to_s)
      self.actions = Set.new Array(actions).map(&:to_s)
      self.resource = resource
      self.all_actions = false
      self.public = false
    end

    def initialize_copy(other)
      @roles = @roles.dup
      @actions = @actions.dup
    end

    # on(resource).allow(*roles).to_access(*actions)
    def allow(*roles)
      to(*roles)
      self
    end

    # on(resource).restrict(*actions).to(*roles)
    def restrict(*actions)
      to_access(*actions)
      self
    end

    # allow(*roles).on(resource).to_access(*actions)
    def on(resource)
      self.resource = resource
      self
    end

    # restrict(*actions).to *roles
    def to(*roles)
      self.roles = self.roles.merge roles.flatten.compact.map(&:to_s)
    end

    # make actions public basically
    # restrict(:index).to_none
    def to_none
      self.public = true
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

    def allow?(current_roles, action, options = {})
      action?(action) && role?(current_roles, options)
    end

    def allowed_roles(current_roles, action, options = {})
      return [] if public? || !action?(action)
      match_roles(current_roles, options)
    end

    def all_public
      self.public = true
      self.all_actions = true
    end

    def role?(check_roles, options = {})
      return true if public?
      required_resource = find_required_resource(options)

      Array(check_roles).any? do |check_role|
        allowed_role?(check_role) && allowed_resource?(check_role, required_resource)
      end
    end

    private def require_resource?
      !!resource
    end

    private def allowed_resource?(check_role, required_resource)
      return true unless require_resource?
      return false unless check_role.respond_to?(:resource?)

      if resources?(required_resource)
        required_resource.any? do |r|
          check_role.resource?(r)
        end
      else
        check_role.resource?(required_resource)
      end
    end

    private def resources?(resources)
      resources.is_a?(Array) && !%w(String Symbol).include?(resources.first.class.name)
    end

    private def find_required_resource(options = {})
      return resource unless %w(String Symbol).include?(resource.class.to_s)

      options[resource]
    end

    def action?(check_actions)
      check_actions = Set.new Array(check_actions).map(&:to_s)
      all_actions? || !(check_actions & actions).empty?
    end

    def public?
      !!public
    end

    protected # self.attr= gets mad
    attr_writer :roles
    attr_accessor :actions
    attr_accessor :all_actions
    attr_accessor :public
    attr_accessor :resource

    private def match_roles(check_roles, options = {})
      required_resource = find_required_resource(options)

      Array(check_roles).select do |check_role|
        allowed_role?(check_role) && allowed_resource?(check_role, required_resource)
      end
    end

    private def allowed_role?(role_object)
      role_string = role_object.respond_to?(:to_role_string) ? role_object.to_role_string : role_object.to_s

      roles.include?(role_string.to_s)
    end

    def all_actions?
      !!all_actions
    end
    private :all_actions?
  end
end
