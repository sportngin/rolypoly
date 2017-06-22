require 'spec_helper'

module Rolypoly
  describe RoleDSL do
    subject do
      Class.new do
        include Rolypoly::RoleDSL
      end
    end
    after { subject.instance_variable_set('@rolypoly_gatekeepers', nil) }

    it { expect(subject).to respond_to :rolypoly_gatekeepers }

    it { expect(subject).to respond_to :all_public }
    it 'should delegate all_public to rolypoly_gatekeepers' do
      expect(subject.rolypoly_gatekeepers).to receive(:all_public)
      subject.all_public
    end

    it { expect(subject).to respond_to :allow }
    it 'should delegate allow to rolypoly_gatekeepers' do
      expect(subject.rolypoly_gatekeepers).to receive(:allow).with(:role_1, :role_2)
      subject.allow(:role_1, :role_2)
    end

    it { expect(subject).to respond_to :allow? }
    it 'should delegate allow? to rolypoly_gatekeepers' do
      expect(subject.rolypoly_gatekeepers).to receive(:allow?).with([:admin, :org_admin], :index)
      subject.allow?([:admin, :org_admin], :index)
    end

    it { expect(subject).to respond_to :allowed_roles }
    it 'should delegate allowed_roles to rolypoly_gatekeepers' do
      expect(subject.rolypoly_gatekeepers).to receive(:allowed_roles).with([:admin, :org_admin], :index)
      subject.allowed_roles([:admin, :org_admin], :index)
    end

    it { expect(subject).to respond_to :on }
    it 'should delegate on to rolypoly_gatekeepers' do
      expect(subject.rolypoly_gatekeepers).to receive(:on).with(:organization)
      subject.on(:organization)
    end

    it { expect(subject).to respond_to :publicize }
    it 'should delegate publicize to rolypoly_gatekeepers' do
      expect(subject.rolypoly_gatekeepers).to receive(:publicize).with(:index, :show)
      subject.publicize(:index, :show)
    end

    it { expect(subject).to respond_to :public? }
    it 'should delegate public? to rolypoly_gatekeepers' do
      expect(subject.rolypoly_gatekeepers).to receive(:public?).with(:index)
      subject.public?(:index)
    end

    it { expect(subject).to respond_to :restrict }
    it 'should delegate restrict to rolypoly_gatekeepers' do
      expect(subject.rolypoly_gatekeepers).to receive(:restrict).with(:index, :show)
      subject.restrict(:index, :show)
    end

    describe 'instance' do
      let(:example_object) { subject.new }

      it { expect(example_object).to respond_to :current_user_roles }
      it { expect(example_object).to respond_to :rolypoly_resource_map }

      it { expect(example_object).to respond_to :rolypoly_gatekeepers }
      it 'should delegate rolypoly_gatekeepers to self.class' do
        expect(subject).to receive(:rolypoly_gatekeepers)
        example_object.rolypoly_gatekeepers
      end

      it { expect(subject).to respond_to :public? }
      it 'should delegate public? to rolypoly_gatekeepers' do
        expect(subject.rolypoly_gatekeepers).to receive(:public?).with(:index)
        subject.public?(:index)
      end

      %w(allow? allowed_roles).each do |method_name|
        it { expect(example_object).to respond_to method_name }

        it "should delegate #{method_name} to rolypoly_gatekeepers" do
          current_user_roles = [:admin, :org_admin]
          rolypoly_resource_map = { foo: :foo, bar: :bar }
          options = { bar: :baz }

          expect(example_object).to receive(:current_user_roles).and_return(current_user_roles)
          expect(example_object).to receive(:rolypoly_resource_map).and_return(rolypoly_resource_map)
          expect(example_object.rolypoly_gatekeepers).to receive(method_name).with(current_user_roles, :index, { foo: :foo, bar: :baz })

          example_object.public_send(method_name, :index, options)
        end
      end
    end

  end
end
