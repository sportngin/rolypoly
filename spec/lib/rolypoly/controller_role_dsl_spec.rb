require 'spec_helper'
module Rolypoly
  describe ControllerRoleDSL do
    let(:example_controller) do
      Class.new do
        include Rolypoly::ControllerRoleDSL
      end
    end
    subject { example_controller }
    it { should respond_to :restrict }
    it { should respond_to :allow }
  end
end
