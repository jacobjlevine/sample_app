def full_title(page_title = '')
  base_title = 'Ruby on Rails Tutorial Sample App'
  if page_title.empty?
    base_title
  else
    "#{base_title} | #{page_title}"
  end
end

def create_user
  FactoryGirl.create(:user)
end

def valid_sign_in(user)
  # Upcase email to ensure that login is case insensitive.
  click_link "Sign In"
  fill_in "Email", with: user.email.upcase
  fill_in "Password", with: user.password
  click_button "Sign In"
end

def invalid_sign_in
  click_button "Sign In"
end

def sign_out
  click_link "Sign Out"
end