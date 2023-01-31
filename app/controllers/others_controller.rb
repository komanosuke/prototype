class OthersController < ApplicationController
    before_action :logged_in_user

    def link
        @park = Park.find_by(user_id: current_user.id)
        @bench = Bench.find_by(park_id: @park.id)

        # まず接続設定をおこなう
        # conn = Faraday.new(url: 'https://www.valuecommerce.ne.jp') do |faraday|
        #     faraday.request  :url_encoded             # form-encode POST params
        #     faraday.response :logger                  # log requests to STDOUT
        #     faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
        # end
        
        # # GETで記事一覧を取得する
        # response = conn.get '/stepup/wordpress-blog'

        # # JSONをパースする
        # parsed_articles = JSON.parse(response.body)
        
        # 記事一覧が出て来るので展開する
        # parsed_articles.each do |article|
        #     p article['id'] #記事id
        #     p article['title'] #タイトル
        #     p article['content'] #本文
        # end
    end
end