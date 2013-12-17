class RelationshipsController < ApplicationController
  before_action :signed_in_user
  before_action :not_self, only: :create

  def create
    @user = User.find(params[:relationship][:followed_id])
    current_user.follow! @user
    respond_to do |format|
      format.html { redirect_to user_path(@user) }
      format.js { render "update_follow_elements" }
    end
  end

  def destroy
    relationship = Relationship.find(params[:id])
    @user = User.find(relationship[:followed_id])
    current_user.unfollow! @user
    respond_to do |format|
      format.html { redirect_to user_path(@user) }
      format.js { render "update_follow_elements" }
    end
  end

  private

    def not_self
      if current_user.id == params[:relationship][:followed_id].to_i
        redirect_to root_path
      end
    end
end