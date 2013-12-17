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

    describe "successfully" do
      before { valid_sign_in follower, no_capybara: true }

      specify { expect do
        post relationships_path(relationship: { followed_id: followed.id })
      end.to change(Relationship, :count).by(1) }
    end
  end

  describe "destroy relationship" do
    let(:relationship) { follower.relationships.find_by(followed_id: followed.id) }
    before { follower.follow! followed }

    describe "must be logged in" do
      before { delete relationship_path(relationship) }

      specify { expect(response).to redirect_to signin_path }
    end

    describe "successfully" do
      before { valid_sign_in follower, no_capybara: true }

      specify { expect do
        delete relationship_path(relationship)
      end.to change(Relationship, :count).by(-1) }
    end
  end
end