require 'set'
module Rolypoly
  class RoleGatekeeper
    attr_reader :roles
    def initialize(roles, actions, require_resource)
      self.roles = Set.new Array(roles).map(&:to_s)
      self.actions = Set.new Array(actions).map(&:to_s)
      self.require_resource = require_resource
      self.all_actions = false
      self.public = false
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

    def allow?(current_roles, action, resource)
      action?(action) &&
        role?(current_roles, resource)
    end

    def allowed_roles(current_roles, action, resource)
      return [] if public? || !action?(action)
      match_roles(current_roles, resource)
    end

    def all_public
      self.public = true
      self.all_actions = true
    end

    def role?(check_roles, resource)
      check_roles = filter_roles_by_resource(check_roles, resource)
      check_roles = Set.new sanitize_role_input(check_roles)
      public? || !(check_roles & roles).empty?
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
    attr_accessor :require_resource

    def match_roles(check_roles, resource)
      check_roles = filter_roles_by_resource(check_roles, resource)
      check_roles.reduce([]) { |array, role_object|
        array << role_object if roles.include?(sanitize_role_object(role_object))
        array
      }
    end
    private :match_roles

    def filter_roles_by_resource(check_roles, resource)
      return check_roles unless require_resource
      check_roles.select do |check_role|
        check_role.respond_to?(:resource?) && check_role.resource?(resource)
      end
    end
    private :filter_roles_by_resource

    def sanitize_role_input(role_objects)
      Array(role_objects).map { |r| sanitize_role_object(r) }
    end
    private :sanitize_role_input

    def sanitize_role_object(role_object)
      role_object.respond_to?(:to_role_string) ? role_object.to_role_string : role_object.to_s
    end
    private :sanitize_role_object

    def can_set_with_to?
      roles.empty?
    end
    private :can_set_with_to?

    def can_set_with_access_to?
      actions.empty?
    end
    private :can_set_with_access_to?

    def all_actions?
      !!all_actions
    end
    private :all_actions?
  end
end
