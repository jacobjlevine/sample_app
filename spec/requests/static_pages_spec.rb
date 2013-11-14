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

    it_should_behave_like "all static pages"
    it { should_not have_title('| Home') }

    it "should have valid links" do
      links = []
      links << { text: 'Home', title: ''}
      links << { text: 'Help', title: 'Help'}
      #will have to change when the sign-in page is built.
      links << { text: 'Sign in', title: ''}
      links << { text: 'About', title: 'About'}
      links << { text: 'Contact', title: 'Contact'}
      links << { text: 'Sign up now!', title: 'Sign Up'}
      links << { text: 'sample app', title: ''}

      links.each do | link |
        visit root_path
        click_link link[:text]
        expect(page).to have_title(full_title link[:title])
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
