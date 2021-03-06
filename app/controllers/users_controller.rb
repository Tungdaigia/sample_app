class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :find_user, only: %i(show edit update destroy)
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy
  def index
    @users = User.activated.paginate page: params[:page]
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params

    if @user.save
      @user.send_activation_email
      flash[:info] = t "account_activate.check_email_for_active"
      redirect_to root_url
    else
      render :new
    end
  end

  def show
    @follow = current_user.active_relationships.build
    @unfollow = current_user.active_relationships.find_by followed_id: @user.id
    @microposts = Micropost.feed_for(@user).paginate page: params[:page]
  rescue ActiveRecord::RecordNotFound
    render "errors/error_404"
  end

  def edit; end

  def update
    if @user.update user_params
      flash[:success] = t "flash.profile_updated"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t "delete.success"
    else
      flash[:error] = t "delete.fail"
    end
    redirect_to users_url
  end

  private

  def find_user
    @user = User.find_by id: params[:id]
  end

  def admin_user
    redirect_to root_url unless current_user.admin?
  end

  def user_params
    params.require(:user).permit :name, :email, :password,
      :password_confirmation
  end

  def correct_user
    find_user
    redirect_to(root_url) unless @user.current_user? current_user
  end
end
