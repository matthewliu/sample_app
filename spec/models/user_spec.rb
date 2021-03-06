require 'spec_helper'

describe User do

  #Data for tests below
  before(:each) do
    @attr = {
      :name => "Example User",
      :email => "user@example.com",
      :password => "foobar",
      :password_confirmation => "foobar"
    }
  end

  it "should create a new instance given valid attributes" do
    User.create!(@attr)
  end

  # Creates a User object <User id:nil, name: "", email: "user@example.com", created_at :nil, updated_at: nil)
  # The validation in the User.rb model file {validates :name => true} makes this test pass by preventing .save

  it "should require a name" do
     #Changes :name value in test user to an empty string
     no_name_user = User.new(@attr.merge(:name => ""))
     no_name_user.should_not be_valid
  end
  
  it "should require an email address" do
     no_name_user = User.new(@attr.merge(:email => ""))
     no_name_user.should_not be_valid
  end
  
  it "should reject names that are too long" do
     long_name = "a" * 51
     long_name_user = User.new(@attr.merge(:name => long_name))
     long_name_user.should_not be_valid
  end

  it "should accept valid email addresses" do
      addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
      addresses.each do |address|
        valid_email_user = User.new(@attr.merge(:email => address))
        valid_email_user.should be_valid
      end
  end

  it "should reject invalid email addresses" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
      addresses.each do |address|
        invalid_email_user = User.new(@attr.merge(:email => address))
        invalid_email_user.should_not be_valid
      end
  end
  
  it "should reject duplicate email addresses" do
    # Put a user with given email address into the database.
    User.create!(@attr)
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end
  
  it "should reject email addresses identical up to case" do
    #.upcase takes the :email value and turns it upper case
    upcased_email = @attr[:email].upcase
    User.create!(@attr.merge(:email => upcased_email))
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end
  
  describe "password validations" do
    
    it "should require a password" do
      User.new(@attr.merge(:password => "", :password_confirmation => "")).should_not be_valid
    end
    
    it "should require a matching password confirmation" do
      User.new(@attr.merge(:password_confirmation => "invalid")).should_not be_valid
    end
    
    it "should reject short passwords" do
      short = "a" * 5
      hash = @attr.merge(:password => short, :password_confirmation => short)
      User.new(hash).should_not be_valid
    end

    it "should reject long passwords" do
      long = "a" * 41
      hash = @attr.merge(:password => long, :password_confirmation => long)
      User.new(hash).should_not be_valid
    end
  end
  
  describe "password encryption" do
    
    before(:each) do
      @user = User.create!(@attr)
    end
    
    it "should have an encrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end
    
    it "should set the encrypted password" do
      @user.encrypted_password.should_not be_blank
    end
    
    describe "has_password? method" do
      
      it "should be true if the passwords match" do
        @user.has_password?(@attr[:password]).should be_true
      end
      
      it "should be false if the passwords don't match" do
        @user.has_password?("invalid").should be_false
      end
    end
    
    describe "authenticate method" do
      
      it "should return nil on email/password mismatch" do
        wrong_password_user = User.authenticate(@attr[:email], "wrongpass")
        wrong_password_user.should be_nil
      end
      
      it "should return nil for an email address with no user" do
        nonexistent_user = User.authenticate("sex@sex.com", @attr[:password])
        nonexistent_user.should be nil
      end
      
      it "should return the user on email/password match" do
        matching_user = User.authenticate(@attr[:email], @attr[:password])
        matching_user.should == @user
      end
    end
  end
  
  describe "admin users" do
    before(:each) do
      #Referencing @attr user at the top of this test doc
      @user = User.create!(@attr)
    end

    it "should respond to admin" do
      @user.should respond_to(:admin)
    end
    it "should not be an admin by default" do
      @user.should_not be_admin
    end
    it "should be convertible to an admin" do
      @user.toggle!(:admin)
      @user.should be_admin
    end
  end
  
  describe "micropost associations" do
    before(:each) do
      @user = User.create(@attr)
      #Use factory to generate fake posts with timestamps
      @mp1 = Factory(:micropost, :user => @user, :created_at => 1.day.ago)
      @mp2 = Factory(:micropost, :user => @user, :created_at => 1.hour.ago)
    end
    
    #Note the complementary test in micropost_spec.rb
    it "should have a microposts attribute" do
      @user.should respond_to(:microposts)
    end
    
    it "should have the right microposts in the right order (reverse chronological)" do
      @user.microposts.should == [@mp2, @mp1]
    end
    
    #Upon destroying of users, microposts should also be destroyed
    it "should destroy associated microposts" do
      @user.destroy
      [@mp1, @mp2].each do |micropost|
        Micropost.find_by_id(micropost.id).should be_nil
      end
    end
    
    describe "status feed" do
      
      it "should have a feed" do
        @user.should respond_to(:feed)      
      end
      
      it "should have the user's microposts" do
        @user.feed.include?(@mp1).should be_true
        @user.feed.include?(@mp2).should be_true
      end
      
      #Temporary test
      it "should not include a different user's microposts" do
        #Another user's micropost
        @mp3 = Factory(:micropost, :user => Factory(:user, :email => Factory.next(:email)))
        @user.feed.include?(@mp3).should be_false
      end
      
      it "should include the microposts of followed users" do
        followed = Factory(:user, :email => Factory.next(:email))
        @user.follow!(followed)
        mp3 = Factory(:micropost, :user => followed)
        @user.feed.should include(mp3)
      end
      
    end
  end  
  
  describe "relationships" do
    
    before(:each) do
      #Creates a new user using @attr from above
      @user = User.create!(@attr)
      #Creates another user to be followed using Factory
      @followed = Factory(:user)
    end
    
    it "should have a relationships method" do
      @user.should respond_to(:relationships)
    end
    
    it "should have a following method" do
      @user.should respond_to(:following)
    end
    
    it "should have a following? method" do
      @user.should respond_to(:following?)
    end

    it "should have a follow! method" do
      @user.should respond_to(:follow!)
    end
    
    it "should follow another user" do
      #Creates a following relationship first with follow!
      @user.follow!(@followed)
      #Tests to see that @user is following @followed
      @user.should be_following(@followed)
    end
    
    it "should include the followed user in the following array" do
      @user.follow!(@followed)
      #@user.following.should include(@followed)
      @user.following.include?(@followed).should be_true
    end
    
    it "should have an unfollow! method" do
      @user.should respond_to(:unfollow!)
    end
    
    it "should unfollow another user" do
      @user.follow!(@followed)
      @user.unfollow!(@followed)
      @user.should_not be_following(@followed)
    end
    
    it "should remove the followed user in the following array" do
      @user.follow!(@followed)
      @user.unfollow!(@followed)
      #@user.following.should include(@followed)
      @user.following.include?(@followed).should be_false
    end
    
    it "should have a reverse_relationships method" do
      @user.should respond_to(:reverse_relationships)
    end
    
    it "should have a followers method" do
      @user.should respond_to(:followers)
    end
    
    it "should include followed users in the followers array" do
      @user.follow!(@followed)
      @followed.followers.should include(@user)
      
      #@followed.followers.include?(@user).should be_true
    end
    
  end
end
