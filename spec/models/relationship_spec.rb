require 'spec_helper'

describe Relationship do
  let(:follower) { create_user }
  let(:followed) { create_user }
  let(:relationship) { follower.build_relationship followed }

  subject { relationship }

  it { should be_valid }

  describe "follower methods" do
    it { should respond_to :follower }
    it { should respond_to :followed }
    its(:follower) { should eq follower }
    its(:followed) { should eq followed }
  end

  describe "check validity" do
    describe "of follower_id" do
      let(:invalid_relationship) { Relationship.new(follower: follower) }

      specify { expect(invalid_relationship).not_to be_valid }
    end

    describe "of followed_id" do
      let(:invalid_relationship) { Relationship.new(followed: followed) }

      specify { expect(invalid_relationship).not_to be_valid }
    end
  end
end
