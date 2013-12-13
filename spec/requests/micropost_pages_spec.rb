require 'spec_helper'

describe "Micropost Pages" do
  subject { page }

  let(:user) { create_user }

  describe "micropost creation" do
    before do
      valid_sign_in user
      visit root_path
    end

    describe "with valid data" do
      let(:content) { "This is a test post." }
      before do
        fill_in "micropost_content", with: content
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

  describe "delete microposts" do
    let!(:m1) { create_micropost user: user }
    before { valid_sign_in user, no_capybara: true }

    describe "should decrease number of posts" do
      specify { expect do
        delete micropost_path(m1)
      end.to change(Micropost, :count).by(-1) }
    end

    describe "should redirect to root" do
      before { delete micropost_path(m1) }
      specify { expect(response).to redirect_to root_path }
    end

    describe "can't delete another user's posts" do
      let(:wrong_user) { create_user }
      before { valid_sign_in wrong_user, no_capybara: true }

      specify { expect do
        delete micropost_path(m1)
      end.not_to change(Micropost, :count) }
    end
  end
end
