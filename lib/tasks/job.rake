namespace :job do
  desc "ソケットサーバーを開く"
  task socket_server: :environment do
    SocketServerJob.perform_now
  end

end
