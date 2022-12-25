class OthersController < ApplicationController
    before_action :logged_in_user

    def link
        @user = User.find_by(id: session[:user_id]) #現在のユーザー
    end
end
