class UsersController < ApplicationController
  before_filter :signed_in_user, only: [:index, :edit, :update, :destroy, :followers, :following]
  before_filter :correct_user, only: [:edit, :update]
  before_filter :admin_user, only: :destroy
  before_filter :signed_in_user_access, only: [:new, :create]
  def following
    @title = 'Following'
    @user = User.find(params[:id])
    @users = @user.followed_users.paginate(page: params[:page])
    render 'show_follow'
  end
  def followers
    @title = 'Followers'
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end
  def index
    @users = User.paginate(page: params[:page])
  end
  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
  end
  def new
    @user = User.new
  end
  def destroy
    @user = User.find(params[:id])
    if !current_user?(@user)
      flash[:success] = "User destroyed."
      @user.destroy
    else
      flash[:error] = "Cannot delete admin users"
    end
    redirect_to users_url
  end
  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to Sample App!"
      redirect_to @user
    else
      render 'new'
    end
  end
  def edit
  end
  def update
    if @user.update_attributes(params[:user])
      # Handle a successful update.
      flash[:success] = "Profile updated"
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end
  
  private
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end
    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end
    def signed_in_user_access
      redirect_to(root_path) unless current_user.nil?
    end
end
