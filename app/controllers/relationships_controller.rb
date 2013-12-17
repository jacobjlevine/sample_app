class RelationshipsController < ApplicationController
  before_action :signed_in_user
  before_action :not_self, only: :create
  before_action :wrong_user, only: :destroy

  def create
    @user = User.find(params[:relationship][:followed_id])
    current_user.follow! @user
    respond
  end

  def destroy
    @user = User.find(@relationship[:followed_id])
    current_user.unfollow! @user
    respond
  end

  private

    def not_self
      if current_user.id == params[:relationship][:followed_id].to_i
        redirect_to root_path
      end
    end

    def wrong_user
      @relationship = Relationship.find(params[:id])
      if current_user[:id] != @relationship[:follower_id]
        redirect_to root_path
      end
    end

    def respond
      respond_to do |format|
        format.html { redirect_to @user }
        format.js { render "update_follow_elements" }
      end
    end
end