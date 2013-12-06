require 'spec_helper'

describe "User pages" do
  subject { page }

  describe "signup page" do
    before { visit signup_path }

    it { should have_content 'Sign up'}
    it { should have_title(full_title 'Sign Up')}
  end

  describe "signup" do
    before { visit signup_path }
    let(:submit) { 'Create my account' }

    describe "with valid information" do
      before do
        fill_in 'Name', with: 'Example User'
        fill_in 'Email', with: sample_email
        fill_in 'Password', with: 'testpw'
        fill_in 'Confirmation', with: 'testpw'
      end
      let(:sample_email) { 'example@railstutorial.org' }

      it "should create a user" do
        expect { click_button(submit) }.to change(User, :count).by(1)
      end

      describe "after saving the user" do
        before { click_button(submit) }
        let(:user) { User.find_by(email: sample_email) }

        it { should have_title(user.name) }
        it { should have_selector('div.alert.alert-success', text: 'Welcome') }
        it { should have_link("Sign Out") }
      end
    end

    describe "with invalid information" do
      it "should create a user" do
        expect { click_button(submit) }.not_to change(User, :count)
      end

      describe "after submission" do
        before { click_button(submit) }

        it { should have_title('Sign Up')}
        it { should have_content('errors') }
      end
    end
  end

  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }
    before { visit user_path(user) }

    it { should have_content(user.name) }
    it { should have_title(user.name) }
  end

end