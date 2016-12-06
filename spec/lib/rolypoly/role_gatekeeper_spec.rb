require 'spec_helper'
require 'rolypoly/role_gatekeeper'
module Rolypoly
  describe RoleGatekeeper do
    let(:roles) { %w[admin scorekeeper] }
    let(:actions) { %w[index show] }
    let(:resource) { [] }

    context "resource not required" do
      subject { described_class.new roles, actions, false }

      shared_examples_for "allow should behave correctly" do
        it "shouldn't auto-allow" do
          expect(subject.allow?(nil, nil, resource)).to be false
        end

        it "should allow scorekeepr access to index" do
          expect(subject.allow?([:scorekeeper], "index", resource)).to be true
        end

        it "should not allow scorekeepr access to edit" do
          expect(subject.allow?([:scorekeeper], "edit", resource)).to be false
        end

        describe "all public" do
          before do
            subject.all_public
          end

          it "should allow whatever" do
            expect(subject.allow?(nil, nil, resource)).to be true
          end

          it "should allow scorekeepr access to index" do
            expect(subject.allow?([:scorekeeper], "index", resource)).to be true
          end

          it "should allow scorekeepr access to edit" do
            expect(subject.allow?([:scorekeeper], "edit", resource)).to be true
          end
        end

        describe "all roles" do
          before do
            subject.to_none
          end

          it "shouldn't auto-allow" do
            expect(subject.allow?(nil, nil, resource)).to be false
          end

          it "should allow scorekeepr access to index" do
            expect(subject.allow?([:janitor], "index", resource)).to be true
            expect(subject.allow?([:admin], "index", resource)).to be true
          end

          it "to should not allow scorekeepr access to edit" do
            expect(subject.allow?([:scorekeeper], "edit", resource)).to be false
            expect(subject.allow?([:janitor], "edit", resource)).to be false
          end
        end

        describe "all actions" do
          before do
            subject.to_all
          end

          it "shouldn't auto-allow" do
            expect(subject.allow?(nil, nil, resource)).to be false
          end

          it "should allow scorekeepr access to index" do
            expect(subject.allow?([:scorekeeper], "index", resource)).to be true
          end

          it "shouldn't allow janitor access to any" do
            expect(subject.allow?([:janitor], "index", resource)).to be false
          end

          it "should allow scorekeepr access to edit" do
            expect(subject.allow?([:scorekeeper], "edit", resource)).to be true
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
      let(:scorekeeper) do
        scorekeeper = double("scorekeeper")
        allow(scorekeeper).to receive(:resource?).and_return false
        allow(scorekeeper).to receive(:to_role_string).and_return "scorekeeper"
        scorekeeper
      end

      subject { described_class.new roles, actions, true }

      describe "resource does not match" do
        it { expect(subject.allow?(nil, nil, resource)).to be false }
        it { expect(subject.allow?([scorekeeper], "index", resource)).to be false }
        it { expect(subject.allow?([scorekeeper], "edit", resource)).to be false }
      end

      describe "resource matches" do
        let(:resource) { {resource: 123} }

        before do
          allow(scorekeeper).to receive(:resource?).and_return true
        end

        it { expect(subject.allow?(nil, nil, resource)).to be false }
        it { expect(subject.allow?([scorekeeper], "index", resource)).to be true }
        it { expect(subject.allow?([scorekeeper], "edit", resource)).to be false }
      end
    end
  end
end
