class UserController < ApplicationController
    before_action :logged_in_user, except: [:signupmail, :signupmail_success, :signupmail_confirm, :signupmail_error, :register, :signup_success]
    helper_method :create

    def index
        @parks = Park.all
    end

    def account
        @user = User.find(current_user.id)
        if request.patch? then
            @user.update users_account_params
        end
    end

    def changemail
        @user = User.find(current_user.id)
        if request.patch? then
            @user.update users_email_params
        end
    end

    
    # ここで初めて入力内容を保存します。
    # セキュリティーのためにも一定時間で入力内容の削除を行ってもいいかもしれません。
    def signupmail
        @user = User.new
        logger.debug @user[:email]
        
        logger.debug 'ああああああああああ'
        if params[:user]
            @user = User.new(email: params[:user][:email])
            NewUserMailer.send_mail(@user).deliver_now
            # if
            redirect_to '/user/signupmail_success'
            # else
            #     redirect_to '/user/signupmail_error'
            # end //失敗したときの処理を書く？
        end
    end
    
    
    def register
        @user = User.new
        if request.post? then
            @user = User.create users_account_params
            redirect_to '/user/signupmail_confirm'
        end
    end
    
    def signupmail_confirm
    end

    def signupmail_success
    end

    def signupmail_error
    end

    def signup_success
    end

    private
    def users_account_params
        params.require(:user).permit(:display_name, :municipality, :division)
    end

    private
    def users_email_params
        params.require(:user).permit(:email)
    end


    
end
