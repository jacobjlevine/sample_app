class UsersController < ApplicationController
  before_action :signed_in_user, only: [:edit, :update, :index, :destroy]
  before_action :signed_out_user, only: [:new, :create]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:destroy]
  before_action :not_self, only: [:destroy]

  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = 'Welcome to the Sample App!'
      sign_in(@user)
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "Save successful!"
      redirect_to @user
    else
      render "edit"
    end
  end

  def destroy
    User.delete(params[:id])
    flash[:success] = "User deleted."
    redirect_to users_url
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    # Before filters

    # see sessions_helper for definition
    # def signed_in_user
    # end

    def signed_out_user
      if signed_in?
        redirect_to user_path(current_user)
      end
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to root_url unless current_user == @user
    end

    def admin_user
      redirect_to root_url unless current_user.admin?
    end

    def not_self
      @user = User.find(params[:id])
      if current_user == @user
        redirect_to users_url
      end
    end

end
