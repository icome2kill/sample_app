# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  email           :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  password_digest :string(255)
#  remember_token  :string(255)
#

require 'spec_helper'

describe User do
	before do 
		@user = User.new(name: "Test", email: "test@test.test", password: "password", password_confirmation: "password")
	end

	subject { @user }

	it { should respond_to(:name) }
	it { should respond_to(:email) }
	it { should respond_to(:password_digest) } 
	it { should respond_to(:password) }
	it { should respond_to(:password_confirmation) }
	it { should respond_to(:remember_token) }

	it { should be_valid }

	describe "When user name is not presence" do
		before { @user.name = " " }
		it { should_not be_valid }
	end
	describe "When email is not presence" do
		before { @user.email = " " }
		it { should_not be_valid }
	end
	describe "name is too long" do
		before { @user.name = "a" * 51 }
		it { should_not be_valid }
	end
	describe "invalid email format" do
		it "should not be valid" do
			addresses = %w[user@foo,com user at foo.org example.user@foo. foo@bar baz.com foo@bar+baz.com]
			addresses.each do |invalid_address|
				@user.email = invalid_address
				@user.should_not be_valid
			end
		end
	end
	describe "when email format valid" do
		it "should be valid" do
			addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
			addresses.each do |valid_address|
				@user.email = valid_address
				@user.should be_valid
			end
		end
	end
	describe "when email is already taken" do
		before do
			@user_same_email = @user.dup
			@user_same_email.email = @user.email.upcase
			@user_same_email.save
		end
		it { should_not be_valid }
	end
	describe "when password does not match" do
		before { @user.password_confirmation = "bloh" }
		it { should_not be_valid }
	end
	describe "when password is empty" do
		before { @user.password = @user.password_confirmation = " "}
		it { should_not be_valid }
	end
	describe "when password_confirmation is nil" do
		before { @user.password_confirmation = nil }
		it { should_not be_valid }
	end
	describe "return value of authenticate method" do 
		before { @user.save }
		let(:found_user) { User.find_by_email(@user.email) }
		describe "with valid password" do
			it { should == found_user.authenticate(@user.password) }
		end
		describe "with invalid password" do
			let(:user_for_invalid_password) { found_user.authenticate("invalid") }
			it { should_not == user_for_invalid_password }
			specify { user_for_invalid_password.should be_false } 
		end
	end
	describe "when password is too short" do
		before { @user.password = @user.password_confirmation = "a" * 5}
		it { should be_invalid }
	end
	describe "email address with mixed case" do
    let(:mixed_case_email) { "Foo@ExAMPle.CoM" }
    it "should be saved as all lower-case" do
      @user.email = mixed_case_email
      @user.save
      @user.reload.email.should == mixed_case_email.downcase
    end 
  end
  describe "remember token" do
    before { @user.save }
    its(:remember_token) { should_not be_blank }
  end
end
