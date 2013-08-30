module Rolypoly
  module ControllerRoleDSL
    def self.included(sub)
      sub.send :extend, ClassMethods
    end

    module ClassMethods
      def restrict(*actions)

      end

      def allow(*roles)

      end
    end
  end
end
