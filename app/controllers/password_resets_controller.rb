class PasswordResetsController < ApplicationController
  before_action :get_user, only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]

  def new
  end

  def create
    
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:notice] = "パスワード再設定用のメールを送信しました。メールをご確認の上、パスワードの再設定を行ってください。"
      redirect_to root_url
    else
      flash.now[:error] = "メールアドレスが存在しません"
      render "new", status: :unprocessable_entity
    end
  end

  def update
    if params[:user][:password].blank?
      @user.errors.add(:password, :blank)
      render "edit", status: :unprocessable_entity
    elsif @user.update(user_params)
      log_in @user
      flash[:notice] = "パスワードが更新されました"
      redirect_to @user
    else
      render "edit", status: :unprocessable_entity
    end
  end

  def edit
  end

  private
    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    def get_user
      @user = User.find_by(email: params[:email])
    end

    # 正しいユーザーかどうか確認する
    def valid_user
      unless (@user && @user.activated? && @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end

    # トークンが期限切れかどうか確認する
    def check_expiration
      if @user.password_reset_expired?
        flash[:error] = "有効期限を過ぎているため、パスワードの再設定ができません。"
        redirect_to new_password_reset_url
      end
    end
end
