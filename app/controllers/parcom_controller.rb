require 'net/http'
require 'uri'
require 'nokogiri'
require 'kconv'
require 'json'
require 'socket'
require 'pp'
require 'open-uri'
require 'rmagick'
require 'httpclient'

class ParcomController < ApplicationController
    before_action :logged_in_user, except: [:terms, :privacy, :help, :beginners, :get_data]
    helper_method :post_data, :get_data, :new, :create
    include Weather

    def index
        @parks = Park.where(user_id: current_user.id)
        ##clientという変数にHTTPClientのインスタンス変数を格納
        client    = HTTPClient.new
        ##httpclient でSSL証明書のチェックを無視する
        client.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE
        ##urlに格納したURLにhttpclientが用意してあるgetメソッドを使って外部からHTTPのGETメソッドを走らせる
        article_url      = "http://app.parcom.jp/test/wp-json/wp/v2/article?_embed"
        article_url_cat  = "http://app.parcom.jp/test/wp-json/wp/v2/cat_article"
        news_url         = "http://app.parcom.jp/test/wp-json/wp/v2/news?_embed"
        news_url_cat     = "http://app.parcom.jp/test/wp-json/wp/v2/cat_news"
        ##その結果を〇〇_responseという変数に格納
        article_response      = client.get(article_url)
        article_response_cat  = client.get(article_url_cat)
        news_response     = client.get(news_url)
        news_response_cat = client.get(news_url_cat)
        ##JSON形式になっているのでJSON.parseメソッドを使って連想配列型(Hash)に変換
        article_res_json     = JSON.parse(article_response.body)
        article_res_json_cat = JSON.parse(article_response_cat.body)
        news_res_json        = JSON.parse(news_response.body)
        news_res_json_cat    = JSON.parse(news_response_cat.body)

        @article_datas = []
        @article_datas_cat = []
        make_article(article_res_json, article_res_json_cat)
        @article_datas = @article_datas.first(4)

        @news_datas = []
        @news_datas_cat = []
        make_news(news_res_json, news_res_json_cat)
        @news_datas = @news_datas.first(3)
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
            params_json += '"MAC_ADDRESS"=>"' + mac_address + '"}'
            @mac_check = Bench.find_by(mac_address: mac_address)

            logger.debug 'パラメータを読み取りました！'
            if TmpDatum.exists?
                # Timer状態　確認してparams_jsonにくっつける
                TmpDatum.create(data: params_json.to_s, mac_address: mac_address)
                logger.debug '送信されたデータ：' + params_json.to_s
                logger.debug '送信されたデータをDBに格納しました。'
                # 一時保存する件数　ベンチの台数に応じて数字を変える
                if TmpDatum.count > 1000
                    TmpDatum.first(500).destroy
                end
                # ビューからMACアドレスを取得して、controlpanel.jsで@dataを更新
                @data = TmpDatum.where(mac_address: params['commit']).last.data
            else
                TmpDatum.create(data: params_json.to_s)
                logger.debug 'DBを作成しました。'
            end
            
        else
            logger.debug 'パラメータは無効です。'
        end
        
    end


    def controlpanel
        
        # ログイン中のユーザーに所属する公園を認識し、その中から所属公園を特定する。所属公園の中からベンチを特定する。
        @parks = Park.where(user_id: current_user.id)
        @park = @parks.find_by(id: params[:park_id])
        @benches = Bench.where(park_id: @park.id)
        @bench = @benches.find_by(id: params[:bench_id])

        @bench_image_now = BenchImage.where(user_id: current_user.id).last
        @bench_video_now = BenchVideo.where(user_id: current_user.id).last
        @bench_audio_now = BenchAudio.where(user_id: current_user.id).last
        
        #image、video、audioの保存
        if params[:image] or params[:video] or params[:audio]
            create
        end

        get_data

        # データをViewに表示するための処理① (@dataに最新のデータを入れておく)
        if TmpDatum.exists?
            @data = TmpDatum.where(mac_address: @bench.mac_address).last.data
        else
            @data = 'データはありません。'
        end

        # データをViewに表示するための処理② (submitによるrespondでjs.erbにのせてViewに表示)
        respond_to do |format|
            format.html
            format.js
        end

        
        now = Time.now
        week = ["日", "月", "火", "水", "木", "金", "土"]
        @month = now.month.to_s
        @day = now.day.to_s
        @weekday =  week[now.wday]
    
        weather
        
    end



    def post_data
        # ３つともMACアドレスを指定してその最後をとる
        if params[:cmd].include? 'PDF,ON'
            sleep(2)
            cmd = params[:cmd]
            file = ':http://54.64.49.214:60001' + BenchImage.where(user_id: current_user.id).last.pdf_url
            socket_message(cmd.gsub(/:/, file))
        elsif params[:cmd].include? 'MP4,ON'
            cmd = params[:cmd]
            file = ':http://54.64.49.214:60001' + BenchVideo.where(user_id: current_user.id).last.video.to_s
            socket_message(cmd.gsub(/:/, file))
        elsif params[:cmd].include? 'MP3,ON'
            cmd = params[:cmd]
            file = ':http://54.64.49.214:60001' + BenchAudio.where(user_id: current_user.id).last.audio.to_s
            socket_message(cmd.gsub(/:/, file))
        else
            socket_message(params[:cmd])
        end
    end

    def new
        @bench_image = BenchImage.new
        @bench_video = BenchVideo.new
        @bench_audio = BenchAudio.new
    end

    def create
        if params[:image]
            @bench_image = BenchImage.create(image: params[:image], user_id: current_user.id, name: params[:name], bench_id: params[:bench_id])
            img_url = BenchImage.last.image.to_s
            url_split = img_url.split(/\//)
            img_path = '/' + url_split[1] + '/' + url_split[2] + '/' + url_split[3] + '/' + url_split[4]
            sleep(1)
            # 指定してリネームする
            file = Magick::Image.read("http://54.64.49.214:60001" + img_url)[0]
            # 保存先をフルパスで指定
            url = "/home/ec2-user/parcom_os/public" + img_path + "/out.pdf"
            # url = "awsのパス/public" + img_path + "/out.pdf"
            file.write(url)
            # OK　名前をout.pdfからタイムスタンプにして保存
            new_url = img_path + "/out.pdf"

            # アップロードされたファイルを削除して完全にアップデートする（imageはなくなるがurlは残る。全消ししたい場合はフォルダを丸ごと消す）
            @bench_image.update(image: nil)
            @bench_image.update(pdf_url: new_url)
        elsif params[:video]
            @bench_video = BenchVideo.create(video: params[:video], user_id: current_user.id, name: params[:name], bench_id: params[:bench_id])
        elsif params[:audio]
            @bench_audio = BenchAudio.create(audio: params[:audio], user_id: current_user.id, name: params[:name], bench_id: params[:bench_id])
        end
    end

    def profile
        @parks = Park.where(user_id: current_user.id)
        @park = @parks.find(params[:park_id])
        pictures = Picture.where(park_id: @park.id)
        @pictures = pictures.last(5)
    end

    def review
        @parks = Park.where(user_id: current_user.id)
        @park = @parks.find(params[:park_id])
    end

    def account
        @parks = Park.where(user_id: current_user.id)
    end

    def park
        @parks = Park.where(user_id: current_user.id)
        @park = @parks.find(params[:park_id])
    end

    def article
        @parks = Park.where(user_id: current_user.id)
        client    = HTTPClient.new
        ##httpclient でSSL証明書のチェックを無視する
        client.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE
        ##urlに格納したURLにhttpclientが用意してあるgetメソッドを使って外部からHTTPのGETメソッドを走らせる
        article_url      = "http://app.parcom.jp/test/wp-json/wp/v2/article?_embed"
        article_url_cat  = "http://app.parcom.jp/test/wp-json/wp/v2/cat_article"
        ##その結果を〇〇_responseという変数に格納
        article_response      = client.get(article_url)
        article_response_cat  = client.get(article_url_cat)
        ##JSON形式になっているのでJSON.parseメソッドを使って連想配列型(Hash)に変換
        article_res_json     = JSON.parse(article_response.body)
        article_res_json_cat = JSON.parse(article_response_cat.body)

        @article_datas = []
        @article_datas_cat = []
        make_article(article_res_json, article_res_json_cat)
    end

    def make_article(article_res_json, article_res_json_cat)
        #PARCOMに関するお知らせ
        # @article_datas = []
        for i in 0..article_res_json.length-1
            h = {}
            h["link"]  = (article_res_json[i]["link"])
            if (article_res_json[i]["thumbnail"] != [])
                h["thumbnail"] = (article_res_json[i]["thumbnail"]["url"])
            end
            h["date"]  = (article_res_json[i]["date"]).to_date
            week = (article_res_json[i]["date"]).to_date.wday
            days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
            h["wday"]  = days[week]
            h["title"] = (article_res_json[i]["title"]["rendered"])
            h["cat"]   = (article_res_json[i]["_embedded"]["wp:term"][0][0]["name"])
            @article_datas.push(h)
        end
        @article_datas = Kaminari.paginate_array(@article_datas).page(params[:page]).per(8)
        #PARCOMに関するお知らせサイドバー
        # @article_datas_cat = []
        for i in 0..article_res_json_cat.length-1
            cat = {}
            cat["link"] = (article_res_json_cat[i]["link"])
            cat["name"] = (article_res_json_cat[i]["name"])
            @article_datas_cat.push(cat)
        end

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
        client    = HTTPClient.new
        ##httpclient でSSL証明書のチェックを無視する
        client.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE
        ##urlに格納したURLにhttpclientが用意してあるgetメソッドを使って外部からHTTPのGETメソッドを走らせる
        news_url         = "http://app.parcom.jp/test/wp-json/wp/v2/news?_embed"
        news_url_cat     = "http://app.parcom.jp/test/wp-json/wp/v2/cat_news"
        ##その結果を〇〇_responseという変数に格納
        news_response     = client.get(news_url)
        news_response_cat = client.get(news_url_cat)
        ##JSON形式になっているのでJSON.parseメソッドを使って連想配列型(Hash)に変換
        news_res_json        = JSON.parse(news_response.body)
        news_res_json_cat    = JSON.parse(news_response_cat.body)

        @news_datas = []
        @news_datas_cat = []
        make_news(news_res_json, news_res_json_cat)

    end

    def make_news(news_res_json, news_res_json_cat)
        #サービスに関するお知らせ
        # @news_datas = []
        for i in 0..news_res_json.length-1
            h = {}
            h["link"]  = (news_res_json[i]["link"])
            h["date"]  = (news_res_json[i]["date"]).to_date
            week = (news_res_json[i]["date"]).to_date.wday
            days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
            h["wday"]  = days[week]
            h["title"] = (news_res_json[i]["title"]["rendered"])
            h["cat"]   = (news_res_json[i]["_embedded"]["wp:term"][0][0]["name"])
            @news_datas.push(h)
        end
        @news_datas = Kaminari.paginate_array(@news_datas).page(params[:page]).per(10)
        #サービスに関するお知らせサイドバー
        # @news_datas_cat = []
        for i in 0..news_res_json_cat.length-1
            cat = {}
            cat["link"] = (news_res_json_cat[i]["link"])
            cat["name"] = (news_res_json_cat[i]["name"])
            @news_datas_cat.push(cat)
        end

    end

    def terms
    end

    def privacy
    end

    def help
    end

    def beginners
    end


end









def socket_message(msg)
    maxlen = 400

    queue = []

    begin
        TCPSocket.open("54.64.49.214", 8000) do |socket|

            t1 = Thread.start do #送信スレッド node.jsのものと同じような動き のはず
                message = 'FROM_RAILS : ' + msg
                socket.write(message)
                
                # socket.shutdown() # クライアント側から切断
            end

            t2 = Thread.start do #受信スレッド
                begin
                    loop do
                        buf = socket.readpartial(maxlen) # サーバから受信 String型として取得
                        queue.push(buf)

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

        return queue[0]
    rescue
        @sock = 'error'
    end
end