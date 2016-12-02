module Rolypoly
  class Role
    attr_accessor :name, :resource_type, :resource_id

    def initialize(role)
      if role.is_a?(Hash)
        self.name, self.resource_type = role.first
      else
        self.name = role.to_s
      end
    end

    def matches?(role_object, role_resource)
      return false unless name_match?(role_object)
      return true if resource_type.nil?
      role_object.resource?(role_resource)
    end

    private def resource_match?(role_object, role_resource)
      return false unless role_object.respond_to?(:resource?)
      role_object.resource?(role_resource)
    end

    private def name_match?(role_object)
      role_object_name(role_object) == name.to_s
    end

    private def role_object_name(role_object)
      role_object.respond_to?(:to_role_string) ? role_object.to_role_string : role_object.to_s
    end
  end
end
