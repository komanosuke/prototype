# 以下はスマートベンチから受信しているデータの例
#   "{BATTERY,5.635}{TEMPERATURE,19.75}{FAN,OFF}{DISPLAY,OFF}{POSITION,LAT:36.383,LON:136.381}{LED,OFF}{COLOR,R:0,G:0,B:0}{HUMAN,R:0,L:0}{AUDIO,OFF}{MP3,OFF}{MP4,OFF}{USB5V,OFF}{WIFIUSE,1}{MESSAGE,none}{GTEMPERATURE,23.64}{HUMIDITY,58.02}{LIGHT,26}{PRESS,1025.856}{NOISE,52.29}{ETVOC,45}{CO2,700}{DISCOMFORT,70.73}{HEAT,21.13},MAC,e45f01422d6b\\x0000"
# これを以下の形にしてPARCOM_OSの  http(s)://xxx/parcom/get_data  に送信する
#   (例)"{ "ID"=>"parcom" , "MAC_ADDRESS"=>"(※MACアドレス)" , "DATA"=>"(※上記のデータ)" }"
#   (実例)"{"ID"=>"parcom","MAC_ADDRESS"=>"e45f01422d6b","DATA"=>"{BATTERY,5.635}{TEMPERATURE,19.75}{FAN,OFF}{DISPLAY,OFF}{POSITION,LAT:36.383,LON:136.381}{LED,OFF}{COLOR,R:0,G:0,B:0}{HUMAN,R:0,L:0}{AUDIO,OFF}{MP3,OFF}{MP4,OFF}{USB5V,OFF}{WIFIUSE,1}{MESSAGE,none}{GTEMPERATURE,23.64}{HUMIDITY,58.02}{LIGHT,26}{PRESS,1025.856}{NOISE,52.29}{ETVOC,45}{CO2,700}{DISCOMFORT,70.73}{HEAT,21.13},MAC,e45f01422d6b\\x0000"}"

# 本プログラムの構成
#   ソケットサーバを常に開いた状態にし、クライアント（各ベンチおよびPARCOM OS）からのデータの中継地点とする。
#   ①各ベンチからデータを送信されると、許可されたMACアドレスの通信かを認識し、send_dataメソッドでPARCOM OSに送信する
#   ②PARCOM_OSからコマンドを送信されると、コマンドに付随したMACアドレスが許可されたものかを判断し、そのアドレスのベンチにコマンドを送信する



#------   設定変更はここで   ------#
# URI設定
BASE_URL = "http://localhost:3000"
GET_URI = "#{BASE_URL}/parcom/get_data?"
# ソケットのポート番号
port = 4000
# PARCOM OSからのコマンドが、MACアドレスのバリューの配列に入る ※ここに登録済みのMACアドレスとしか通信しない
request_list = {
    "e45f01422d6b"=>[],
    "f56f01422d6c"=>[],
    "g67f01422d6d"=>[],
}
# request_listのキーでできた配列を、許可されたベンチのMACアドレス群とする (例)["e45f01422d6b", "f56f01422d6c", "g67f01422d6d"]
allowed_mac_adrs_list = request_list.keys
# サーバーに負荷をかけないために、クライアントから受信する文字列の長さを制限
maxlen = 400
#--------------------------------#




require 'socket'
require "net/https"
require "uri"
require "json"

# PARCOM OSにデータを送るメソッド
def send_data(data)
    params = URI.encode_www_form(data) # パラメータ取得

    # URL構成要素を取得 (uri.host, uri.port)
    uri = URI.parse("#{GET_URI}#{params}")
    # セッション開始
    http = Net::HTTP.new(uri.host, uri.port)

    # SSL接続時の設定
    # http.use_ssl = true
    # http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    # get実行
    req = Net::HTTP::Get.new(uri.request_uri)

    begin
    # リクエスト開始
    res = http.request(req)
    # jsonにパース
    results = JSON.parse(res.body)
    rescue => e
    # p e.message（エラー捕捉）
    end
    # # ステータスコードを取得
    # pp res.code, res.msg
end




server = TCPServer.open(port)   # <- この１行でクライアント（各ベンチおよびPARCOM OS）と接続できる(本プログラムはソケットサーバー)
loop do # 以下ループ（クライアントからの送信があれば、dataを生成してPARCOMに送る）
	Thread.start(server.accept) do |socket|
        # スレッド内で、保存するデータはここ（PARCOM OSへの送信用データ）
        data = {
            "ID"=>"parcom",
            "MAC_ADDRESS"=>"",
            "DATA"=>""
        }
		begin
			loop do
				buf = socket.readpartial(maxlen) #クライアントから受信
				if buf.start_with?('ID?') #条件分岐の確認 送信されてくる文字列の後ろに \x00がついてくるため、 buf.start_with?('ID?' ではなく「はじめの文字」で識別している。
					mac_adrs = buf[0,16].delete('ID?,') #MACアドレス取得
                    if allowed_mac_adrs_list.include?(mac_adrs)
                        socket.write 'pi' #クライアントに返答    
                    end
				elsif buf.start_with?('PWD?')
                    mac_adrs = buf[0,17].delete('PWD?,')
                    if allowed_mac_adrs_list.include?(mac_adrs)
					    socket.write 'bench' #クライアントに返答
                    end
                elsif buf.start_with?('{BATTERY') #ベンチからのデータをPARCOM OSに送信する
                    mac_adrs = buf.gsub(/(.*?)MAC,/, "")[0,12]
                    data["MAC_ADDRESS"] = mac_adrs #MACアドレスをdataに登録
                    if allowed_mac_adrs_list.include?(mac_adrs)
                        if (request_list[mac_adrs] != []) #PARCOM OSからのコマンドがあるなら、コマンドをベンチに送る
                            for i in 0..request_list[mac_adrs].length-1 do
                                socket.write request_list[mac_adrs][i] + ',' # クライアントにコマンド送信（ベンチの仕様に合わせてコマンド最後にカンマを付与）
                                sleep(0.01)
                            end
                            request_list[mac_adrs] = []  # コマンド初期化
                        else
                            socket.write "OK"
                        end
                        
                        data['DATA'] = buf
                        send_data(data) #PARCOM OSにベンチからのデータを送信

                        # 以下、確認用出力
                        pp ''
                        pp 'PARCOM OSにデータ'
                        pp data.to_s
                        pp 'を送信します。'
                        pp 'これはMACアドレス: ' + data["MAC_ADDRESS"] + ' のベンチからの通信です。'
                        pp ''
                    end
                elsif buf.start_with?('FROM_RAILS') #PARCOM OSからのコマンドをベンチに送信する
                    mac_adrs_from_os = buf.gsub(/(.*?)MAC,/, "") #送信先ベンチのMACアドレスを認識
                    if allowed_mac_adrs_list.include?(mac_adrs_from_os)
                        data["MAC_ADDRESS"] = 'PARCOM OS'
                        request_cmd = buf.gsub(/FROM_RAILS : /, "").gsub(/,MAC,/, "").gsub(mac_adrs_from_os, "") #コマンドだけを取り出す
                        request_list[mac_adrs_from_os].push(request_cmd)

                        # 以下、確認用出力
                        pp ''
                        pp '-------------------  PARCOM OSからの通信です。 -------------------'
                        pp 'コマンド:  ' + request_cmd + '  をMACアドレス ' + mac_adrs_from_os + ' のベンチに送信します。'
                        
                        # クライアント側での確認用出力
                        socket.write 'リクエストコマンド：' + request_cmd + 'が送られてきました。MACアドレス: ' + mac_adrs_from_os + ' のベンチに送ります。'
                    end
                else
                    # socket.write '' #受けたいコマンドではないとき
				end
                pp 'DATA: ' + buf  # 動作確認のためサーバ側標準出力(ベンチからきたデータをターミナルに出力)
			end
		rescue EOFError => e    # rescueの場合の例外処理。
			$stdout.write('eof\n') # 切断
		rescue => e    # begin~rescueの間でエラーが発生した場合に実行されるコードを書く。エラーがなかったら実行されない。
			print e.backtrace.join('\n')
		ensure    #絶対実行

            # pp ''
            # if data["MAC_ADDRESS"] == 'PARCOM OS'
            #     pp  '---------------  PARCOM OSとの通信が終了しました。 ---------------'
            # elsif data["MAC_ADDRESS"] == ''
            #     pp '---------------  [ WARNING! ]  MACアドレス不明のデータが送信されました。 ---------------'
            # else
            #     pp '---------------  MACアドレス: ' + data["MAC_ADDRESS"] + ' のベンチとの通信が終了しました。 ---------------'
            # end
            # pp ''

			socket.close
		end
	end
end