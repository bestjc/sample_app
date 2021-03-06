class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy

  def index
    # @users = User.paginate(page: params[:page])
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
    redirect_to root_url and return unless @user.activated
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params_user)
    if @user.save
      # UserMailer.account_activation(@user).deliver_now
      @user.send_activation_email
      # log_in @user
      # flash[:success] = "Welcome to the Sample App!"
      # redirect_to @user
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      render 'new'
    end
  end

  def edit
    # 见 correct_user 方法
    # @user = User.find(params[:id])
  end

  def update
    # 见 correct_user 方法
    # @user = User.find(params[:id])
    if @user.update_attributes(params_user)
      # 处理更新成功的情况
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  private

    def params_user
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end

    # 前置过滤器

    # 确保是当前用户
    def correct_user
      @user = User.find_by(id: params[:id])
      redirect_to root_url unless current_user?(@user)
    end

    # 确保是管理员
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
