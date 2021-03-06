class SessionsController < ApplicationController
  def new

  end

  def create
    email = params[:email]
    password = params[:password]
    # Find user with specified email.
    user = User.find_by(email: email.downcase)
    # Authenticate user.
    if user && user.authenticate(password)
      sign_in user
      redirect_back_or user
    else
      flash.now[:error] = "Invalid email/password combination"
      render "new"
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end
end
