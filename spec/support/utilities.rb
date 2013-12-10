def full_title(page_title = '')
  base_title = 'Ruby on Rails Tutorial Sample App'
  if page_title.empty?
    base_title
  else
    "#{base_title} | #{page_title}"
  end
end

def create_user(options = {})
  #if email.blank?
  #  FactoryGirl.create(:user)
  #else
    FactoryGirl.create(:user, options)
  #end
end

def valid_sign_in(user, options={} )
  if options[:no_capybara]
    # Sign in when not using Capybara as well.
    remember_token = User.new_remember_token
    cookies[:remember_token] = remember_token
    user.update_attribute(:remember_token, User.encrypt(remember_token))
  else
    # Upcase email to ensure that login is case insensitive.
    visit signin_path
    fill_in "Email", with: user.email.upcase
    fill_in "Password", with: user.password
    click_button "Sign In"
  end
end

def invalid_sign_in
  click_button "Sign In"
end

def sign_out
  click_link "Sign Out"
end