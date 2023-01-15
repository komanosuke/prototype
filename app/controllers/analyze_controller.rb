class AnalyzeController < ApplicationController
    def index
        @parks = Park.where(user_id: current_user.id)
        @park = @parks.find(params[:park_id])
    end
end
