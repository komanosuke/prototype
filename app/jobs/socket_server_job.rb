require 'socket'

class SocketServerJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    host = '172.31.36.4'
    port = 8000
    request_cmd = nil #jsから送られてくるものをcontrollerで受け取ってここに入れる。以下の処理を関数にしておいて、受け取ったら発火するようにすればいい。

    maxlen = 300

    server = TCPServer.open(4000)   # <- この１行でTCPServer接続できる(本プログラムはサーバー側)
    loop do
        Thread.start(server.accept) do |socket|
            begin
                loop do
                    buf = socket.readpartial(maxlen) #クライアントから受信
                    if buf.start_with?('ID?') #条件分岐の確認 送信されてくる文字列の後ろに \x00がついてくるため、 buf == 'ID?' ではなく「はじめの文字」で識別している。
                        socket.write 'pi' #クライアントに返答
                    elsif buf.start_with?('PWD?')
                        socket.write 'bench' #クライアントに返答
                    # elsif buf.start_with?('TEMPERATURE')
                    #     @temperature = buf
                    # elsif buf.start_with?('BATTERY')
                    #     @battery = buf
                    # elsif buf.start_with?('FAN')
                    #     @fan = buf
                    # elsif buf.start_with?('INVERTER')
                    #     @inverter = buf
                    # elsif buf.start_with?('DISPLAY')
                    #     @display = buf
                    # elsif buf.start_with?('AUDIO')
                    #     @audio = buf
                    # elsif buf.start_with?('LED')
                    #     @LED = buf
                    # elsif buf.start_with?('COLOR')
                    #     @color = buf
                    # elsif buf.start_with?('HUMAN')
                    #     @human = buf
                    # elsif buf.start_with?('AC1')
                    #     @ac1 = buf
                    # elsif buf.start_with?('AC2')
                    #     @ac2 = buf
                    # elsif buf.start_with?('USB5V')
                    #     @usb5v = buf
                    # elsif buf.start_with?('WIFIUSE')
                    #     @wifiuse = buf
                    # elsif buf.start_with?('POSITION')
                    #     @position = buf
                    # elsif buf.start_with?('MESSAGE')
                    #     @message = buf
                    elsif buf.start_with?('REQUEST')
                        if request_cmd != nil
                            socket.write request_cmd
                            request_cmd = nil
                        else
                            socket.write 'OK'
                        end
                    else
                        socket.write 'OK'
                    end
                    
                    pp buf # 動作確認のためサーバ側標準出力
                end
            rescue EOFError => e    # rescueの場合の例外処理。
                $stdout.write('eof\n') # 切断の記述
            rescue => e    # begin~rescueの間でエラーが発生した場合に実行されるコードを書く。エラーがなかったら実行されない。
                print e.backtrace.join('\n')
            ensure    #絶対実行
                socket.close
            end
        end
    end
  end
end
