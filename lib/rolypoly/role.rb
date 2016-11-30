module Rolypoly
  class Role
    attr_accessor :name, :resource_type, :resource_id

    def initialize(role)
      if role.is_a?(Hash)
        self.name, resources = role.first
        self.resource_type, self.resource_id = resources.first
      else
        self.name = role.to_s
      end
    end

    def matches?(role_object)
      return false unless name_match?(role_object)
      return true unless resource_check_required?
      resource_match?(role_object)
    end

    private def resource_check_required?
      !(resource_type.nil? || resource_id.nil?)
    end

    private def resource_match?(role_object)
      return false unless role_object.respond_to?(:resource?)
      role_object.resource?(resource_type, resource_id)
    end

    private def name_match?(role_object)
      role_object_name(role_object) == name.to_s
    end

    private def role_object_name(role_object)
      role_object.respond_to?(:to_role_string) ? role_object.to_role_string : role_object.to_s
    end
  end
end
