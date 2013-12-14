def full_title(page_title = '')
  base_title = 'Ruby on Rails Tutorial Sample App'
  if page_title.empty?
    base_title
  else
    "#{base_title} | #{page_title}"
  end
end

def create_user(options = {}, user_type = :user)
  # If "times" option exists, use it and delete it from the hash
  # so it doesn't interfere with the FactoryGirl.create method
  # otherwise just create a single user
  times = options.delete(:times) || 1
  # Can't wrap create statement if times == 1 because then the
  # user won't be returned.
  if times == 1
    FactoryGirl.create(user_type, options)
  else
    times.times { FactoryGirl.create(user_type, options) }
  end
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
  return_to = options[:return_to]
  if return_to
    visit return_to
  end
end

def invalid_sign_in
  click_button "Sign In"
end

def sign_out
  click_link "Sign Out"
end

def create_micropost(options = {})
  FactoryGirl.create(:micropost, options)
end