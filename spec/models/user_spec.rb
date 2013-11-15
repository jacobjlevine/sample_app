require 'spec_helper'

describe User do

  before { @user = User.new(name: 'Example User', email: 'UseR@Example.com')}

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should be_valid }

  #test all mandatory attributes
  [:name, :email].each do | attribute |
    describe "when #{attribute} is not present" do
      it "should be invalid" do
        #test all types of blank values
        [nil, '', ' '].each do | blank_string |
          @user[attribute] = blank_string
          expect(@user).not_to be_valid
        end
      end
    end
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
      addresses = %w[user@foo,com user_at_foo.org example.user@foo. foo@bar_baz.com foo@bar+baz.com]
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

  describe "when email address is already in database" do
    #create copy of @user and put it in database. @user should now be invalid.
    before do
      new_user = @user.dup
      new_user.email.upcase!
      new_user.save
    end

    it { should_not be_valid }
  end
end
