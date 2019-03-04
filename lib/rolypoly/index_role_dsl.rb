require 'forwardable'
require 'role_scope'
require 'rubygems'

module IndexRoleDSL

  def self.included(base)
    base.before_filter(:check_where_or) if base.respond_to? :before_filter
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
  end

  module InstanceMethods
    extend Forwardable

    def self.included(base)
      unless base.method_defined?(:current_user_roles)
        base.send(:define_method, :current_user_roles) do
          raise NotImplementedError
        end
      end
    end

    def_delegators 'self.class', :role_scopes
    def_delegators :role_scopes, :public?

    def apply_scopes
      return query if role_scopes.all_access?(current_user_roles)
      return query.none if scope_hash.empty?
      return scope_hash.inject(query) { |query, (scope_name, ids)| query.or(query.public_send(scope_name, ids)) }
    end

    def scope_hash
      @scope_hash ||= role_scopes.scope_hash(current_user_roles)
    end

    def allowed_roles(scope_name)
      role_scopes.allowed_roles(current_user_roles, scope_name)
    end

    protected def check_rails
      rails_gem = Gem::Specification.select {|z| z.name == "rails"}.max_by {|a| a.version}
      if Gem::Version.new(rails_gem.version.version) < Gem::Version.new('5.0.0')
        true
      else
        false
      end
    end

    protected def check_where_or
      whereor_gem = Gem::Specification.select {|z| z.name == "where-or"}
      unless whereor_gem && check_rails
        rescue_error status: 500, message: 'It appears you are using Rails version 4.X.X or lower, please install the "where-or" gem or upgrade to rails 5.X.X'
      end
    end
  end

  module ClassMethods
    extend Forwardable

    def inherited(subclass)
      super
      subclass.instance_variable_set('@role_scopes', role_scopes.dup)
    end

    def_delegators :role_scopes, :all_public, :allow, :allowed_roles, :on

    def role_scopes
      @role_scopes ||= RoleScopes.new
    end
  end

end
