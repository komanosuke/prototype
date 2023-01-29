class ShortcutJob < ApplicationJob
  queue_as :default

  def perform(id)
    shortcut = Shortcut.find(id)
    # puts 'タイトル：' + shortcut.title
    # puts '開始時間：' + shortcut.start_time.to_s
    # puts '終了時間：' + shortcut.end_time.to_s
    # puts 'プログラム：' + shortcut.program
    socket_message('SUCCESS!!!!')
    puts 'SUCCESS!!!!'
  end
end


def socket_message(msg)
  maxlen = 400
  begin
      TCPSocket.open("localhost", 4000) do |socket|

          t1 = Thread.start do #送信スレッド
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
  rescue
      @sock = 'error'
  end
end
