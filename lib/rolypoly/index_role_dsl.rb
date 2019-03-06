require 'forwardable'
require 'rolypoly/role_scopes'

module Rolypoly
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
          scope_hash.inject(query) { |query, (scope_name, ids)| query.public_send(scope_name, ids) }
        else
          # This block is designed to handle cases of more than one scope.
          # The following code has been demonstrated to perform on most "simple"...
          #...objects and scopes. However, there are certain complex objects...
          #...and scopes that cause permission checks to fail.
          object_query = query
          object_query = join_tables.inject(object_query) do |q, join_table|
            q.joins(join_table)
          end

          scope_hash.inject(object_query) do |object_query, (scope_name, ids)|
            object_query.or(query.public_send(scope_name, ids))
          end
        end
      end

      def join_tables
        scope_hash.map do |scope_name, ids|
          query.public_send(scope_name, ids).values[:joins]
        end
          .flatten
          .uniq
          .reject { |join_table| query_join_tables.include?(join_table) }
      end

      def query_join_tables
         values = query.try(:values) || {}
         values.fetch(:joins, [])
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
        @role_scopes ||= Rolypoly::RoleScopes.new
      end
    end
  end
end
