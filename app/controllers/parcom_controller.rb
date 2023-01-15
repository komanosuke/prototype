require 'net/http'
require 'uri'
# require 'nokogiri'
# require 'kconv'
require 'json'
# require 'pp'

require 'open-uri'

class ParcomController < ApplicationController
    before_action :logged_in_user, except: [:terms, :privacy, :help, :beginners, :get_data]
    helper_method :post_data, :get_data, :new, :create

    def index
        @parks = Park.where(user_id: current_user.id)
    end

    def get_data
        # paramsにID:parcomが含まれていれば実行
        if params.has_key?('ID') and params['ID'] == 'parcom'
            # params_json = params
            # params_json.delete('controller')
            # params_json.delete('action')
            p params['DATA']
            params_data = params['DATA'].gsub!("{","").split("}")
            params_json = '{'
            params_data.each do |data|
                params_json += '"' + data.sub(',', '"=>"') + '",'
            end
            
            mac_address = params['MAC_ADDRESS']
            @mac_check = Bench.find_by(mac_address: mac_address)

            if @mac_check.timer.to_s == 'false'
                params_json += '"TIMER"=>"OFF"}'
            else
                params_json += '"TIMER"=>"ON"}'
            end

            logger.debug 'パラメータを読み取りました！'
            if TmpDatum.exists?
                # Timer状態　確認してparams_jsonにくっつける
                TmpDatum.create(data: params_json.to_s)
                @data = TmpDatum.last.data
                logger.debug '送信されたデータ：' + params_json.to_s
                logger.debug '送信されたデータをDBに格納しました。'
            else
                TmpDatum.create(data: params_json.to_s)
                logger.debug 'DBを作成しました。'
            end
        else
            logger.debug 'パラメータは無効です。'
        end
    end



    def controlpanel
        @parks = Park.where(user_id: current_user.id)
        # 選択されたBenchのデータを取得する処理
        @park = Park.find(1)
        @bench = Bench.last

        # 初期化処理
        @bench_image_now = BenchImage.last
        @bench_video_now = BenchVideo.last
        @bench_audio_now = BenchAudio.last
        

        #image、video、audioの保存
        if params[:image] or params[:video] or params[:audio]
            create
        end

        get_data

        # データをViewに表示するための処理① (@dataに最新のデータを入れておく)
        if TmpDatum.exists?
            @data = TmpDatum.last.data
        else
            @data = 'データはありません。'
        end
    
        # データをViewに表示するための処理② (submitによるrespondでjs.erbにのせてViewに表示)
        respond_to do |format|
            format.html
            format.js
        end

        
        now = Time.new
        week = ["日", "月", "火", "水", "木", "金", "土"]
        @month = now.month.to_s
        @day = now.day.to_s
        @weekday =  week[now.wday]
        
        area_codes = {"稚内"=>"011000","旭川"=>"012010","留萌"=>"012020","網走"=>"013010","北見"=>"013020","紋別"=>"013030","根室"=>"014010","釧路"=>"014020","帯広"=>"014030","室蘭"=>"015010","浦河"=>"015020","札幌"=>"016010","岩見沢"=>"016020","倶知安"=>"016030","函館"=>"017010","江差"=>"017020","青森"=>"020010","むつ"=>"020020","八戸"=>"020030","盛岡"=>"030010","宮古"=>"030020","大船渡"=>"030030","仙台"=>"040010","白石"=>"040020","秋田"=>"050010","横手"=>"050020","山形"=>"060010","米沢"=>"060020","酒田"=>"060030","新庄"=>"060040","福島"=>"070010","小名浜"=>"070020","若松"=>"070030","水戸"=>"080010","土浦"=>"080020","宇都宮"=>"090010","大田原"=>"090020","前橋"=>"100010","みなかみ"=>"100020","さいたま"=>"110010","熊谷"=>"110020","秩父"=>"110030","千葉"=>"120010","銚子"=>"120020","館山"=>"120030","東京"=>"130010","大島"=>"130020","八丈島"=>"130030","父島"=>"130040","横浜"=>"140010","小田原"=>"140020","新潟"=>"150010","長岡"=>"150020","高田"=>"150030","相川"=>"150040","富山"=>"160010","伏木"=>"160020","金沢"=>"170010","輪島"=>"170020","福井"=>"180010","敦賀"=>"180020","甲府"=>"190010","河口湖"=>"190020","長野"=>"200010","松本"=>"200020","飯田"=>"200030","岐阜"=>"210010","高山"=>"210020","静岡"=>"220010","網代"=>"220020","三島"=>"220030","浜松"=>"220040","名古屋"=>"230010","豊橋"=>"230020","津"=>"240010","尾鷲"=>"240020","大津"=>"250010","彦根"=>"250020","京都"=>"260010","舞鶴"=>"260020","大阪"=>"270000","神戸"=>"280010","豊岡"=>"280020","奈良"=>"290010","風屋"=>"290020","和歌山"=>"300010","潮岬"=>"300020","鳥取"=>"310010","米子"=>"310020","松江"=>"320010","浜田"=>"320020","西郷"=>"320030","岡山"=>"330010","津山"=>"330020","広島"=>"340010","庄原"=>"340020","下関"=>"350010","山口"=>"350020","柳井"=>"350030","萩"=>"350040","徳島"=>"360010","日和佐"=>"360020","高松"=>"370000","松山"=>"380010","新居浜"=>"380020","宇和島"=>"380030","高知"=>"390010","室戸岬"=>"390020","清水"=>"390030","福岡"=>"400010","八幡"=>"400020","飯塚"=>"400030","久留米"=>"400040","佐賀"=>"410010","伊万里"=>"410020","長崎"=>"420010","佐世保"=>"420020","厳原"=>"420030","福江"=>"420040","熊本"=>"430010","阿蘇乙姫"=>"430020","牛深"=>"430030","人吉"=>"430040","大分"=>"440010","中津"=>"440020","日田"=>"440030","佐伯"=>"440040","宮崎"=>"450010","延岡"=>"450020","都城"=>"450030","高千穂"=>"450040","鹿児島"=>"460010","鹿屋"=>"460020","種子島"=>"460030","名瀬"=>"460040","那覇"=>"471010","名護"=>"471020","久米島"=>"471030","南大東"=>"472000","宮古島"=>"473000","石垣島"=>"474010","与那国島"=>"474020"}
        area_code = ''
        area_codes.keys.each do |city|
            if @park.address.include? city
                area_code = area_codes[city]
            end
        end

        url = "https://weather.tsukumijima.net/api/forecast/city/" + area_code
        uri = URI.parse(url)
        response = Net::HTTP.get(uri)
        @response =JSON.parse(response)

        @telop = @response['forecasts'][0]['image']['title']
        @weather_img = @response['forecasts'][0]['image']['url']


        
    end



    def post_data
        TmpMessage.create(message: params[:cmd])
        @message = TmpMessage.last.message

        logger.debug @message

        socket_message(@message)
    end

    def new
        @bench_image = BenchImage.new
        @bench_video = BenchVideo.new
        @bench_audio = BenchAudio.new
    end

    def create
        if params[:image]
            @bench_image = BenchImage.create(image: params[:image], bench_id: 1)
        elsif params[:video]
            @bench_video = BenchVideo.create(video: params[:video], bench_id: 1)
        elsif params[:audio]
            @bench_audio = BenchAudio.create(audio: params[:audio], bench_id: 1)
        end
    end

    def profile
        @parks = Park.where(user_id: current_user.id)
        @park = @parks.find(params[:park_id])
        @picture = Picture.last
    end

    def review
        @parks = Park.where(user_id: current_user.id)
        @park = @parks.find(params[:park_id])
    end

    def article
        @parks = Park.where(user_id: current_user.id)
    end

    def account
        @parks = Park.where(user_id: current_user.id)
    end

    def park
        @parks = Park.where(user_id: current_user.id)
        @park = @parks.find(params[:park_id])
    end

    def news
        @parks = Park.where(user_id: current_user.id)
    end

    def terms
    end

    def privacy
    end

    def help
    end

    def beginners
    end


    # benchを認識するため（後で実装）
    private
    def bench_images_params
        params.require(:bench_image).permit(:image).merge(bench_id: 1)
    end

    private
    def bench_videos_params
        params.require(:bench_video).permit(:video).merge(bench_id: 1)
    end

    private
    def bench_audios_params
        params.require(:bench_audio).permit(:audio).merge(bench_id: 1)
    end
end








require 'socket'
require 'json'

def socket_message(msg)
    maxlen = 300

    queue = []

    TCPSocket.open("localhost", 4000) do |socket|

        t1 = Thread.start do #送信スレッド node.jsのものと同じような動き のはず
            message = 'FROM_RAILS : ' + msg
            socket.write(message)
            
            
            # socket.shutdown() # クライアント側から切断
        end

        t2 = Thread.start do #受信スレッド
            begin
                loop do
                    buf = socket.readpartial(maxlen) # サーバから受信 String型として取得

                    pp 'サーバからの返答：' + buf.force_encoding("UTF-8") # 動作確認のためクライアント側標準出力
                end
            rescue EOFError => e
                $stdout.write("eof\n") # 切断
            end
        end

        # t1.join # スレッドが終了するまで待つ
        # t2.join # スレッドが終了するまで待つ
        sleep(0.1)
        t1.kill
        t2.kill
    end
end