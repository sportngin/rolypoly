require 'forwardable'
require 'role_scope'

module IndexRoleDSL

  def self.included(base)
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
      if scope_hash.keys.length == 1
        return scope_hash.inject(query) { |query, (scope_name, ids)| query.public_send(scope_name, ids) }
      else
        raise NotImplementedError, 'Add ability to OR multiple scopes together' # TODO: Add ability to OR multiple scopes together
      end
    end

    def scope_hash
      @scope_hash ||= role_scopes.scope_hash(current_user_roles)
    end

    def allowed_roles(scope_name)
      role_scopes.allowed_roles(current_user_roles, scope_name)
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
