require 'spec_helper'
require 'rolypoly/role_gatekeeper'
module Rolypoly
  describe RoleGatekeeper do
    let(:roles) { %w[admin scorekeeper] }
    let(:actions) { %w[index show] }

    subject { described_class.new roles, actions }

    describe "optional conditionals" do
      subject { described_class.new roles, actions, options }

      describe "if" do
        describe "string" do
          let(:options) { { if: "show?" } }

          it "should be true" do
            controller = double show?: true
            subject.optional_conditional?(controller).should be_true
          end

          it "should be false" do
            controller = double show?: false
            subject.optional_conditional?(controller).should be_false
          end
        end

        describe "symbol" do
          let(:options) { { if: :show? } }

          it "should be true" do
            controller = double show?: true
            subject.optional_conditional?(controller).should be_true
          end

          it "should be false" do
            controller = double show?: false
            subject.optional_conditional?(controller).should be_false
          end
        end

        describe "block" do
          let(:options) { { if: -> { show? } } }

          it "should be true" do
            controller = double show?: true
            subject.optional_conditional?(controller).should be_true
          end

          it "should be false" do
            controller = double show?: false
            subject.optional_conditional?(controller).should be_false
          end
        end
      end

      describe "unless" do
        describe "string" do
          let(:options) { { unless: "show?" } }

          it "should be false" do
            controller = double show?: true
            subject.optional_conditional?(controller).should be_false
          end

          it "should be true" do
            controller = double show?: false
            subject.optional_conditional?(controller).should be_true
          end
        end

        describe "symbol" do
          let(:options) { { unless: :show? } }

          it "should be false" do
            controller = double show?: true
            subject.optional_conditional?(controller).should be_false
          end

          it "should be true" do
            controller = double show?: false
            subject.optional_conditional?(controller).should be_true
          end
        end

        describe "block" do
          let(:options) { { unless: -> { show? } } }

          it "should be false" do
            controller = double show?: true
            subject.optional_conditional?(controller).should be_false
          end

          it "should be true" do
            controller = double show?: false
            subject.optional_conditional?(controller).should be_true
          end
        end
      end
    end

    shared_examples_for "allow should behave correctly" do
      it "shouldn't auto-allow" do
        subject.allow?(nil, nil).should be_false
      end

      it "should allow scorekeepr access to index" do
        subject.allow?([:scorekeeper], "index").should be_true
      end

      it "should not allow scorekeepr access to edit" do
        subject.allow?([:scorekeeper], "edit").should be_false
      end

      describe "all public" do
        before do
          subject.all_public
        end

        it "should allow whatever" do
          subject.allow?(nil, nil).should be_true
        end

        it "should allow scorekeepr access to index" do
          subject.allow?([:scorekeeper], "index").should be_true
        end

        it "should allow scorekeepr access to edit" do
          subject.allow?([:scorekeeper], "edit").should be_true
        end
      end

      describe "all roles" do
        before do
          subject.to_none
        end

        it "shouldn't auto-allow" do
          subject.allow?(nil, nil).should be_false
        end

        it "should allow scorekeepr access to index" do
          subject.allow?([:janitor], "index").should be_true
          subject.allow?([:admin], "index").should be_true
        end

        it "should not allow scorekeepr access to edit" do
          subject.allow?([:scorekeeper], "edit").should be_false
          subject.allow?([:janitor], "edit").should be_false
        end
      end

      describe "all actions" do
        before do
          subject.to_all
        end

        it "shouldn't auto-allow" do
          subject.allow?(nil, nil).should be_false
        end

        it "should allow scorekeepr access to index" do
          subject.allow?([:scorekeeper], "index").should be_true
        end

        it "shouldn't allow janitor access to any" do
          subject.allow?([:janitor], "index").should be_false
        end

        it "should allow scorekeepr access to edit" do
          subject.allow?([:scorekeeper], "edit").should be_true
        end
      end
    end

    include_examples "allow should behave correctly"

    describe "with only roles set" do
      let(:actions) { [] }

      before do
        subject.to_access(:index, :show)
      end

      include_examples "allow should behave correctly"
    end

    describe "with only actions set" do
      let(:roles) { [] }

      before do
        subject.to(:admin, :scorekeeper)
      end

      include_examples "allow should behave correctly"
    end
  end
end
