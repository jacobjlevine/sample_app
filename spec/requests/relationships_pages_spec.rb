require "spec_helper"

describe "Relationship pages" do
  let(:follower) { create_user }
  let(:followed) { create_user }

  describe "create new relationship" do
    describe "must be logged in" do
      before { post relationships_path }

      specify { expect(response).to redirect_to signin_path }
    end

    describe "cannot follow self" do
      before do
        valid_sign_in follower, no_capybara: true
        post relationships_path(relationship: { followed_id: follower.id })
      end

      specify { expect(response).to redirect_to root_path }
    end
  end

  describe "destroy relationship" do
    before { follower.follow! followed }

    describe "must be logged in" do
      before { delete relationship_path(follower.relationships.find_by(followed_id: followed.id)) }

      specify { expect(response).to redirect_to signin_path }
    end
  end
end