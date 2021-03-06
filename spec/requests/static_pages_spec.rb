require 'spec_helper'

describe "Static pages" do
  subject { page }

  shared_examples_for "all static pages" do
    it { should have_selector('h1', text: heading) }
    it { should have_title(full_title page_title) }
  end

  describe "Home page" do
    before { visit root_path }
    let(:heading) { 'Welcome to the Sample App' }
    let(:page_title) { '' }
    def should_have_valid_links(links)
      links.each do | link |
        visit root_path
        click_link link[:text]
        expect(page).to have_title(full_title link[:title])
      end
    end

    def should_not_have_links(links)
      links.each do | link |
        visit root_path
        expect(page).not_to have_link(link[:text])
      end
    end

    it_should_behave_like "all static pages"
    it { should_not have_title('| Home') }

    describe "should have valid links" do
      let(:user) { create_user }
      let(:links) do
        links = []
        links << { text: 'Home', title: ''}
        links << { text: 'Help', title: 'Help'}
        links << { text: 'About', title: 'About'}
        links << { text: 'Contact', title: 'Contact'}
        links << { text: 'sample app', title: ''}
      end
      let(:signed_out_links) do
        signed_out_links = []
        signed_out_links << { text: 'Sign In', title: 'Sign In'}
      end
      let(:signed_in_links) do
        signed_in_links = []
        signed_in_links << { text: 'Users', title: 'All Users' }
        signed_in_links << { text: 'Profile', title: user.name }
        signed_in_links << { text: 'Settings', title: 'Edit' }
        signed_in_links << { text: 'Sign Out', title: '' }
      end

      describe "before sign in" do
        it { should_have_valid_links(links) }
        it { should_have_valid_links(signed_out_links) }
        it { should_not_have_links(signed_in_links) }
      end

      describe "after sign in" do
        before { valid_sign_in(user) }

        it { should_have_valid_links(links) }
        it { should_have_valid_links(signed_in_links) }
        it { should_not_have_links(signed_out_links) }

        describe "and sign out" do
          before { sign_out }

          it { should_have_valid_links(signed_out_links) }
          it { should have_title full_title }
        end
      end
    end

    describe "for signed in users" do
      let(:user) { create_user }
      let(:followed_user) { create_user }
      let(:unfollowed_user) { create_user }
      let!(:m1) { create_micropost(user: user) }
      let!(:m2) { create_micropost(user: user) }
      let!(:followed_post) { create_micropost(user: followed_user) }
      let!(:unfollowed_post) { create_micropost(user: unfollowed_user) }
      before do
        user.follow!(followed_user)
        valid_sign_in user
        visit root_path
      end

      describe "should render the user feed" do
        specify do
          user.feed.each do |post|
            expect(page).to have_selector("li##{post.id}", text: post.content)
          end
        end

        it "should include posts by followed users" do
          expect(page).to have_selector("li##{followed_post.id}", text: followed_post.content)
        end

        it "should not include posts by unfollowed users" do
          expect(page).not_to have_selector("li##{unfollowed_post.id}", text: unfollowed_post.content)
        end
      end

      describe "delete links" do

        describe "should work" do
          specify { expect do
            click_link "delete", match: :first
          end.to change(Micropost, :count).by(-1) }
        end

        describe "should exist only for own posts" do
          specify { expect(page).not_to have_link "delete", href: micropost_path(followed_post) }
        end
      end

      describe "following counts" do

        it { should have_link "1 following", href: following_user_path(user) }
        it { should have_link "0 followers", href: followers_user_path(user) }
      end

      describe "follower counts" do
        before do
          valid_sign_in followed_user
          visit root_path
        end

        it { should have_link "0 following", href: following_user_path(followed_user) }
        it { should have_link "1 follower", href: followers_user_path(followed_user) }
      end
    end
  end

  describe "Help page" do
    before { visit help_path }
    let(:heading) { 'Help' }
    let(:page_title) { 'Help' }

    it_should_behave_like "all static pages"
  end

  describe "About page" do
    before { visit about_path }
    let(:heading) { 'About Us' }
    let(:page_title) { 'About Us' }

    it_should_behave_like "all static pages"
  end

  describe "Contact page" do
    before { visit contact_path }
    let(:heading) { 'Contact' }
    let(:page_title) { 'Contact' }

    it_should_behave_like "all static pages"
  end
end
