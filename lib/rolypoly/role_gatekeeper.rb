require 'set'
module Rolypoly
  class RoleGatekeeper
    InvalidOptionError = Class.new StandardError

    attr_reader :roles
    attr_reader :options
    attr_accessor :controller

    def initialize(roles, actions, options = {})
      self.roles = Set.new Array(roles).map(&:to_s)
      self.actions = Set.new Array(actions).map(&:to_s)
      self.options = options || {}
      self.all_actions = false
      self.public = false
    end

    # restrict(*actions).to *roles
    def to(*roles)
      roles = extract_options!(roles)
      self.roles = self.roles.merge roles.flatten.compact.map(&:to_s)
    end

    # make actions public basically
    # restrict(:index).to_none
    def to_none(*args)
      extract_options!(args)
      self.public = true
    end

    # allow(*roles).to_access *actions
    def to_access(*actions)
      actions = extract_options!(actions)
      self.actions = self.actions.merge actions.flatten.compact.map(&:to_s)
    end

    # allow role access to all actions
    # allow(*roles).to_all
    def to_all(*args)
      extract_options!(args)
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

    def optional_conditional?(controller)
      return true if !(if_block || unless_block)

      if if_block
        check_controller_block(controller, if_block)
      else
        !check_controller_block(controller, unless_block)
      end
    end

    protected # self.attr= gets mad
    attr_writer :roles
    attr_writer :options
    attr_accessor :actions
    attr_accessor :all_actions
    attr_accessor :public

    def check_controller_block(controller, option)
      case
      when option.is_a?(String) || option.is_a?(Symbol)
        controller.instance_eval(option.to_s)
      when option.is_a?(Proc)
        controller.instance_exec(&option)
      else
        raise InvalidOptionError, "must pass String, Symbol, or Proc"
      end
    end
    private :check_controller_block

    def match_roles(check_roles)
      check_roles.reduce([]) { |array, role_object|
        array << role_object if roles.include?(sanitize_role_object(role_object))
        array
      }
    end
    private :match_roles

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

    def if_block
      options[:if] || options["if"]
    end
    private :if_block

    def unless_block
      options[:unless] || options["unless"]
    end
    private :unless_block

    def extract_options!(array)
      args = array.dup
      if args.last.is_a?(Hash)
        self.options = self.options.merge(args.pop)
      end

      return args
    end
    private :extract_options!
  end
end
