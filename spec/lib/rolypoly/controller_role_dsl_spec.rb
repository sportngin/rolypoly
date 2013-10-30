require 'spec_helper'
class RoleObject < Struct.new :name
  def to_s
    name.to_s
  end
end
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
        let(:current_user_roles) { [RoleObject.new(:admin), RoleObject.new(:scorekeeper)] }
        before do
          subject.allow(:admin).to_access(:index)
          subject.publicize(:landing)
          controller_instance.stub current_user_roles: current_user_roles, action_name: action_name
        end

        describe "#index" do
          let(:action_name) { "index" }

          it "is not public" do
            controller_instance.should_not be_public
          end

          it "allows admin access" do
            expect { controller_instance.rolypoly_check_role_access! }
            .not_to raise_error
          end

          it "can get current_roles from controller" do
            controller_instance.current_roles.should == [RoleObject.new(:admin)]
          end
        end

        describe "#show" do
          let(:action_name) { "show" }
          it "disallows admin access" do
            expect { controller_instance.rolypoly_check_role_access! }
            .to raise_error(Rolypoly::FailedRoleCheckError)
          end

          it "is not public" do
            controller_instance.should_not be_public
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

            it "is public" do
              controller_instance.should be_public
            end
          end
        end
      end
    end
  end
end
