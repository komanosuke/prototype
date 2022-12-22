require 'socket'

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



class PanelsController < ApplicationController

    helper_method :say, :show

    def index
        # SocketServerJob.perform_now
        
    end

    def show
        # server.rbからshowにつなげるとき、server.rbのhost,portを変更・確認



        # MACアドレスを認識する処理 JSONからMACアドレス剥ぎ取る
        # if Bench.find(macaddress) #なかったらDBに保存    !!!!MACアドレスはTmpDataに一緒に保管、MACアドレスをもとにdataをupdate
        # viewでMACアドレス指定しているので、他のMACアドレスのデータは保存されてもViewでは参照しない（showメソッドは常にデータが来るため忙しい。ここのタイムが肝。）送るのはマイペースだが、受信は常にある。

        # else #あったら、更新update
            
        # end

        # GETパラメータを一時保存　updateでもいいが、前後を見れた方がデバッグしやすいのでこのまま
        logger.debug params
        if params.has_key?('ID') and params['ID'] == 'parcom'
            logger.debug 'パラメータを読み取りました！'
            if TmpDatum.exists?
                # Timer状態　確認してparamsにくっつける
                TmpDatum.create(data: params.to_s)
                @data = TmpDatum.last.data
                logger.debug '送信されたデータ：' + params.to_s
                logger.debug '送信されたデータをDBに格納しました。'
            else
                TmpDatum.create(data: params.to_s)
                logger.debug 'DBを作成しました。'
            end
        else
            logger.debug 'パラメータは無効です。'
        end

        # データをViewに表示するための処理① (@dataに最新のデータを入れておく)
        if TmpDatum.exists?
            @data = TmpDatum.last.data
            return @data
        else
            @data = 'データはありません。'
        end
    
        # データをViewに表示するための処理② (submitによるrespondでjs.erbにのせてViewに表示)
        respond_to do |format|
            format.html
            format.js
        end
    end





    def say
        # ラズパイへのコマンドを一時保存して、socket_message関数で送信(Javascriptで直接ソケット通信できないため) Viewからはajaxで送信実行
        # viewでMACアドレスを指定しているので、それ宛にデータを送れる。TmpMessageにはMACアドレスはいらない。　　　ここの処理は終了。->jsへ。

        TmpMessage.create(message: params[:cmd])
        @message = TmpMessage.last.message

        logger.debug @message #ajax届いてはいる

        # @message = @message + MACアドレス(MAC,~~~)この処理はjs

        socket_message(@message)
    end

    
    

    def done
    end


end
