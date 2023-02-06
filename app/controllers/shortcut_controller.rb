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
        @sc = Shortcut.find(1)
        p @sc.start_time.to_s.match(/ /).post_match.match(/ /).pre_match.gsub!(":",",").gsub!("0","").split(",")
        p "aaaaaaaa"
    end

    def create
        p params[:shortcut][:repeat]
        p params[:shortcut][:mac_address1]
        p params[:shortcut][:triggers]
        p params[:shortcut][:mac_address2]
        p params[:shortcut][:actions]
        
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
        params.require(:shortcut).permit(:park_id, :title, :nickname, :start_time, :end_time, :repeat, :mac_address1, :triggers, :mac_address2, :actions)
    end
end
