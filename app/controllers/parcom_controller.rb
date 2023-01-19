require 'net/http'
require 'uri'
require 'nokogiri'
require 'kconv'
require 'json'
require 'pp'

require 'open-uri'

require 'RMagick'

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
            p "送信されたデータ: " + params['DATA']
            params_data = params['DATA'].sub!(/,MAC.*/m, "").gsub!("{","").split("}")
            params_json = '{'
            params_data.each do |data|
                params_json += '"' + data.sub(',', '"=>"') + '",'
            end
            mac_address = params['MAC_ADDRESS']
            params_json += '"MAC_ADDRESS"=>"' + mac_address + '",'
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
                # 一時保存する件数　ベンチの台数に応じて数字を変える
                if TmpDatum.count > 1000
                    TmpDatum.first.destroy
                end
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
        
        area = {"能登"=>["珠洲","穴水"]}
        area_codes = {"稚内"=>"011000","旭川"=>"012010","留萌"=>"012020","網走"=>"013010","北見"=>"013020","紋別"=>"013030","根室"=>"014010","釧路"=>"014020","帯広"=>"014030","室蘭"=>"015010","浦河"=>"015020","札幌"=>"016010","岩見沢"=>"016020","倶知安"=>"016030","函館"=>"017010","江差"=>"017020","青森"=>"020010","むつ"=>"020020","八戸"=>"020030","盛岡"=>"030010","宮古"=>"030020","大船渡"=>"030030","仙台"=>"040010","白石"=>"040020","秋田"=>"050010","横手"=>"050020","山形"=>"060010","米沢"=>"060020","酒田"=>"060030","新庄"=>"060040","福島"=>"070010","小名浜"=>"070020","若松"=>"070030","水戸"=>"080010","土浦"=>"080020","宇都宮"=>"090010","大田原"=>"090020","前橋"=>"100010","みなかみ"=>"100020","さいたま"=>"110010","熊谷"=>"110020","秩父"=>"110030","千葉"=>"120010","銚子"=>"120020","館山"=>"120030","東京"=>"130010","大島"=>"130020","八丈島"=>"130030","父島"=>"130040","横浜"=>"140010","小田原"=>"140020","新潟"=>"150010","長岡"=>"150020","高田"=>"150030","相川"=>"150040","富山"=>"160010","伏木"=>"160020","金沢"=>"170010","輪島"=>"170020","福井"=>"180010","敦賀"=>"180020","甲府"=>"190010","河口湖"=>"190020","長野"=>"200010","松本"=>"200020","飯田"=>"200030","岐阜"=>"210010","高山"=>"210020","静岡"=>"220010","網代"=>"220020","三島"=>"220030","浜松"=>"220040","名古屋"=>"230010","豊橋"=>"230020","津"=>"240010","尾鷲"=>"240020","大津"=>"250010","彦根"=>"250020","京都"=>"260010","舞鶴"=>"260020","大阪"=>"270000","神戸"=>"280010","豊岡"=>"280020","奈良"=>"290010","風屋"=>"290020","和歌山"=>"300010","潮岬"=>"300020","鳥取"=>"310010","米子"=>"310020","松江"=>"320010","浜田"=>"320020","西郷"=>"320030","岡山"=>"330010","津山"=>"330020","広島"=>"340010","庄原"=>"340020","下関"=>"350010","山口"=>"350020","柳井"=>"350030","萩"=>"350040","徳島"=>"360010","日和佐"=>"360020","高松"=>"370000","松山"=>"380010","新居浜"=>"380020","宇和島"=>"380030","高知"=>"390010","室戸岬"=>"390020","清水"=>"390030","福岡"=>"400010","八幡"=>"400020","飯塚"=>"400030","久留米"=>"400040","佐賀"=>"410010","伊万里"=>"410020","長崎"=>"420010","佐世保"=>"420020","厳原"=>"420030","福江"=>"420040","熊本"=>"430010","阿蘇乙姫"=>"430020","牛深"=>"430030","人吉"=>"430040","大分"=>"440010","中津"=>"440020","日田"=>"440030","佐伯"=>"440040","宮崎"=>"450010","延岡"=>"450020","都城"=>"450030","高千穂"=>"450040","鹿児島"=>"460010","鹿屋"=>"460020","種子島"=>"460030","名瀬"=>"460040","那覇"=>"471010","名護"=>"471020","久米島"=>"471030","南大東"=>"472000","宮古島"=>"473000","石垣島"=>"474010","与那国島"=>"474020"}
        pref_codes = {"宗谷"=>"011000","上川"=>"012000","留萌"=>"012000","石狩"=>"016000","空知"=>"016000","後志"=>"016000","網走"=>"013000","北見"=>"013000","紋別"=>"013000","釧路"=>"014100","根室"=>"014100","十勝"=>"014100","胆振"=>"015000","日高"=>"015000","渡島"=>"017000","檜山"=>"017000","青森県"=>"020000","岩手県"=>"030000","宮城県"=>"040000","秋田県"=>"050000","山形県"=>"060000","福島県"=>"070000","茨城県"=>"080000","栃木県"=>"090000","群馬県"=>"100000","埼玉県"=>"110000","千葉県"=>"120000","東京都"=>"130000","神奈川県"=>"140000","山梨県"=>"190000","長野県"=>"200000","岐阜県"=>"210000","静岡県"=>"220000","愛知県"=>"230000","三重県"=>"240000","新潟県"=>"150000","富山県"=>"160000","石川県"=>"170000","福井県"=>"180000","滋賀県"=>"250000","京都府"=>"260000","大阪府"=>"270000","兵庫県"=>"280000","奈良県"=>"290000","和歌山県"=>"300000","鳥取県"=>"310000","島根県"=>"320000","岡山県"=>"330000","広島県"=>"340000","徳島県"=>"360000","香川県"=>"370000","愛媛県"=>"380000","高知県"=>"390000","山口県"=>"350000","福岡県"=>"400000","佐賀県"=>"410000","長崎県"=>"420000","熊本県"=>"430000","大分県"=>"440000","宮崎県"=>"450000","鹿児島県"=>"460100","沖縄本島地方"=>"471000"}
        # area_codes = {"稚内"=>"011000","旭川"=>"012010","留萌"=>"012020","網走"=>"013010","北見"=>"013020","紋別"=>"013030","根室"=>"014010","釧路"=>"014020","帯広"=>"014030","室蘭"=>"015010","浦河"=>"015020","札幌"=>"016010","岩見沢"=>"016020","倶知安"=>"016030","函館"=>"017010","江差"=>"017020","青森"=>"020010","むつ"=>"020020","八戸"=>"020030","盛岡"=>"030010","宮古"=>"030020","大船渡"=>"030030","仙台"=>"040010","白石"=>"040020","秋田"=>"050010","横手"=>"050020","山形"=>"060010","米沢"=>"060020","酒田"=>"060030","新庄"=>"060040","福島"=>"070010","小名浜"=>"070020","若松"=>"070030","水戸"=>"080010","土浦"=>"080020","宇都宮"=>"090010","大田原"=>"090020","前橋"=>"100010","みなかみ"=>"100020","さいたま"=>"110010","熊谷"=>"110020","秩父"=>"110030","千葉"=>"120010","銚子"=>"120020","館山"=>"120030","東京"=>"130010","大島"=>"130020","八丈島"=>"130030","父島"=>"130040","横浜"=>"140010","小田原"=>"140020","新潟"=>"150010","長岡"=>"150020","高田"=>"150030","相川"=>"150040","富山"=>"160010","伏木"=>"160020","金沢"=>"170010","輪島"=>"170020","福井"=>"180010","敦賀"=>"180020","甲府"=>"190010","河口湖"=>"190020","長野"=>"200010","松本"=>"200020","飯田"=>"200030","岐阜"=>"210010","高山"=>"210020","静岡"=>"220010","網代"=>"220020","三島"=>"220030","浜松"=>"220040","名古屋"=>"230010","豊橋"=>"230020","津"=>"240010","尾鷲"=>"240020","大津"=>"250010","彦根"=>"250020","京都"=>"260010","舞鶴"=>"260020","大阪"=>"270000","神戸"=>"280010","豊岡"=>"280020","奈良"=>"290010","風屋"=>"290020","和歌山"=>"300010","潮岬"=>"300020","鳥取"=>"310010","米子"=>"310020","松江"=>"320010","浜田"=>"320020","西郷"=>"320030","岡山"=>"330010","津山"=>"330020","広島"=>"340010","庄原"=>"340020","下関"=>"350010","山口"=>"350020","柳井"=>"350030","萩"=>"350040","徳島"=>"360010","日和佐"=>"360020","高松"=>"370000","松山"=>"380010","新居浜"=>"380020","宇和島"=>"380030","高知"=>"390010","室戸岬"=>"390020","清水"=>"390030","福岡"=>"400010","八幡"=>"400020","飯塚"=>"400030","久留米"=>"400040","佐賀"=>"410010","伊万里"=>"410020","長崎"=>"420010","佐世保"=>"420020","厳原"=>"420030","福江"=>"420040","熊本"=>"430010","阿蘇乙姫"=>"430020","牛深"=>"430030","人吉"=>"430040","大分"=>"440010","中津"=>"440020","日田"=>"440030","佐伯"=>"440040","宮崎"=>"450010","延岡"=>"450020","都城"=>"450030","高千穂"=>"450040","鹿児島"=>"460010","鹿屋"=>"460020","種子島"=>"460030","名瀬"=>"460040","那覇"=>"471010","名護"=>"471020","久米島"=>"471030","南大東"=>"472000","宮古島"=>"473000","石垣島"=>"474010","与那国島"=>"474020"}
        area_code = ''
        area_codes.keys.each do |area|
            if @park.city.include? area
                area_code = area_codes[area]
            end
        end

        # 県で分類、町で分類、その親の地域コードを特定
        if area_code != ''
            # url = "https://www.jma.go.jp/bosai/forecast/data/forecast/" + area_code + ".json"
            url = "https://weather.tsukumijima.net/api/forecast/city/" + area_code
            uri = URI.parse(url)
            response = Net::HTTP.get(uri)
            @response = JSON.parse(response)

            @telop = @response['forecasts'][0]['image']['title']
            @weather_img = @response['forecasts'][0]['image']['url']
            @response = @response
        end

        url = "https://www.jma.go.jp/bosai/common/const/area.json"
        uri = URI.parse(url)
        response = Net::HTTP.get(uri)
        @towns = JSON.parse(response)['class15s']
        # centers
        # offices
        # class10s
        # class15s
        # class20s
        @response = []
        @towns.each do |town|
            @response.push(town[1]['name'])
            # if @park.city.include? town
            #     # area_code = area_codes[town]
            # end
        end

        @response = @response.push(area_codes)




        # {"publishingOffice"=>"金沢地方気象台", "reportDatetime"=>"2023-01-17T05:00:00+09:00", "timeSeries"=>[{"timeDefines"=>["2023-01-17T05:00:00+09:00", "2023-01-18T00:00:00+09:00"], "areas"=>[{"area"=>{"name"=>"加賀", "code"=>"170010"}, "weatherCodes"=>["211", "207"], "weathers"=>["くもり　夕方　から　晴れ", "くもり　朝晩　雨か雪"], "winds"=>["東の風　海上　では　後　南西の風　やや強く", "南西の風　後　東の風　海上　では　南西の風　やや強く"], "waves"=>["２メートル　後　１メートル", "２．５メートル　後　２メートル"]}, {"area"=>{"name"=>"能登", "code"=>"170020"}, "weatherCodes"=>["211", "207"], "weathers"=>["くもり　夕方　から　晴れ", "くもり　時々　雨か雪"], "winds"=>["北西の風　後　南西の風　海上　では　後　南西の風　やや強く", "西の風　後　北の風　海上　では　はじめ　北西の風　強く"], "waves"=>["２メートル　後　１．５メートル", "３メートル　後　２メートル"]}]}, {"timeDefines"=>["2023-01-17T06:00:00+09:00", "2023-01-17T12:00:00+09:00", "2023-01-17T18:00:00+09:00", "2023-01-18T00:00:00+09:00", "2023-01-18T06:00:00+09:00", "2023-01-18T12:00:00+09:00", "2023-01-18T18:00:00+09:00"], "areas"=>[{"area"=>{"name"=>"加賀", "code"=>"170010"}, "pops"=>["10", "0", "0", "50", "50", "30", "50"]}, {"area"=>{"name"=>"能登", "code"=>"170020"}, "pops"=>["10", "0", "10", "70", "30", "50", "30"]}]}, {"timeDefines"=>["2023-01-17T09:00:00+09:00", "2023-01-17T00:00:00+09:00", "2023-01-18T00:00:00+09:00", "2023-01-18T09:00:00+09:00"], "areas"=>[{"area"=>{"name"=>"金沢", "code"=>"56227"}, "temps"=>["7", "7", "2", "8"]}, {"area"=>{"name"=>"輪島", "code"=>"56052"}, "temps"=>["6", "6", "2", "8"]}]}]}

        # uri = URI.parse("https://www.jma.go.jp/bosai/forecast/#area_type=offices&area_code=" + area_code)
        # request = Net::HTTP::Get.new(uri)

        # req_options = {
        #     use_ssl: uri.scheme == "https",
        # }

        # response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        #     http.request(request)
        # end
        # @doc = Nokogiri::HTML.parse(response.body.toutf8, nil, 'utf-8')
        # @response = @doc.css('script')[10] #画像取得をどうするか

        # heroes_json = URI.open('https://arao99.github.io/zenn_scraping/heroes.json').read
        # heroes_array = JSON.parse(heroes_json)
        # p heroes_array

        
    end



    def post_data
        # ３つともMACアドレスを指定してその最後をとる
        if params[:cmd].include? 'PDF,ON'
            if params[:cmd].include? "preview_dummy"
                socket_message(params[:cmd])
            else
                sleep(1)
                cmd = params[:cmd]
                file = ':' + BenchImage.last.image.to_s
                socket_message(cmd.gsub(/:/, file))
            end
        elsif params[:cmd].include? 'MP4,ON'
            cmd = params[:cmd]
            file = ':' + BenchVideo.last.video.to_s
            socket_message(cmd.gsub(/:/, file))
        elsif params[:cmd].include? 'MP3,ON'
            cmd = params[:cmd]
            file = ':' + BenchAudio.last.audio.to_s
            socket_message(cmd.gsub(/:/, file))
        else
            # TmpMessage.create(message: params[:cmd])
            # #一応MACアドレスを確認
            # @message = TmpMessage.last.message
            socket_message(params[:cmd])
        end

        # if TmpMessage.count > 1000
        #     TmpMessage.first.destroy
        # end

        # logger.debug @message
    end

    def new
        @bench_image = BenchImage.new
        @bench_video = BenchVideo.new
        @bench_audio = BenchAudio.new
    end

    def create
        if params[:image]
            @bench_image = BenchImage.create(image: params[:image], user_id: current_user.id)
            img_url = BenchImage.last.image.to_s
            url_split = img_url.split(/\//)
            img_path = '/' + url_split[1] + '/' + url_split[2] + '/' + url_split[3] + '/' + url_split[4]
            
            # 指定してリネームする
            file = Magick::Image.read("http://localhost:3000" + img_url)[0]
            # 保存先をフルパスで指定
            url = "/Users/komaitoshihiko/Desktop/prototype/public" + img_path + "/out.pdf"
            file.write(url)
            # OK　名前をout.pdfからタイムスタンプにして保存
            new_url = img_path + "/out.pdf"

            # アップロードされたファイルを削除して完全にアップデートする（発想を変えて、imageはなくなるがurlは残る。全消ししたい場合はフォルダを丸ごと消す）
            # @bench_image.update(image: nil)
            @bench_image.update(name: new_url)
        elsif params[:video]
            @bench_video = BenchVideo.create(video: params[:video], user_id: current_user.id)
        elsif params[:audio]
            @bench_audio = BenchAudio.create(audio: params[:audio], user_id: current_user.id, name: params[:name])
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