class AdminController < ApplicationController
    before_action :logged_in_user
    helper_method :show
    # adminコントローラーは権限ある人だけアクセス可能

    def index #(データ一覧を表示、ビューからボタン押して切り替え)
        @users = User.all
        @parks = Park.all
        @benches = Bench.all
        @news = News.all
        @media = Medium.all
        @pictures = Picture.all
        @events = Event.all
        @products = Product.all
        @shortcuts = Shortcut.all
        @tmp_data = TmpDatum.all
        @tmp_messages = TmpMessage.all
        show
    end

    def show
        logger.debug params[:category]
        @result = params[:category]

        # if params[:category] == 'ユーザー'
        #     @users = User.all
        # elsif params[:category] == '公園'
        #     @parks = Park.all
        # elsif params[:category] == 'ベンチ'
        #     @benches = Bench.all
        # elsif params[:category] == 'お知らせ'
        #     @news = News.all
        # elsif params[:category] == 'メディア情報'
        #     @media = Medium.all
        # elsif params[:category] == '写真'
        #     @pictures = Picture.all
        # elsif params[:category] == 'イベント'
        #     @events = Event.all
        # elsif params[:category] == 'プロダクト'
        #     @products = Product.all
        # elsif params[:category] == 'ショートカット'
        #     @shortcuts = Shortcut.all
        # elsif params[:category] == 'ベンチからのデータ'
        #     @tmp_data = TmpDatum.all
        # elsif params[:category] == 'ベンチへのコマンド'
        #     @tmp_messages = TmpMessage.all
        # end

        respond_to do |format|
            format.html
            format.js
        end
    end

    def add
        @tmp_data = TmpDatum.new
        if params[:tmp_datum]
            logger.debug 'aaa'
            if request.post? then
                TmpDatum.create tmp_data_params
                redirect_to '/admin/index'
            end
        end
    end

    # def edit　編集
        # @parksとかで取ってきて、一覧表示、それぞれにformつける update
    # end

    # def delete
    # end
        
    private
    def users_params
        params.require(:user).permit()
    end

    private
    def parks_params
        params.require(:park).permit()
    end

    private
    def benches_params
        params.require(:bench).permit()
    end

    private
    def news_params
        params.require(:news).permit()
    end

    private
    def media_params
        params.require(:medium).permit()
    end

    private
    def pictures_params
        params.require(:picture).permit()
    end

    private
    def events_params
        params.require(:event).permit()
    end

    private
    def products_params
        params.require(:product).permit()
    end

    private
    def shortcuts_params
        params.require(:shortcut).permit()
    end

    private
    def tmp_data_params
        params.require(:tmp_datum).permit(:data, :mac_address)
    end
end
