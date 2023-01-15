class ApplicationController < ActionController::Base
    include SessionsHelper
    include AdminSessionsHelper
    protect_from_forgery

    private
    # ログイン済みユーザーかどうか確認
    def logged_in_user
      unless logged_in?
        redirect_to login_url
      end
    end

    private
    def logged_in_admin
      unless admin_logged_in?
        redirect_to admin_login_url
      end
    end

    # 以下エラーページ設定
    unless Rails.env.development?
      rescue_from Exception,                      with: :_render_500
      rescue_from ActiveRecord::RecordNotFound,   with: :_render_404
      rescue_from ActionController::RoutingError, with: :_render_404
    end
  
    def routing_error
      raise ActionController::RoutingError, params[:path]
    end
  
    private
    def _render_404(e = nil)
      logger.info "Rendering 404 with excaption: #{e.message}" if e

      if request.format.to_sym == :json
        render json: { error: "404 Not Found" }, status: :not_found
      else
        render "errors/404.html", status: :not_found, layout: "error"
      end
    end

    def _render_500(e = nil)
      logger.error "Rendering 500 with excaption: #{e.message}" if e

      if request.format.to_sym == :json
        render json: { error: "500 Internal Server Error" }, status: :internal_server_error
      else
        render "errors/500.html", status: :internal_server_error, layout: "error"
      end
    end
end