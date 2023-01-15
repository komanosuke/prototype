class PasswordResetsController < ApplicationController
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

  def edit
  end
end
