class AdminSessionsController < ApplicationController
  def new
  end

  def create
    admin = Admin.find_by(name: params[:session][:name])
    if admin && admin.authenticate(params[:session][:password])
      admin_log_in admin
      redirect_to '/admin/index'
    else
      render 'new'
    end
  end

  def destroy
    admin_log_out if admin_logged_in?
    redirect_to '/admin/index'
  end
end
