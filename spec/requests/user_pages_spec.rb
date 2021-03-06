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
    let!(:m1) { create_micropost user: user, content: "foo", created_at: 1.days.ago }
    let!(:m2) { create_micropost user: user, content: "bar", created_at: 2.days.ago }
    before { visit user_path(user) }

    it { should have_content(user.name) }
    it { should have_title(user.name) }
    # note: full test for follow count section appears in static_pages_spec
    it { should have_selector("div.follow-counts") }

    describe "microposts" do
      it { should have_content m1.content }
      it { should have_content m2.content }
      it { should have_content "Microposts (2)" }
      it { should have_content "Posted 1 day ago." }
      it { should have_content "Posted 2 days ago." }

      describe "delete link" do

        describe "should not exist when logged out" do
          it { should_not have_link "delete", micropost_path(m1) }
        end

        describe "should exist for own posts" do
          before do
            valid_sign_in user
            visit user_path(user)
          end

          it { should have_link "delete", micropost_path(m1) }
        end

        describe "should not exist for others' posts" do
          let(:other_user) { create_user }
          let!(:m3) { create_micropost user: other_user, content: "foo", created_at: 1.days.ago }
          before { visit user_path(other_user) }

          it { should_not have_link "delete", micropost_path(m3) }
        end
      end
    end

    describe "follow/unfollow button" do
      let(:follow_text) { "Follow" }
      let(:unfollow_text) { "Unfollow" }
      let(:followed_user) { create_user }
      let(:unfollowed_user) { create_user }
      before do
        user.follow!(followed_user)
      end

      describe "shouldn't appear when user logged out" do
        it { should_not have_button follow_text }
        it { should_not have_button unfollow_text }
      end

      describe "shouldn't appear when viewing own profile" do
        before do
          valid_sign_in user
          visit user_path(user)
        end

        it { should_not have_button follow_text }
        it { should_not have_button unfollow_text }
      end

      describe "follow button" do
        before do
          valid_sign_in user
          visit user_path(unfollowed_user)
        end

        describe "should appear on profiles of unfollowed users" do
          it { should have_button follow_text }
          it { should_not have_button unfollow_text }
        end

        describe "toggle button" do
          before { click_button follow_text }

          it { should have_button unfollow_text }
        end

        specify { expect { click_button follow_text }.to change(Relationship, :count).by(1) }
      end

      describe "unfollow button" do
        before do
          valid_sign_in user
          visit user_path(followed_user)
        end

        describe "should appear on profiles of followed users" do
          it { should_not have_button follow_text }
          it { should have_button unfollow_text }
        end

        describe "toggle button" do
          before { click_button unfollow_text }

          it { should have_button follow_text }
        end

        specify { expect { click_button unfollow_text }.to change(Relationship, :count).by(-1) }
      end
    end
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
    let(:user) { create_user }
    before(:each) do
      create_user
      valid_sign_in user
      visit users_path
    end

    it { should have_title "All Users" }
    it { should have_content "All Users" }

    describe "should have pagination" do
      before(:all) { create_user times: 30 }
      after(:all) { User.delete_all }

      it { should have_selector("div.pagination") }

      it "should list each user" do
        User.paginate(page: 1).each do |user|
          expect(page).to have_selector("li", text: user.name)
        end
      end
    end

    describe "delete links" do
      describe "should not be visible for regular users" do
        it { should_not have_link("delete") }
      end

      describe "admins" do
        let(:admin) { create_user({}, :admin) }
        before { valid_sign_in admin, return_to: users_path }

        it { should have_link("delete", href: user_path(User.first)) }
        it "should be able to delete user" do
          expect do
            click_link("delete", match: :first)
          end.to change(User, :count).by(-1)
        end

        it "should not be able to delete themselves" do
          should_not have_link("delete", href: user_path(admin))
        end
      end
    end
  end

  describe "following/followers pages" do
    let(:follower) { create_user }
    let(:followed_user) { create_user }
    before do
      follower.follow! followed_user
      # doesn't matter which user is signed in as long as one of them is
      valid_sign_in follower
    end

    describe "following page" do
      before do
        visit following_user_path follower
      end

      it { should have_title full_title "Following" }
      it { should have_selector "h3", "Following" }
      it { should have_link followed_user.name, user_path(followed_user) }
    end

    describe "followers page" do
      before do
        visit followers_user_path followed_user
      end

      it { should have_title full_title "Followers" }
      it { should have_selector "h3", "Followers" }
      it { should have_link follower.name, user_path(follower) }
    end
  end

  describe "admin attribute should not be available in params" do
    let(:user) { create_user }
    before do
      valid_sign_in user, no_capybara: true
      patch user_path(user), user: { name: user.name,
                                    email: user.email,
                                    password: user.password,
                                    password_confirmation: user.password,
                                    admin: true }
    end

    specify { expect(user.reload.admin).to be_false }
  end

  describe "logged-in users shouldn't be able to access" do
    let(:user) { create_user }

    describe "the signup page" do
      before do
        valid_sign_in user
        visit signup_path
      end

      it { should have_title full_title(user.name) }
    end

    describe "Users#new" do
      before do
        valid_sign_in user, no_capybara: true
        get signup_path
      end

      specify { expect(response).to redirect_to user_path(user) }
    end

    describe "Users#create" do
      before do
        valid_sign_in user, no_capybara: true
        post users_path
      end

      specify { expect(response).to redirect_to user_path(user) }
    end
  end
end