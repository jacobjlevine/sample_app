require 'spec_helper'

describe Micropost do
  let(:user) { create_user }
  before { @micropost = user.microposts.build(content: "Lorem ipsum") }

  subject { @micropost }

  it { should respond_to :content }
  it { should respond_to :user_id }
  it { should respond_to :user }
  its(:user) { should eq user}

  describe "when user_id is nil" do
    before { @micropost.user_id = nil }

    it { should_not be_valid }
  end

  describe "when content is blank" do
    it "should be invalid" do
      #test all types of blank values
      [nil, '', ' '].each do | blank_string |
        @micropost = Micropost.new(content: blank_string, user_id: user.id)
        expect(@micropost).not_to be_valid
      end
    end
  end

  describe "when content is the max length" do
    before { @micropost.content = 'a' * 140 }
    it { should be_valid }
  end

  describe "when content is too long" do
    before { @micropost.content = 'a' * 141 }
    it { should_not be_valid }
  end
end
