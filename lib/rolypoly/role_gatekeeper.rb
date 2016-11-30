require 'set'
module Rolypoly
  class RoleGatekeeper
    attr_reader :roles
    def initialize(roles, actions)
      self.roles = Set.new Array(roles)
      self.actions = Set.new Array(actions).map(&:to_s)
      self.all_actions = false
      self.public = false
    end

    # restrict(*actions).to *roles
    def to(*roles)
      self.roles = self.roles.merge roles.map { |role| Role.new(role) }
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

    def allow?(current_roles, action)
      action?(action) &&
        role?(current_roles)
    end

    def allowed_roles(current_roles, action)
      return [] if public? || !action?(action)
      match_roles(current_roles)
    end

    def all_public
      self.public = true
      self.all_actions = true
    end

    def role?(check_roles)
      public? || !check_roles.nil? && check_roles.any? { |check_role| matches_any_role?(check_role) }
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

    private def matches_any_role?(check_role)
      roles.any? { |role| role.matches?(check_role) }
    end

    private def match_roles(check_roles)
      check_roles.reduce([]) { |array, role_object|
        array << role_object if matches_any_role?(role_object)
        array
      }
    end

    private def can_set_with_to?
      roles.empty?
    end

    private def can_set_with_access_to?
      actions.empty?
    end

    private def all_actions?
      !!all_actions
    end
  end
end
