require 'spec_helper'
require 'rolypoly/role_gatekeeper'
module Rolypoly
  describe RoleGatekeeper do
    let(:roles) { %w[admin scorekeeper] }
    let(:actions) { %w[index show] }

    subject { described_class.new roles, actions }

    it "shouldn't auto-allow" do
      subject.allow?(nil, nil).should be_false
    end

    it "should allow scorekeepr access to index" do
      subject.allow?([:scorekeeper], "index").should be_true
    end

    it "should not allow scorekeepr access to edit" do
      subject.allow?([:scorekeeper], "edit").should be_false
    end

    describe "with only roles set" do
      let(:actions) { [] }

      before do
        subject.to_access(:index, :show)
      end

      it "shouldn't auto-allow" do
        subject.allow?(nil, nil).should be_false
      end

      it "should allow scorekeepr access to index" do
        subject.allow?([:scorekeeper], "index").should be_true
      end

      it "should not allow scorekeepr access to edit" do
        subject.allow?([:scorekeeper], "edit").should be_false
      end
    end

    describe "with only actions set" do
      let(:roles) { [] }

      before do
        subject.to(:admin, :scorekeeper)
      end

      it "shouldn't auto-allow" do
        subject.allow?(nil, nil).should be_false
      end

      it "should allow scorekeepr access to index" do
        subject.allow?([:scorekeeper], "index").should be_true
      end

      it "should not allow scorekeepr access to edit" do
        subject.allow?([:scorekeeper], "edit").should be_false
      end
    end
  end
end
