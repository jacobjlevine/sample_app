require 'spec_helper'

describe User do

  before { @user = User.new(name: 'Example User', email: 'UseR@Example.com',
                        password: 'foobar', password_confirmation: 'foobar') }

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest)}
  it { should respond_to(:password)}
  it { should respond_to(:password_confirmation)}
  it { should respond_to(:authenticate) }
  it { should be_valid }

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
      @new_user = @user.dup
      @new_user.email.upcase!
      @new_user.save
    end

    it { should_not be_valid }
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
end
