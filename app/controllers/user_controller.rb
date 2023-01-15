class UserController < ApplicationController
    before_action :logged_in_user, except: [:signupmail, :signupmail_success, :signupmail_confirm, :signupmail_error, :register, :signup_success, :back]
    helper_method :create

    def index
        @parks = Park.all
    end

    def account 
        @user = User.find(current_user.id)
        if request.patch? then
            @user.update users_account_params
        end

        @parks = Park.where(user_id: current_user.id)
    end

    def changemail
        logger.debug current_user.id
        @user = User.find(current_user.id)
        if request.patch? then
            @user.update users_email_params
            ChangeMailMailer.send_mail(@user).deliver_now
        end

        @parks = Park.where(user_id: current_user.id)
    end

    def changepwd
        @user = User.find(current_user.id)
        if request.patch? then
            if @user && @user.authenticate(users_password_params[:password])
                @user.update(password: users_password_params[:reset_digest])
            else
                redirect_to '/changepwd_error'
            end
        end

        @parks = Park.where(user_id: current_user.id)
    end

    
    # ここで初めて入力内容を保存します。
    # セキュリティーのためにも一定時間で入力内容の削除を行ってもいいかもしれません。
    def signupmail
        @user = User.new
        logger.debug @user[:email]
        
        if params[:user]
            @user = User.new(email: params[:user][:email])
            NewUserMailer.send_mail(@user).deliver_now
            # if
            redirect_to '/signupmail_success'
            # else
            #     redirect_to '/user/signupmail_error'
            # end //失敗したときの処理を書く？
        end
    end
    
    
    def register
        @user = User.new
    end

    def back
        @user = User.new(users_account_params)
        render :register
    end
    
    def signupmail_confirm
        if params[:user]
            @user = User.new(users_account_params)
        end
        # if @user.invalid?
        #     render :register
        # else
        #     @user = User.create users_account_params
        # end
    end

    def signupmail_success
        
    end

    def signupmail_error
    end

    def signup_success #ここでUserモデルに許可を出す＝アカウント作成（必須項目だけ）
        if users_account_params
            @user = User.create(users_account_params)
        else
            redirect_to '/signupmail_error'
        end
    end

    private
    def users_account_params
        params.require(:user).permit(:name, :email, :password, :zip,  :prefecture, :city, :street, :tel, :municipality, :division, :profile)
    end

    private
    def users_email_params
        params.require(:user).permit(:email)
    end

    private
    def users_password_params
        params.require(:user).permit(:password, :reset_digest)
    end


    
end
