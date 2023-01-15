class ParkController < ApplicationController
    before_action :logged_in_user

    def parkinfo_edit
        @parks = Park.where(user_id: current_user.id)
        @park = @parks.find(params[:park_id])
        @address = @park.address

        @hours = @park.hours.to_json
        @fee = @park.fee.to_json
        @parking_info = @park.parking_info.to_json
        @toilet_info = @park.toilet_info.to_json
        @playground_info = @park.playground_info.to_json

        @pictures = Picture.where(park_id: @park.id)

        if request.patch? then
            if params[:park][:name]
                # hours = parks_basicinfo_params[:hours].gsub(/\\/){''} Ruby側でもゴミを消す処理が必要
                @park.update parks_basicinfo_params
                # @park.update(hours: hours)
            elsif params[:park][:parking_info]
                @park.update parks_facility_params
            elsif params[:park][:tel]
                @park.update parks_contact_params
            elsif params[:park][:pic_list]
                pic_list = params[:park][:pic_list].split(',')
                @pic = Picture.where(park_id: @park.id)
                @pic.each_with_index do |pic, i|
                    if pic_list.include?(i.to_s)
                        pic.destroy
                    end
                end
            end
        end

        # 初期化処理
        @picture_now = Picture.last
        #pictureの保存
        if params[:picture]
            create
        end

    end

    def new
        @picture_new = Picture.new
    end

    def create
        @picture_new = Picture.create(picture: params[:picture], park_id: params[:park_id], name: params[:name])
    end

    def products
        @parks = Park.where(user_id: current_user.id)
        @park = @parks.find(params[:park_id])
        @bench = Bench.find_by(park_id: @park.id)
        if !(@bench)
            redirect_to '/'
        end
    end

    

    private
    def parks_basicinfo_params
        params.require(:park).permit(:name, :zip, :address, :hours, :tel, :fee, :adult, :child)
        # params[:park][:hours] = params[:park][:hours].gsub(/\\/){''}
        # logger.debug params[:park][:hours]
        # params.gsub(/\\/) { '' }
    end

    private
    def parks_facility_params
        params.require(:park).permit(:parking_info, :toilet_info, :playground_info)
    end

    private
    def parks_contact_params
        params.require(:park).permit(:tel, :website)
    end
end