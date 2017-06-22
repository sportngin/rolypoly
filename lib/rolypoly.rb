require "rolypoly/version"
require 'rolypoly/controller_role_dsl'

module Rolypoly

  def self.define_gatekeepers(&block)
    role_gatekeepers = RoleGatekeepers.new
    role_gatekeepers.instance_eval(&block)
    role_gatekeepers
  end

end
