class AdminController < ApplicationController
    before_action :logged_in_user
    helper_method :show
    # adminコントローラーは権限ある人だけアクセス可能

    def index #(データ一覧を表示、ビューからボタン押して切り替え)
        @users = User.page(params[:page]).per(3)
        @parks = Park.page(params[:page]).per(3)
        @benches = Bench.page(params[:page]).per(3)
        @pictures = Picture.page(params[:page]).per(3)
        @events = Event.page(params[:page]).per(3)
        @products = Product.page(params[:page]).per(3)
        @shortcuts = Shortcut.page(params[:page]).per(3)
        @tmp_data = TmpDatum.page(params[:page]).per(3)
        @tmp_data = TmpDatum.page(params[:page]).per(3)
        @tmp_messages = TmpMessage.page(params[:page]).per(3)
        show
    end

    def show
        logger.debug params[:category]
        @result = params[:category]

        respond_to do |format|
            format.html
            format.js
        end
    end

    def add
        @result = params[:category]

        @user = User.new
        @park = Park.new
        @bench = Bench.new
        @picture = Picture.new
        @event = Event.new
        @product = Product.new
        @shortcut = Shortcut.new
        show

        if params[:user]
            if request.post? then
                User.create users_params
                redirect_to '/admin/add_done'
            end
        elsif params[:park]
            if request.post? then
                Park.create parks_params
                redirect_to '/admin/add_done'
            end
        elsif params[:bench]
            if request.post? then
                Bench.create benches_params
                redirect_to '/admin/add_done'
            end
        elsif params[:picture]
            if request.post? then
                Picture.create pictures_params
                redirect_to '/admin/add_done'
            end
        elsif params[:event]
            if request.post? then
                Event.create events_params
                redirect_to '/admin/add_done'
            end
        elsif params[:product]
            if request.post? then
                Product.create products_params
                redirect_to '/admin/add_done'
            end
        elsif params[:shortcut]
            if request.post? then
                Shortcut.create shortcuts_params
                redirect_to '/admin/add_done'
            end
        end


        @tmp_data = TmpDatum.new
        if params[:tmp_datum]
            logger.debug 'aaa'
            if request.post? then
                TmpDatum.create tmp_data_params
                redirect_to '/admin/delete_done'
            end
        end
    end

    def edit
        logger.debug 'パラメータは、' + params.to_s
        # indexページからの遷移時に、paramsからモデルのIDを認識する処理
        if params[:user_id]
            @user = User.find(params[:user_id])
        elsif params[:park_id]
            @park = Park.find(params[:park_id])
        elsif params[:bench_id]
            @bench = Bench.find(params[:bench_id])
        elsif params[:picture_id]
            @picture = Picture.find(params[:picture_id])  
        elsif params[:event_id]
            @event = Event.find(params[:event_id])    
        elsif params[:product_id]
            @product = Product.find(params[:product_id])
        elsif params[:shortcut_id]
            @shortcut = Shortcut.find(params[:shortcut_id])
        end

        # update処理
        if request.patch? then
            if params[:user]
                @user = User.find(params[:user][:id])
                @user.update users_params
            elsif params[:park]
                @park = Park.find(params[:park][:id])
                @park.update parks_params
            elsif params[:bench]
                @bench = Bench.find(params[:bench][:id])
                @bench.update benches_params
            elsif params[:picture]
                @picture = Picture.find(params[:picture][:id])
                @picture.update pictures_params
            elsif params[:event]
                @event = Event.find(params[:event][:id])
                @event.update events_params 
            elsif params[:product]
                @product = Product.find(params[:product][:id])
                @product.update products_params
            elsif params[:shortcut]
                @shortcut = Shortcut.find(params[:shortcut][:id])
                @shortcut.update shortcuts_params
            end
            redirect_to '/admin/index'
        end
    end

    def delete
        logger.debug 'パラメータは、' + params.to_s

        # indexページからの遷移時に、paramsからモデルのIDを認識する処理
        if params[:user_id]
            @user = User.find(params[:user_id])
        elsif params[:park_id]
            @park = Park.find(params[:park_id])
        elsif params[:bench_id]
            @bench = Bench.find(params[:bench_id])
        elsif params[:picture_id]
            @picture = Picture.find(params[:picture_id])
        elsif params[:event_id]
            @event = Event.find(params[:event_id])
        elsif params[:product_id]
            @product = Product.find(params[:product_id])
        elsif params[:shortcut_id]
            @shortcut = Shortcut.find(params[:shortcut_id])
        end

        # delete処理
        if request.post? then
            if params[:user_delete_id]
                @user = User.find(params[:user_delete_id])
                @user.destroy
                redirect_to '/admin/delete_done'
            elsif params[:park_delete_id]
                @park = Park.find(params[:park_delete_id])
                @park.destroy
                redirect_to '/admin/delete_done'
            elsif params[:bench_delete_id]
                @bench = Bench.find(params[:bench_delete_id])
                @bench.destroy
                redirect_to '/admin/delete_done'
            elsif params[:picture_delete_id]
                @picture = Picture.find(params[:picture_delete_id])
                @picture.destroy 
                redirect_to '/admin/delete_done'
            elsif params[:event_delete_id]
                @event = Event.find(params[:event_delete_id])
                @event.destroy
                redirect_to '/admin/delete_done'
            elsif params[:product_delete_id]
                @product = Product.find(params[:product_delete_id])
                @product.destroy
                redirect_to '/admin/delete_done'
            elsif params[:shortcut_delete_id]
                @shortcut = Shortcut.find(params[:shortcut_delete_id])
                @shortcut.destroy
                redirect_to '/admin/delete_done'
            end
        end
    end
        
    # permit()内のパラメータを含んだものだけを許可
    private
    def users_params
        params.require(:user).permit(:display_name, :email, :zip, :prefecture, :address, :street, :tel, :municipality, :division, :image, :profile, :notification, :flag, :admin_memo)
    end

    private
    def parks_params
        params.require(:park).permit(:name, :zip, :prefecture, :address, :street, :hours, :tel, :fee, :map, :website, :size, :profile, :parking_info, :toilet_info, :playground_info, :facility_info, :sports_info, :view_info, :disaster_info, :other_info)
    end
   
    private
    def benches_params
        params.require(:bench).permit(:park_id, :name, :mac_address, :os_name, :introduced_date)
    end

    private
    def pictures_params
        params.require(:picture).permit(:park_id, :name, :picture)
    end

    private
    def events_params
        params.require(:event).permit(:park_id, :name, :contents)
    end

    private
    def products_params
        params.require(:product).permit(:park_id, :name, :contents)
    end

    private
    def shortcuts_params
        params.require(:shortcut).permit(:bench_id, :name, :program)
    end
end
