require 'spec_helper'
require 'rolypoly/role_gatekeeper'
module Rolypoly
  describe RoleGatekeeper do
    let(:roles) { %w[admin scorekeeper] }
    let(:actions) { %w[index show] }

    context "resource not required" do
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

      describe "with resource defined" do
        let(:resource) { [organization: 123] }

        before do
          subject.to(:admin, :scorekeeper)
        end

        it_should_behave_like "allow should behave correctly"
      end
    end

    context "resource required" do
      let(:scorekeeper_role) { RoleObject.new(:scorekeeper) }

      subject { described_class.new roles, actions, :resource }

      describe "resource does not match" do
        before do
          allow(scorekeeper_role).to receive(:resource?).with(nil).and_return false
          allow(scorekeeper_role).to receive(:to_role_string).and_return 'scorekeeper'
        end

        it { expect(subject.allow?(nil, nil)).to be false }
        it { expect(subject.allow?(scorekeeper_role, :index)).to be false }
        it { expect(subject.allow?(scorekeeper_role, :edit)).to be false }
      end

      describe "resource does not match" do
        let(:resource) { { resource: ['Organization', 123] } }

        before do
          allow(scorekeeper_role).to receive(:resource?).with(resource[:resource]).and_return false
          allow(scorekeeper_role).to receive(:to_role_string).and_return "scorekeeper"
        end 

        it { expect(subject.allow?(nil, nil, resource)).to be false }
        it { expect(subject.allow?([scorekeeper_role], "index", resource)).to be false }
        it { expect(subject.allow?([scorekeeper_role], "edit", resource)).to be false }
      end

      describe "resource matches" do
        let(:resource) { { resource: ['Organization', 123] } }

        before do
          allow(scorekeeper_role).to receive(:resource?).with(resource[:resource]).and_return true
        end

        it { expect(subject.allow?(nil, nil, resource)).to be false }
        it { expect(subject.allow?([scorekeeper_role], "index", resource)).to be true }
        it { expect(subject.allow?([scorekeeper_role], "edit", resource)).to be false }
      end
    end
  end
end
