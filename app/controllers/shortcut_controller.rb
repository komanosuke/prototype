class ShortcutController < ApplicationController
    before_action :logged_in_user

    def index
        @parks = Park.where(user_id: current_user.id)
        @park = @parks.find(params[:park_id])
        @benches = Bench.where(park_id: @park.id)

        mac_addresses = []
        @benches.each do |bench|
            mac_addresses.push(bench.mac_address)
        end

        @data = []
        mac_addresses.each do |mac|
            @data.push(TmpDatum.where(mac_address: mac).last.data)
        end

        @shortcut = Shortcut.new
        @shortcuts = Shortcut.where(park_id: @park.id)

        # shortcut = Shortcut.find(1)
        # p shortcut.program
    end

    def create
        # @shortcut = Shortcut.create(shortcut_params)
        # if @shortcut
        #     if @shortcut.end_time != nil
        #         ShortcutJob.set(wait_until: @shortcut.start_time).perform_later(@shortcut.id)
        #         ShortcutJob.set(wait_until: @shortcut.end_time).perform_later(@shortcut.id)
        #     else
        #         ShortcutJob.set(wait_until: @shortcut.start_time).perform_later(@shortcut.id)
        #     end
        # else
        #     redirect_to '/'
        # end
    end

    def delete
        if request.post? then
            if params[:shortcut_id]
                @shortcut = Shortcut.find(params[:shortcut_id])
                @shortcut.destroy
            end
        end
    end

    private
    def shortcut_params
        params.require(:shortcut).permit(:park_id, :title, :start_time, :end_time, :program, :repeat)
    end
end
