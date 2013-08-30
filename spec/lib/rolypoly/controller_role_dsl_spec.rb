require 'spec_helper'
module Rolypoly
  describe ControllerRoleDSL do
    let(:example_controller) do
      Class.new do
        include Rolypoly::ControllerRoleDSL
      end
    end
    after { example_controller.instance_variable_set("@rolypoly_gatekeepers", nil) }
    subject { example_controller }
    it { should respond_to :restrict }
    it { should respond_to :allow }

    describe "setting up with DSL" do
      describe "from allow side" do
        let(:controller_instance) { subject.new }
        before do
          subject.allow(:admin).to_access(:index)
          controller_instance.stub current_roles: [:admin], action_name: action_name
        end

        describe "#index" do
          let(:action_name) { "index" }
          it "allows admin access" do
            expect { controller_instance.rolypoly_check_role_access! }
            .not_to raise_error
          end
        end

        describe "#show" do
          let(:action_name) { "show" }
          it "disallows admin access" do
            expect { controller_instance.rolypoly_check_role_access! }
            .to raise_error(Rolypoly::FailedRoleCheckError)
          end
        end
      end
    end
  end
end
