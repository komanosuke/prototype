require 'json'

class ParkController < ApplicationController
    before_action :logged_in_user
    include Weather

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
                @park.update parks_basicinfo_params
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

        #pictureの保存
        if params[:picture]
            create
        end
    end

    def create
        Picture.create(picture: params[:picture], park_id: params[:park_id], name: params[:name], size: params[:size])
    end

    def products
        @parks = Park.where(user_id: current_user.id)
        @park = @parks.find(params[:park_id]) #現在のユーザーから、パラメータのidで公園を特定
        #新しい配列をつくる処理（ベンチとカメラを導入順に並べる）
        @benches = Bench.where(park_id: @park.id)
        @cameras = Camera.where(park_id: @park.id)
        @products = []
        @benches.each do |bench|
            @products.push(bench)
        end
        @cameras.each do |camera|
            @products.push(camera)
        end

        now = Time.now
        week = ["日", "月", "火", "水", "木", "金", "土"]
        @month = now.month.to_s
        @day = now.day.to_s
        @weekday =  week[now.wday]
    
        weather

    end

    

    private
    def parks_basicinfo_params
        params.require(:park).permit(:name, :zip, :address, :hours, :tel, :fee, :adult, :child)
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