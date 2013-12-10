require "spec_helper"

describe "Authentication" do

  subject { page }

  describe "signin page" do
    before { visit signin_path }

    it { should have_content "Sign In" }
    it { should have_title "Sign In" }
  end

  describe "signin" do
    before { visit signin_path }

    describe "with invalid information" do
      before { invalid_sign_in }

      it { should have_title "Sign In" }
      it { should have_selector "div.alert.alert-error", text: "Invalid" }

      describe "after visiting another page" do
        before { click_link "Home" }

        it { should_not have_selector "div.alert.alert-error", text: "Invalid" }
      end
    end

    describe "with valid information" do
      before { valid_sign_in(user) }
      let(:user) { create_user }

      it { should have_title user.name }
      it { should have_link("Users", users_path) }
      it { should have_link("Sign Out", href: signout_path) }
      it { should have_link("Profile", href: user_path(user)) }
      it { should_not have_link("Sign In", href: signin_path) }

    end
  end

  describe "authorization" do
    describe "for non-signed in users" do
      let(:user) { create_user }

      describe "in the Users Controller" do
        describe "visiting the edit page" do
          before { visit edit_user_path(user) }

          it { should have_title "Sign In" }
          it { should have_text "Please sign in." }
        end

        describe "submitting to the update action" do
          before { patch user_path(user) }

          specify { expect(response).to redirect_to(signin_path) }
        end

        describe "visiting the user index" do
          before { visit users_path }

          it { should have_title "Sign In" }
        end
      end

      describe "when attempting to visit a protected site" do
        before do
          visit edit_user_path(user)
          fill_in "Email", with: user.email
          fill_in "Password", with: user.password
          click_button "Sign In"
        end

        it "after signing in, should render the desired protected page" do
          expect(page).to have_title("Edit User")
        end
      end
    end

    describe "as wrong user" do
      let(:user) { create_user }
      let(:wrong_user) { create_user(email: "wrong@example.com") }

      before { valid_sign_in user, no_capybara: true }

      describe "submitting GET request to Users#edit" do
        before { get edit_user_path(wrong_user) }

        specify { expect(response.body).not_to match(full_title "Edit User") }
        specify { expect(response).to redirect_to(root_url) }
      end

      describe "submitting PATCH request to Users#update" do
        before { patch user_path(wrong_user) }

        specify { expect(response).to redirect_to(root_url) }
      end
    end
  end
end
