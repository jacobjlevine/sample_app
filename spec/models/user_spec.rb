require 'spec_helper'

describe User do

  before { @user = User.new(name: 'Example User', email: 'UseR@Example.com',
                        password: 'foobar', password_confirmation: 'foobar') }

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:admin) }
  it { should respond_to(:microposts) }
  it { should respond_to(:relationships) }
  it { should respond_to(:followed_users) }
  it { should respond_to(:reverse_relationships) }
  it { should respond_to(:followers) }
  it { should respond_to(:following?) }
  it { should respond_to(:follow!) }
  it { should respond_to(:unfollow!) }

  it { should be_valid }
  it { should_not be_admin }

  #test all mandatory attributes
  [:name, :email].each do | attribute |
    describe "when #{attribute} is blank" do
      it "should be invalid" do
        #test all types of blank values
        [nil, '', ' '].each do | blank_string |
          @user[attribute] = blank_string
          expect(@user).not_to be_valid
        end
      end
    end
  end

  #when password and password_confirmation match but are blank, should be invalid
  describe "when password is blank" do
    it "should be invalid" do
      #test all types of blank values
      [nil, '', ' '].each do | blank_string |
        @user = User.new(name: 'Example User', email: 'UseR@Example.com',
                         password: blank_string, password_confirmation: blank_string, password_digest: 'xxx')
        expect(@user).not_to be_valid
      end
    end
  end

  describe "when password and confirmation don't match" do
    before { @user.password_confirmation = 'mismatch' }

    it { should_not be_valid }
  end

  describe "when name is the max length" do
    before { @user.name = 'a' * 50 }
    it { should be_valid }
  end

  describe "when name is too long" do
    before { @user.name = 'a' * 51 }
    it { should_not be_valid }
  end

  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo. foo@bar_baz.com foo@bar+baz.com foo@bar..com]
      addresses.each do | invalid_address |
        @user.email = invalid_address
        expect(@user).not_to be_valid
      end
    end
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM a_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do | valid_address |
        @user.email = valid_address
        expect(@user).to be_valid
      end
    end
  end

  describe "email address" do
    #create copy of @user and put it in database. @user should now be invalid.
    #also verify email is downcased when saved
    before do
      @new_user = @user.dup
      @new_user.email.upcase!
      @new_user.save
    end

    it "is already in database" do
      should_not be_valid
    end
    it "should be downcased" do
      expect(@new_user.email).to eq @user.email.downcase
    end
  end

  describe "return value of authenticate method" do
    #verify that authenticate returns user if password matches
    #and returns false if not
    before { @user.save }
    let(:found_user) { User.find_by(email: @user.email) }

    describe "with valid password" do
      it { should eq found_user.authenticate(@user.password) }
    end

    describe "with invalid password" do
      let(:user_with_invalid_password) { found_user.authenticate('invalid') }

      it { should_not eq user_with_invalid_password }
      specify { expect(user_with_invalid_password).to be_false }
    end
  end

  describe "validates password length" do

    describe "by rejecting short passwords" do
      let(:too_short_password) { 'a' * 5 }

      it do
        @user.password = too_short_password
        @user.password_confirmation = too_short_password

        should_not be_valid
      end
    end

    describe "by accepting appropriately lengthed passwords" do
      let(:ok_length_password) { 'a' * 6 }

      it do
        @user.password = ok_length_password
        @user.password_confirmation = ok_length_password

        should be_valid
      end
    end
  end

  describe "remember token" do
    before { @user.save }
    its(:remember_token) { should_not be_blank }
  end

  describe "when admin attribute set to 'true'" do
    before do
      @user.save!
      @user.toggle!(:admin)
    end
  end

  describe "micropost associations" do
    before { @user.save }
    let!(:older_post) { create_micropost(user: @user, created_at: 1.day.ago)}
    let!(:newer_post) { create_micropost(user: @user, created_at: 1.hour.ago)}

    it "should have the microposts in order from newest to oldest" do
      expect(@user.microposts.to_a).to eq [newer_post, older_post]
    end

    describe "when user is deleted" do
      let!(:microposts) { @user.microposts.to_a }
      before do
        @user.destroy
      end

      specify "microposts should be deleted" do
        expect(microposts).not_to be_empty
        expect(Micropost.where(user_id: @user.id)).to be_empty
      end
    end

    describe "status feed" do
      let(:other_user) { create_user }
      let(:unfollowed_post) { create_micropost user: other_user }

      its(:feed) { should include(newer_post) }
      its(:feed) { should include(older_post) }
      its(:feed) { should_not include(unfollowed_post) }
    end
  end

  describe "following" do
    let(:followed_user) { create_user }
    before do
      @user.save
      @user.follow!(followed_user)
    end

    it { should be_following(followed_user) }
    its(:followed_users) { should include(followed_user) }
    specify { expect(followed_user.followers).to include(@user) }

    describe "and unfollowing" do
      before { @user.unfollow!(followed_user) }

      it { should_not be_following(followed_user) }
      its(:followed_users) { should_not include(followed_user) }
      specify { expect(followed_user.followers).not_to include(@user) }
    end
  end
end
