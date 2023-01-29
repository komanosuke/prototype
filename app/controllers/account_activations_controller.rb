class AccountActivationsController < ApplicationController
    def edit
        user = User.find_by(email: params[:email])
        p user
        p !user.activated?
        p user.authenticated?(:activation, params[:id])
        if user && !user.activated? && user.authenticated?(:activation, params[:id])
            user.activate
            log_in user
            flash[:notice] = "アカウントが有効化されました"
          redirect_to '/signup_success'
        else
            flash[:error] = "この有効化リンクは無効です"
            redirect_to root_url
        end
      end
end
