module Rolypoly
  class RoleGatekeeper
    def initialize(roles, actions)
      self.roles = Array(roles).map &:to_s
      self.actions = Array(actions).map &:to_s
      self.all_actions = false
      self.public = false
    end

    # restrict(*actions).to *roles
    def to(*roles)
      self.roles += roles.flatten.compact.map(&:to_s)
    end

    def to_access(*actions)
      self.actions += actions.flatten.compact.map(&:to_s)
    end

    def allow?(current_roles, action)
      public? || (
        action?(action) &&
        role?(current_roles)
      )
    end

    protected # self.attr= gets mad
    attr_accessor :roles
    attr_accessor :actions
    attr_accessor :all_actions
    attr_accessor :public

    def role?(check_roles)
      check_roles = Array(check_roles).map(&:to_s)
      !(check_roles & roles).empty?
    end
    private :role?

    def action?(check_actions)
      check_actions = Array(check_actions).map(&:to_s)
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
