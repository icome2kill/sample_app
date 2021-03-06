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
#  admin           :boolean          default(FALSE)
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
	it { should respond_to(:authenticate) }
	it { should respond_to(:microposts) }
	it { should respond_to(:feed) }
	it { should respond_to(:relationships) }
  it { should respond_to(:followed_users) }
  it { should respond_to(:following?) }
  it { should respond_to(:follow!) }
  it { should respond_to(:reverse_relationships) }
  it { should respond_to(:followers) }
  
	it { should be_valid }
	it { should_not be_admin }

  describe "following" do
    let(:other_user) {FactoryGirl.create(:user)}
    before do
      @user.save
      @user.follow!(other_user)
    end
    it {should be_following(other_user)}
    its(:followed_users) {should include(other_user)}
    describe "and unfollowing" do
      before {@user.unfollow!(other_user)}
      it {should_not be_following(other_user)}
      its(:followed_users) {should_not include(other_user)}
    end
    describe "followed user" do
      subject { other_user }
      its(:followers) { should include(@user) }
    end
  end

  describe "with admin attribute set to 'true'" do
    before do
      @user.save!
      @user.toggle!(:admin)
    end

    it { should be_admin }
  end

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
  describe "relationship associations" do
    let(:followed_user) { FactoryGirl.create(:user) }
    before do
      @user.save
      @user.follow!(followed_user)
    end
    it "should destroy asscociated relationships" do
      relationships = @user.relationships.dup
      @user.destroy
      relationships.should_not be_empty
      relationships.each do |r|
        Relationship.find_by_id(r.id).should be_nil
      end
    end
  end
  describe "micropost associations" do

    before { @user.save }
    let!(:older_micropost) do 
      FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago)
    end
    let!(:newer_micropost) do
      FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago)
    end

    it "should have the right microposts in the right order" do
      @user.microposts.should == [newer_micropost, older_micropost]
    end
    it "should destroy associated microposts" do
      microposts = @user.microposts.dup
      @user.destroy
      microposts.should_not be_empty
      microposts.each do |micropost|
        Micropost.find_by_id(micropost.id).should be_nil
      end
    end
    describe "status" do
      let(:unfollowed_post) do
        FactoryGirl.create(:micropost, user: FactoryGirl.create(:user))
      end
      let(:followed_user) { FactoryGirl.create(:user) }
      before do
        @user.follow!(followed_user)
        3.times { followed_user.microposts.create!(content: "Blah blah")}
      end
      its(:feed) { should include(newer_micropost) }
      its(:feed) { should include(older_micropost) }
      its(:feed) { should_not include(unfollowed_post) }
      its(:feed) do
        followed_user.microposts.each do |micropost|
          should include(micropost)
        end
      end
    end
  end
end
