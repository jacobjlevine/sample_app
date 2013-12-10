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
    let(:user) { create_user }
    before { visit user_path(user) }

    it { should have_content(user.name) }
    it { should have_title(user.name) }
  end

  describe "edit" do
    let(:user) { create_user }
    before do
      valid_sign_in(user)
      visit edit_user_path(user)
    end

    describe "page" do
      it { should have_content("Update your profile") }
      it { should have_title("Edit User") }
      it { should have_link("Change", href: "http://gravatar.com/emails") }
    end

    describe "with invalid information" do
      # password confirmation starts out blank so should return error
      before { click_button "Save" }

      it { should have_content("error") }
    end

    describe "with valid information" do
      let(:new_name) { "New Name" }
      let(:new_email) { "new_email@test.com" }

      before do
        fill_in "Name", with: new_name
        fill_in "Email", with: new_email
        fill_in "Password", with: user.password
        fill_in "Confirmation", with: user.password
        click_button "Save"
      end

      it { should have_title new_name }
      it { should have_selector("div.alert.alert-success")}
      specify { expect(user.reload.email).to eq new_email }

    end

  end

  describe "user index" do
    before do
      create_user name: "Bob", email: "bob@example.com"
      create_user name: "Bill", email: "bill@example.com"
      visit users_path
      fill_in "Email", with: user.email
      fill_in "Password", with: user.password
      click_button "Sign In"
    end
    let(:user) { create_user }

    it { should have_title "All Users" }
    it { should have_content "All Users" }

    it "should list each user" do
      User.all.each do |user|
        expect(page).to have_selector("li", text: user.name)
      end
    end
  end

end