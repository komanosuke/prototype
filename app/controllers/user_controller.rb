class UserController < ApplicationController
    before_action :logged_in_user

    def index
        @parks = Park.all
    end
end
