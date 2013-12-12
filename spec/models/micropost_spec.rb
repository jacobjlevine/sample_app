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
end
