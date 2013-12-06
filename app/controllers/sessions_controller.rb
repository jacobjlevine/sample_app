class SessionsController < ApplicationController
  def new

  end

  def create
    session = params[:session]
    # Find user with specified email.
    user = User.find_by(email: session[:email].downcase)
    # Authenticate user.
    if user && user.authenticate(session[:password])
      # Sign in user
    else
      flash.now[:error] = "Invalid email/password combination"
      render "new"
    end
  end

  def destroy

  end
end
