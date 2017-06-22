require 'spec_helper'

module Rolypoly
  describe RoleGatekeepers do
    subject { RoleGatekeepers.new }
    after { subject.clear }

    # DSL class methods
    describe 'rule-building methods' do
      it { should respond_to :all_public }
      it { expect { subject.all_public }.to change { subject.to_a.size }.by(1) }
      it 'should delegate all_public to a new gatekeeper' do
        expect_any_instance_of(RoleGatekeeper).to receive(:all_public)
        subject.all_public
      end

      it { should respond_to :allow }
      it { expect { subject.allow(:role_1, :role_2) }.to change { subject.to_a.size }.by(1) }
      it 'should delegate allow to a new gatekeeper' do
        expect_any_instance_of(RoleGatekeeper).to receive(:allow).with(:role_1, :role_2)
        subject.allow(:role_1, :role_2)
      end

      it { should respond_to :on }
      it { expect { subject.on(:organization) }.to change { subject.to_a.size }.by(1) }
      it 'should delegate on to a new gatekeeper' do
        expect_any_instance_of(RoleGatekeeper).to receive(:on).with(:organization)
        subject.on(:organization)
      end

      it { should respond_to :publicize }
      it { expect { subject.publicize }.to change { subject.to_a.size }.by(1) }
      it 'should delegate publicize to a new gatekeeper' do
        newer_gatekeeper = instance_double('RoleGatekeeper', :newer_gatekeeper)
        expect_any_instance_of(RoleGatekeeper).to receive(:restrict).with(:index, :show).and_return(newer_gatekeeper)
        expect(newer_gatekeeper).to receive(:to_none)
        subject.publicize(:index, :show)
      end

      it { should respond_to :restrict }
      it { expect { subject.restrict(:index, :show) }.to change { subject.to_a.size }.by(1) }
      it 'should delegate restrict to a new gatekeeper' do
        expect_any_instance_of(RoleGatekeeper).to receive(:restrict).with(:index, :show)
        subject.restrict(:index, :show)
      end
    end

    # DSL instance methods
    it { should respond_to :allow? }
    it { should respond_to :allowed_roles }
    it { should respond_to :public? }

    # Array methods not included in Enumerable
    it { should respond_to :clear }
    it { should respond_to :empty? }

    describe 'setting up with DSL' do
      describe 'from allow side' do
        let(:current_user_roles) { [RoleObject.new(:admin), RoleObject.new(:scorekeeper)] }
        before do
          subject.allow(:admin).to_access(:index)
          subject.publicize(:landing)
        end

        describe '#index' do
          let(:action_name) { 'index' }

          it 'is not public' do
            expect(subject).to_not be_public(action_name)
          end

          it 'allows admin access' do
            expect(subject).to be_allow(current_user_roles, action_name)
          end

          it 'can get current_user_roles' do
            expect(subject.allowed_roles(current_user_roles, action_name)).to eq([RoleObject.new(:admin)])
          end
        end

        describe '#show' do
          let(:action_name) { 'show' }
          it 'disallows admin access' do
            expect(subject).to_not be_allow(current_user_roles, action_name)
          end

          it 'is not public' do
            expect(subject).to_not be_public(action_name)
          end
        end

        describe '#landing' do
          let(:action_name) { 'landing' }
          it 'allows admin access' do
            expect(subject).to be_allow(current_user_roles, action_name)
          end

          describe 'with no role' do
            let(:current_user_roles) { [] }
            it 'allows admin access' do
              expect(subject).to be_allow(current_user_roles, action_name)
            end

            it 'is public' do
              expect(subject).to be_public(action_name)
            end
          end
        end
      end

      describe 'from on side' do
        let(:admin_role) { RoleObject.new(:admin) }
        let(:scorekeeper_role) { RoleObject.new(:scorekeeper) }
        let(:current_user_roles) { [admin_role, scorekeeper_role] }
        let(:rolypoly_resource_map) { { organization: ['Organization', 123] } }

        before do
          subject.on(:organization).allow(:admin).to_access(:index)
          subject.publicize(:landing)
          allow(admin_role).to receive(:resource?).with(rolypoly_resource_map[:organization]).and_return true
        end

        describe '#index' do
          let(:action_name) { 'index' }

          it { expect(subject).to_not be_public(action_name) }
          it { expect(subject).to be_allow(current_user_roles, action_name, rolypoly_resource_map) }
          it { expect(subject.allowed_roles(current_user_roles, action_name, rolypoly_resource_map)).to eq([RoleObject.new(:admin)])}
        end

        describe '#show' do
          let(:action_name) { 'show' }

          it { expect(subject).to_not be_allow(current_user_roles, action_name) }
          it { expect(subject).to_not be_public(action_name) }
        end

        describe '#landing' do
          let(:action_name) { 'landing' }

          it { expect(subject).to be_allow(current_user_roles, action_name) }

          describe 'with no role' do
            let(:current_user_roles) { [] }

            it { expect(subject).to be_allow(current_user_roles, action_name) }
            it { expect(subject).to be_public(action_name) }
          end
        end
      end
    end
  end
end
