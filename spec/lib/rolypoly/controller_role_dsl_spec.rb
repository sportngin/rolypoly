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
        let(:current_roles) { [:admin] }
        before do
          subject.allow(:admin).to_access(:index)
          subject.publicize(:landing)
          controller_instance.stub current_roles: current_roles, action_name: action_name
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

        describe "#landing" do
          let(:action_name) { "landing" }
          it "allows admin access" do
            expect { controller_instance.rolypoly_check_role_access! }
            .not_to raise_error
          end

          describe "with no role" do
            let(:current_roles) { [] }
            it "allows admin access" do
              expect { controller_instance.rolypoly_check_role_access! }
              .not_to raise_error
            end
          end
        end
      end
    end
  end
end
