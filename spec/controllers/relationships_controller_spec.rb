require "spec_helper"

describe RelationshipsController do
  let(:follower) { create_user }
  let(:followed) { create_user }

  describe "create new relationship with AJAX" do
    def ajax_call
      xhr :post, :create, relationship: { followed_id: followed.id }
    end

    before { valid_sign_in follower, no_capybara: true }

    specify { expect do
      ajax_call
    end.to change(Relationship, :count).by(1) }

    it "should respond with success" do
      ajax_call
      expect(response).to be_success
    end
  end

  describe "destroy relationship with AJAX" do
    let(:relationship) { follower.relationships.find_by(followed_id: followed.id) }
    let(:ajax_call) { xhr :delete, :destroy, id: relationship.id }
    before do
      follower.follow! followed
      valid_sign_in follower, no_capybara: true
    end

    specify { expect do
      ajax_call
    end.to change(Relationship, :count).by(-1) }

    it "should respond with success" do
      ajax_call
      expect(response).to be_success
    end
  end
end