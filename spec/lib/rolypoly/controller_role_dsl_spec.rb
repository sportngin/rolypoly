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
    it { should respond_to :on }

    describe "setting up with DSL" do
      describe "from allow side" do
        let(:controller_instance) { subject.new }
        let(:current_user_roles) { [RoleObject.new(:admin), RoleObject.new(:scorekeeper)] }
        before do
          subject.allow(:admin).to_access(:index)
          subject.publicize(:landing)
          allow(controller_instance).to receive(:current_user_roles).and_return(current_user_roles)
          allow(controller_instance).to receive(:action_name).and_return(action_name)
        end

        describe "#index" do
          let(:action_name) { "index" }

          it "is not public" do
            expect(controller_instance).to_not be_public
          end

          it "allows admin access" do
            expect { controller_instance.rolypoly_check_role_access! }
            .not_to raise_error
          end

          it "can get current_roles from controller" do
            expect(controller_instance.current_roles).to eq([RoleObject.new(:admin)])
          end
        end

        describe "#show" do
          let(:action_name) { "show" }
          it "disallows admin access" do
            expect { controller_instance.rolypoly_check_role_access! }
            .to raise_error(Rolypoly::FailedRoleCheckError)
          end

          it "is not public" do
            expect(controller_instance).to_not be_public
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
              expect(controller_instance).to be_public
            end
          end
        end
      end

      describe "from on side" do
        let(:controller_instance) { subject.new }
        let(:admin_role) { RoleObject.new(:admin) }
        let(:scorekeeper_role) { RoleObject.new(:scorekeeper) }
        let(:current_user_roles) { [admin_role, scorekeeper_role] }
        let(:rolypoly_resource_map) { { organization: ['Organization', 123] } }
        let(:check_access!) { controller_instance.rolypoly_check_role_access! }

        before do
          subject.on(:organization).allow(:admin).to_access(:index)
          subject.publicize(:landing)
          allow(admin_role).to receive(:resource?).with(rolypoly_resource_map[:organization]).and_return true
          allow(controller_instance).to receive(:current_user_roles).and_return(current_user_roles)
          allow(controller_instance).to receive(:action_name).and_return(action_name)
          allow(controller_instance).to receive(:rolypoly_resource_map).and_return(rolypoly_resource_map)
        end

        describe "#index" do
          let(:action_name) { "index" }

          it { expect(controller_instance).to_not be_public }
          it { expect{ check_access! }.not_to raise_error }
          it { expect(controller_instance.current_roles).to eq([RoleObject.new(:admin)])}
        end

        describe "#show" do
          let(:action_name) { "show" }

          it { expect{ check_access! }.to raise_error(Rolypoly::FailedRoleCheckError)}
          it { expect(controller_instance).to_not be_public }
        end

        describe "#landing" do
          let(:action_name) { "landing" }

          it { expect{ check_access! }.not_to raise_error }

          describe "with no role" do
            let(:current_roles) { [] }

            it { expect { check_access! }.not_to raise_error }
            it { expect(controller_instance).to be_public }
          end
        end
      end
    end
  end
end
