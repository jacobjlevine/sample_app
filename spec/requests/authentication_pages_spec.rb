require 'spec_helper'

describe "AuthenticationPages" do

  subject { page }

  describe "signin page" do
    before { visit signin_path }

    it { should have_content 'Sign In' }
    it { should have_title 'Sign In' }
  end

  describe "signin" do
    before { visit signin_path }

    describe "with invalid information" do
      before { invalid_sign_in }

      it { should have_title 'Sign In' }
      it { should have_selector 'div.alert.alert-error', text: 'Invalid' }

      describe "after visiting another page" do
        before { click_link "Home" }

        it { should_not have_selector 'div.alert.alert-error', text: 'Invalid' }
      end
    end

    describe "with valid information" do
      before { valid_sign_in(user) }
      let(:user) { create_user }

      it { should have_title user.name }
      it { should have_link('Sign Out', href: signout_path) }
      it { should have_link('Profile', href: user_path(user)) }
      it { should_not have_link('Sign In', href: signin_path) }

    end
  end


end
