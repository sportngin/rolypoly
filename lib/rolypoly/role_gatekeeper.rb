require 'set'
module Rolypoly
  class RoleGatekeeper
    def initialize(roles, actions)
      self.roles = Set.new Array(roles).map(&:to_s)
      self.actions = Set.new Array(actions).map(&:to_s)
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

    def allow?(current_roles, action)
      action?(action) &&
        role?(current_roles)
    end

    def all_public
      self.public = true
      self.all_actions = true
    end

    protected # self.attr= gets mad
    attr_accessor :roles
    attr_accessor :actions
    attr_accessor :all_actions
    attr_accessor :public

    def role?(check_roles)
      check_roles = Set.new Array(check_roles).map(&:to_s)
      public? || !(check_roles & roles).empty?
    end
    private :role?

    def action?(check_actions)
      check_actions = Set.new Array(check_actions).map(&:to_s)
      all_actions? || !(check_actions & actions).empty?
    end
    private :action?

    def can_set_with_to?
      roles.empty?
    end
    private :can_set_with_to?

    def can_set_with_access_to?
      actions.empty?
    end
    private :can_set_with_access_to?

    def public?
      !!public
    end
    private :public?

    def all_actions?
      !!all_actions
    end
    private :all_actions?
  end
end
