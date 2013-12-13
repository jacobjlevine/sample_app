require 'spec_helper'

describe "Micropost Pages" do
  subject { page }

  let(:user) { create_user }
  before { valid_sign_in user }

  describe "micropost creation" do
    before { visit root_path }

    describe "with valid data" do
      let(:content) { "This is a test post." }
      before do
        fill_in "Content", with: content
      end

      describe "should show success message" do
        before { click_button "Post" }

        it { should have_content "Micropost created!" }
      end

      it "should create a micropost" do
        expect { click_button "Post" }.to change(Micropost, :count).by(1)
      end
    end

    describe "with invalid data" do
      describe "should show error message" do
        before { click_button "Post" }

        it { should have_content "error" }
      end

      it "should not create a micropost" do
        expect { click_button "Post" }.not_to change(Micropost, :count)
      end
    end
  end
end
