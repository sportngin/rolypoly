require 'spec_helper'
require 'rolypoly/role_gatekeeper'
module Rolypoly
  describe RoleGatekeeper do
    let(:roles) { %w[admin scorekeeper] }
    let(:actions) { %w[index show] }

    subject { described_class.new roles, actions }

    shared_examples_for "allow should behave correctly" do
      it "shouldn't auto-allow" do
        expect(subject.allow?(nil, nil)).to be false
      end

      it "should allow scorekeepr access to index" do
        expect(subject.allow?([:scorekeeper], "index")).to be true
      end

      it "should not allow scorekeepr access to edit" do
        expect(subject.allow?([:scorekeeper], "edit")).to be false
      end

      describe "all public" do
        before do
          subject.all_public
        end

        it "should allow whatever" do
          expect(subject.allow?(nil, nil)).to be true
        end

        it "should allow scorekeepr access to index" do
          expect(subject.allow?([:scorekeeper], "index")).to be true
        end

        it "should allow scorekeepr access to edit" do
          expect(subject.allow?([:scorekeeper], "edit")).to be true
        end
      end

      describe "all roles" do
        before do
          subject.to_none
        end

        it "shouldn't auto-allow" do
          expect(subject.allow?(nil, nil)).to be false
        end

        it "should allow scorekeepr access to index" do
          expect(subject.allow?([:janitor], "index")).to be true
          expect(subject.allow?([:admin], "index")).to be true
        end

        it "to should not allow scorekeepr access to edit" do
          expect(subject.allow?([:scorekeeper], "edit")).to be false
          expect(subject.allow?([:janitor], "edit")).to be false
        end
      end

      describe "all actions" do
        before do
          subject.to_all
        end

        it "shouldn't auto-allow" do
          expect(subject.allow?(nil, nil)).to be false
        end

        it "should allow scorekeepr access to index" do
          expect(subject.allow?([:scorekeeper], "index")).to be true
        end

        it "shouldn't allow janitor access to any" do
          expect(subject.allow?([:janitor], "index")).to be false
        end

        it "should allow scorekeepr access to edit" do
          expect(subject.allow?([:scorekeeper], "edit")).to be true
        end
      end
    end
    it_should_behave_like "allow should behave correctly"

    describe "with only roles set" do
      let(:actions) { [] }

      before do
        subject.to_access(:index, :show)
      end

      it_should_behave_like "allow should behave correctly"
    end

    describe "with only actions set" do
      let(:roles) { [] }

      before do
        subject.to(:admin, :scorekeeper)
      end

      it_should_behave_like "allow should behave correctly"
    end
  end
end
