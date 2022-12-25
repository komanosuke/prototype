class ParcomController < ApplicationController
    before_action :logged_in_user, except: [:controlpanel]
    helper_method :post_data, :controlpanel

    def controlpanel

        if params.has_key?('ID') and params['ID'] == 'parcom'
            params_json = params
            params_json.delete('controller')
            params_json.delete('action')
            mac_address = params['MAC_ADDRESS']
            @mac_check = Bench.find_by(mac_address: mac_address)

            if @mac_check.timer.to_s == 'false'
                params_json['TIMER'] = 'OFF'
            else
                params_json['TIMER'] = 'ON'
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
    end

    def post_data

        TmpMessage.create(message: params[:cmd])
        @message = TmpMessage.last.message

        logger.debug @message

        socket_message(@message)
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