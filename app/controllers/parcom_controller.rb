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

        # 初期化処理
        # if BenchImage.where(id: 1).empty?
            
        #     #デフォルト画像のパス
        # elsif BenchVideo.where(id: 1).empty?
            
        #     #デフォルトMP4のパス
        # elsif BenchAudio.where(id: 1).empty?
            
        #     #デフォルトMP3のパス
        # else
        @bench_image_now = BenchImage.where(user_id: current_user.id).last
        @bench_video_now = BenchVideo.where(user_id: current_user.id).last
        @bench_audio_now = BenchAudio.where(user_id: current_user.id).last
        # end
        
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
    
        area_data = [
            {"北海道"=>[
                {"稚内"=>
                    "稚内市,宗谷郡,枝幸郡,天塩郡,礼文郡,利尻郡"
                },
                { "旭川"=>
                    "旭川市,士別市,名寄市,富良野市,上川郡,空知郡,勇払郡,中川郡,中川郡"
                },
                { "留萌"=>
                    "留萌市,増毛郡,留萌郡,苫前郡,天塩郡"
                },
                { "網走"=>
                    "北見市,網走市,網走郡,斜里郡,常呂郡"
                },
                { "北見"=>
                    "北見市,常呂郡"
                },
                { "紋別"=>
                    "紋別市,紋別郡"
                },
                { "根室"=>
                    "根室市,野付郡,標津郡,目梨郡,色丹郡,国後郡,択捉郡,紗那郡,蘂取郡"
                },
                { "釧路"=>
                    "釧路市,釧路郡,厚岸郡,川上郡,阿寒郡,白糠郡"
                },
                { "帯広"=>
                    "帯広市,河東郡,上川郡,河西郡,広尾郡,中川郡,足寄郡,十勝郡"
                },
                { "室蘭"=>
                    "室蘭市,苫小牧市,登別市,伊達市,虻田郡,有珠郡,白老郡,勇払郡"
                },
                { "浦河"=>
                    "沙流郡,新冠郡,浦河郡,様似郡,幌泉郡,日高郡"
                },
                { "札幌"=>
                    "札幌市,江別市,千歳市,恵庭市,北広島市,石狩市,石狩郡"
                },
                { "岩見沢"=>
                    "夕張市,岩見沢市,美唄市,芦別市,赤平市,三笠市,滝川市,砂川市,歌志内市,深川市,空知郡,夕張郡,樺戸郡,雨竜郡"
                },
                { "倶知安"=>
                    "小樽市,島牧郡,寿都郡,磯谷郡,虻田郡,岩内郡,古宇郡,積丹郡,古平郡,余市郡"
                },
                { "函館"=>
                    "函館市,北斗市,松前郡,上磯郡,亀田郡,茅部郡,二海郡,山越郡"
                },
                { "江差"=>
                    "二海郡八雲町,檜山郡,爾志郡,奥尻郡,瀬棚郡,久遠郡"
                }
            ]},
        
            {"青森県"=>[
                {"青森"=>
                    "青森市,弘前市,黒石市,五所川原市,つがる市,平川市,東津軽郡,西津軽郡,中津軽郡,南津軽郡,北津軽郡"
                },
                { "むつ"=>
                    "むつ市,下北郡"
                },
                { "八戸"=>
                    "八戸市,十和田市,三沢市,上北郡,三戸郡"
                }
            ]},
        
            {"岩手県"=>[
                {"盛岡"=>
                    "盛岡市,花巻市,北上市,遠野市,一関市,二戸市,八幡平市,奥州市,滝沢市,岩手郡,紫波郡,和賀郡,胆沢郡,西磐井郡,九戸郡,二戸郡"
                },
                { "宮古"=>
                    "宮古市,久慈市,下閉伊郡,九戸郡"
                },
                { "大船渡"=>
                    "大船渡市,陸前高田市,釜石市,気仙郡,上閉伊郡"
                }
            ]},
        
            {"宮城県"=>[
                {"仙台"=>
                    "仙台市,石巻市,塩竃市,気仙沼市,名取市,角田市,多賀城市,岩沼市,登米市,栗原市,東松島市,大崎市,富谷市,柴田郡,伊具郡,亘理郡,宮城郡,黒川郡,遠田郡,牡鹿郡,本吉郡"
                },
                { "白石"=>
                    "仙台市,白石市,栗原市,大崎市,刈田郡,柴田郡,黒川郡,加美郡"
                }
            ]},
        
            {"秋田県"=>[
                {"秋田"=>
                    "秋田市,能代市,男鹿市,由利本荘市,潟上市,にかほ市,山本郡,南秋田郡"
                },
                { "横手"=>
                    "横手市,大館市,湯沢市,鹿角市,大仙市,北秋田市,仙北市,鹿角郡,北秋田郡,仙北郡,雄勝郡"
                }
            ]},
        
            {"山形県"=>[
                {"山形"=>
                    "山形市,寒河江市,上山市,村山市,天童市,東根市,尾花沢市,東村山郡,西村山郡,北村山郡"
                },
                { "米沢"=>
                    "米沢市,長井市,南陽市,東置賜郡,西置賜郡"
                },
                { "酒田"=>
                    "鶴岡市,酒田市,東田川郡,飽海郡"
                },
                { "新庄"=>
                    "新庄市,最上郡"
                }
            ]},
        
            {"福島県"=>[
                {"福島"=>
                    "福島市,郡山市,白河市,須賀川市,二本松市,田村市,伊達市,本宮市,伊達郡,安達郡,岩瀬郡,西白河郡,東白川郡,石川郡,田村郡"
                },
                { "小名浜"=>
                    "いわき市,相馬市,南相馬市,双葉郡,相馬郡"
                },
                { "若松"=>
                    "会津若松市,郡山市,喜多方市,岩瀬郡天栄村,南会津郡,耶麻郡,河沼郡,大沼郡"
                }
            ]},
        
            {"茨城県"=>[
                {"水戸"=>
                    "水戸市,日立市,常陸太田市,高萩市,北茨城市,笠間市,ひたちなか市,常陸大宮市,那珂市,小美玉市,東茨城郡,那珂郡,久慈郡"
                },
                { "土浦"=>
                    "土浦市,古河市,石岡市,結城市,龍ヶ崎市,下妻市,常総市,取手市,牛久市,つくば市,鹿嶋市,潮来市,守谷市,筑西市,坂東市,稲敷市,かすみがうら市,桜川市,神栖市,行方市,鉾田市,つくばみらい市,稲敷郡,結城郡,猿島郡,北相馬郡"
                }
            ]},
        
            {"栃木県"=>[
                {"宇都宮"=>
                    "宇都宮市,足利市,栃木市,佐野市,鹿沼市,小山市,真岡市,さくら市,那須烏山市,下野市,河内郡,芳賀郡,下都賀郡,塩谷郡,那須郡"
                },
                { "大田原"=>
                    "日光市,大田原市,矢板市,那須塩原市,塩谷郡,那須郡"
                }
            ]},
        
            {"群馬県"=>[
                {"前橋"=>
                    "前橋市,高崎市,桐生市,伊勢崎市,太田市,館林市,渋川市,藤岡市,富岡市,安中市,みどり市,北群馬郡,多野郡,甘楽郡,佐波郡,邑楽郡"
                },
                { "みなかみ"=>
                    "沼田市,吾妻郡,利根郡"
                }
            ]}, 
        
            {"埼玉県"=>[
                {"さいたま"=>
                    "さいたま市,川越市,川口市,所沢市,飯能市,春日部市,狭山市,上尾市,草加市,越谷市,蕨市,戸田市,入間市,朝霞市,志木市,和光市,新座市,桶川市,北本市,八潮市,富士見市,三郷市,蓮田市,坂戸市,幸手市,鶴ヶ島市,日高市,吉川市,ふじみ野市,白岡市,北足立郡,入間郡,比企郡,南埼玉郡,北葛飾郡"
                },
                { "熊谷"=>
                    "熊谷市,行田市,加須市,本庄市,東松山市,羽生市,鴻巣市,深谷市,久喜市,比企郡,秩父郡,児玉郡,大里郡"
                },
                { "秩父"=>
                    "秩父市,秩父郡"
                }
            ]},
        
            {"千葉県"=>[
                {"千葉"=>
                    "千葉市,市川市,船橋市,松戸市,野田市,成田市,佐倉市,習志野市,柏市,市原市,流山市,八千代市,我孫子市,鎌ヶ谷市,浦安市,四街道市,八街市,印西市,白井市,富里市,印旛郡"
                },
                { "銚子"=>
                    "銚子市,茂原市,東金市,旭市,匝瑳市,香取市,山武市,大網白里市,香取郡,山武郡,長生郡"
                },
                { "館山"=>
                    "館山市,木更津市,勝浦市,鴨川市,君津市,富津市,袖ヶ浦市,南房総市,いすみ市,夷隅郡,安房郡"
                }
            ]},
        
            {"東京都"=>[
                {"東京"=>
                    "千代田区,中央区,港区,新宿区,文京区,台東区,墨田区,江東区,品川区,目黒区,大田区,世田谷区,渋谷区,中野区,杉並区,豊島区,北区,荒川区,板橋区,練馬区,足立区,葛飾区,江戸川区,八王子市,立川市,武蔵野市,三鷹市,青梅市,府中市,昭島市,調布市,町田市,小金井市,小平市,日野市,東村山市,国分寺市,国立市,福生市,狛江市,東大和市,清瀬市,東久留米市,武蔵村山市,多摩市,稲城市,羽村市,あきる野市,西東京市,西多摩郡"
                },
                { "大島"=>
                    "大島町,利島村,新島村,神津島村"
                },
                { "八丈島"=>
                    "三宅村,御蔵島村,八丈町,青ヶ島村"
                },
                { "父島"=>
                    "小笠原村"
                }
            ]},
        
            {"神奈川県"=>[
                {"横浜"=>
                    "横浜市,川崎市,横須賀市,平塚市,鎌倉市,藤沢市,茅ヶ崎市,逗子市,三浦市,大和市,海老名市,座間市,綾瀬市,三浦郡,高座郡,中郡"
                },
                { "小田原"=>
                    "相模原市,小田原市,秦野市,厚木市,伊勢原市,南足柄市,足柄上郡,足柄下郡,愛甲郡"
                }
            ]},
        
            {"山梨県"=>[
                {"甲府"=>
                    "甲府市,山梨市,韮崎市,南アルプス市,北杜市 ,甲斐市,笛吹市,甲州市,中央市,西八代郡,南巨摩郡,中巨摩郡"
                },
                { "河口湖"=>
                    "富士吉田市,都留市,大月市,上野原市,南都留郡,北都留郡"
                }
            ]},
        
            {"長野県"=>[
                {"長野"=>
                    "長野市,須坂市,中野市,大町市,飯山市,千曲市,北安曇郡,埴科郡,上高井郡,下高井郡,上水内郡,下水内郡"
                },
                { "松本"=>
                    "松本市,上田市,岡谷市,諏訪市,小諸市,茅野市,塩尻市,佐久市,東御市,安曇野市,南佐久郡,北佐久郡,小県郡,諏訪郡,東筑摩郡"
                },
                { "飯田"=>
                    "飯田市,伊那市,駒ヶ根市,塩尻市,上伊那郡,下伊那郡,木曽郡"
                }
            ]},
        
            {"岐阜県"=>[
                {"岐阜"=>
                    "岐阜市,大垣市,多治見市,関市,中津川市,美濃市,瑞浪市,羽島市,恵那市,美濃加茂市,土岐市,各務原市,可児市,山県市,瑞穂市,本巣市,郡上市,海津市,羽島郡,養老郡,不破郡,安八郡,揖斐郡,本巣郡,加茂郡,可児郡"
                },
                { "高山"=>
                    "高山市,飛騨市,下呂市,大野郡"
                }
            ]},
        
            {"静岡県"=>[
                {"静岡"=>
                    "静岡市,島田市,焼津市,藤枝市,牧之原市,榛原郡"
                },
                { "網代"=>
                    "熱海市,伊東市,下田市,伊豆市,伊豆の国市,賀茂郡,田方郡"
                },
                { "三島"=>
                    "沼津市,三島市,富士宮市,富士市,御殿場市,裾野市,駿東郡"
                },
                { "浜松"=>
                    "浜松市,磐田市,掛川市,袋井市,湖西市,御前崎市,菊川市,周智郡"
                }
            ]},
        
            {"愛知県"=>[
                {"名古屋"=>
                    "名古屋市,岡崎市,一宮市,瀬戸市,半田市,春日井市,津島市,碧南市,刈谷市,豊田市,安城市,西尾市,犬山市,常滑市,江南市,小牧市,稲沢市,東海市,大府市,知多市,知立市,尾張旭市,高浜市,岩倉市,豊明市,日進市,愛西市,清須市,北名古屋市,弥富市,みよし市,あま市,長久手市,愛知郡,西春日井郡,丹羽郡,海部郡,知多郡,額田郡"
                },
                { "豊橋"=>
                    "豊橋市,豊川市,豊田市,蒲郡市,新城市,田原市,北設楽郡"
                }
            ]},
        
            {"三重県"=>[
                {"津"=>
                    "津市,四日市市,松阪市,桑名市,鈴鹿市,名張市,亀山市,いなべ市,伊賀市,桑名郡,員弁郡,三重郡,多気郡"
                },
                { "尾鷲"=>
                    "伊勢市,尾鷲市,鳥羽市,熊野市,志摩市,多気郡,度会郡,北牟婁郡,南牟婁郡"
                }
            ]},
        
            {"新潟県"=>[
                {"新潟"=>
                    "新潟市,新発田市,村上市,燕市,五泉市,阿賀野市,胎内市,北蒲原郡,西蒲原郡,東蒲原郡,岩船郡"
                },
                { "長岡"=>
                    "長岡市,三条市,柏崎市,小千谷市,加茂市,十日町市,見附市,魚沼市,南魚沼市, 南蒲原郡,三島郡,南魚沼郡,中魚沼郡,刈羽郡"
                },
                { "高田"=>
                    "上越市,糸魚川市,妙高市"
                },
                { "相川"=>
                    "佐渡市"
                }
            ]},
        
            {"富山県"=>[
                {"富山"=>
                    "富山市,魚津市,滑川市,黒部市,中新川郡,下新川郡"
                },
                { "伏木"=>
                    "高岡市,氷見市,砺波市,小矢部市,南砺市,射水市"
                }
            ]},
        
            {"石川県"=>[
                {"金沢"=>
                    "金沢市,小松市,加賀市,かほく市,白山市,能美市,野々市市,能美郡,河北郡"
                },
                { "輪島"=>
                    "七尾市,輪島市,珠洲市,羽咋市,羽咋郡,鹿島郡,鳳珠郡"
                }
            ]},
        
            {"福井県"=>[
                {"福井"=>
                    "福井市,大野市,勝山市,鯖江市,あわら市,越前市,坂井市,吉田郡,今立郡,南条郡,丹生郡"
                },
                { "敦賀"=>
                    "敦賀市,小浜市,三方郡,大飯郡,三方上中郡"
                }
            ]},
        
            {"滋賀県"=>[
                {"大津"=>
                    "大津市,近江八幡市,草津市,守山市,栗東市,甲賀市,野洲市,湖南市,東近江市,蒲生郡"
                },
                { "彦根"=>
                    "大津市,彦根市,長浜市,高島市,米原市,愛知郡,犬上郡"
                }
            ]},
        
            {"京都府"=>[
                {"京都"=>
                    "京都市,宇治市,亀岡市,城陽市,向日市,長岡京市,八幡市,京田辺市,南丹市,木津川市,乙訓郡,久世郡,綴喜郡,相楽郡,船井郡"
                },
                { "舞鶴"=>
                    "福知山市,舞鶴市,綾部市,宮津市,京丹後市,与謝郡"
                }
            ]},
        
            {"大阪府"=>[
                {"大阪"=>
                    "大阪府"
                }
            ]},
        
            {"兵庫県"=>[
                {"神戸"=>
                    "神戸市,姫路市,尼崎市,明石市,西宮市,洲本市,芦屋市,伊丹市,相生市,加古川市,赤穂市,西脇市,宝塚市,三木市,高砂市,川西市,小野市,三田市,加西市,篠山市,丹波市,南あわじ市,淡路市,宍粟市,加東市,たつの市,川辺郡,多可郡,加古郡,神崎郡,揖保郡,赤穂郡,佐用郡"
                },
                { "豊岡"=>
                    "豊岡市,養父市,朝来市,美方郡"
                }
            ]},
        
            {"奈良県"=>[
                {"奈良"=>
                    "奈良市,大和高田市,大和郡山市,天理市,橿原市,桜井市,五條市,御所市,生駒市,香芝市,葛城市,宇陀市,山辺郡,生駒郡,磯城郡,高市郡,北葛城郡,吉野郡"
                },
                { "風屋"=>
                    "五條市,宇陀郡,吉野郡"
                }
            ]},
        
            {"和歌山県"=>[
                {"和歌山"=>
                    "和歌山市,海南市,橋本市,有田市,御坊市,紀の川市,岩出市,海草郡,伊都郡,有田郡,日高郡"
                },
                { "潮岬"=>
                    "田辺市,新宮市,西牟婁郡,東牟婁郡"
                }
            ]},
        
            {"鳥取県"=>[
                {"鳥取"=>
                    "鳥取市,岩美郡,八頭郡"
                },
                { "米子"=>
                    "米子市,倉吉市,境港市,東伯郡,西伯郡,日野郡"
                }
            ]},
        
            {"島根県"=>[
                {"松江"=>
                    "松江市,出雲市,安来市,雲南市,仁多郡,飯石郡"
                },
                { "浜田"=>
                    "浜田市,益田市,大田市,江津市,邑智郡,鹿足郡"
                },
                { "西郷"=>
                    "隠岐郡"
                }
            ]},
        
            {"岡山県"=>[
                {"岡山"=>
                    "岡山市,倉敷市,玉野市,笠岡市,井原市,総社市,高梁市,備前市,瀬戸内市,赤磐市,浅口市,和気郡,都窪郡,浅口郡,小田郡,加賀郡"
                },
                { "津山"=>
                    "津山市,新見市,真庭市,美作市,真庭郡,苫田郡,勝田郡,英田郡,久米郡"
                }
            ]},
        
            {"広島県"=>[
                {"広島"=>
                    "広島市,呉市,竹原市,三原市,尾道市,福山市,府中市,大竹市,東広島市,廿日市市,江田島市,安芸郡,豊田郡,世羅郡,神石郡"
                },
                { "庄原"=>
                    "三次市,庄原市,安芸高田市,山県郡"
                }
            ]},
        
            {"徳島県"=>[
                {"徳島"=>
                    "徳島市,鳴門市,小松島市,吉野川市,阿波市,美馬市,三好市,名東郡,名西郡,板野郡,美馬郡,三好郡"
                },
                { "日和佐"=>
                    "阿南市,勝浦郡,那賀郡,海部郡"
                }
            ]},
        
            {"香川県"=>[
                {"高松"=>
                    "香川県"
                }
            ]},
        
            {"愛媛県"=>[
                {"松山"=>
                    "松山市,伊予市,東温市,上浮穴郡,伊予郡"
                },
                { "新居浜"=>
                    "今治市,新居浜市,西条市,四国中央市,越智郡"
                },
                { "宇和島"=>
                    "宇和島市,八幡浜市,大洲市,西予市,喜多郡,西宇和郡,北宇和郡,南宇和郡"
                }
            ]},
        
            {"高知県"=>[
                {"高知"=>
                    "高知市,南国市,土佐市,須崎市,香南市,香美市,長岡郡,土佐郡,吾川郡,高岡郡"
                },
                { "室戸岬"=>
                    "室戸市,安芸市,安芸郡"
                },
                { "清水"=>
                    "宿毛市,土佐清水市,四万十市,高岡郡,幡多郡"
                }
            ]},
        
            {"山口県"=>[
                {"下関"=>
                    "下関市,宇部市,山陽小野田市"
                },
                { "山口"=>
                    "山口市,防府市,下松市,周南市"
                },
                { "柳井"=>
                    "岩国市,光市,柳井市,大島郡,玖珂郡,熊毛郡"
                },
                { "萩"=>
                    "萩市,長門市,美祢市,阿武郡"
                }
            ]},
        
            {"福岡県"=>[
                {"福岡"=>
                    "福岡市,筑紫野市,春日市,大野城市,宗像市,太宰府市,古賀市,福津市,糸島市,筑紫郡,糟屋郡"
                },
                { "八幡"=>
                    "北九州市,行橋市,豊前市,中間市,遠賀郡,京都郡,築上郡"
                },
                { "飯塚"=>
                    "直方市,飯塚市,田川市,宮若市,嘉麻市,鞍手郡,嘉穂郡,田川郡"
                },
                { "久留米"=>
                    "大牟田市,久留米市,柳川市,八女市,筑後市,大川市,小郡市,うきは市,朝倉市,みやま市,朝倉郡,三井郡,三潴郡,八女郡"
                }
            ]},
        
            {"佐賀県"=>[
                {"佐賀"=>
                    "佐賀市,鳥栖市,多久市,武雄市,鹿島市,小城市,嬉野市,神埼市,神埼郡,三養基郡,杵島郡,藤津郡"
                },
                { "伊万里"=>
                    "唐津市,伊万里市,東松浦郡,西松浦郡"
                }
            ]},
        
            {"長崎県"=>[
                {"長崎"=>
                    "長崎市,島原市,諫早市,大村市,西海市,雲仙市,南島原市,西彼杵郡"
                },
                { "佐世保"=>
                    "佐世保市,平戸市,松浦市,東彼杵郡,北松浦郡"
                },
                { "厳原"=>
                    "対馬市,壱岐市"
                },
                { "福江"=>
                    "佐世保市,五島市,西海市,北松浦郡,南松浦郡"
                }
            ]},
        
            {"熊本県"=>[
                {"熊本"=>
                    "熊本市,八代市,,荒尾市,玉名市,山鹿市,菊池市,宇土市,宇城市,合志市,下益城郡,玉名郡,菊池郡,阿蘇郡,上益城郡,八代郡"
                },
                { "阿蘇乙姫"=>
                    "阿蘇市,阿蘇郡"
                },
                { "牛深"=>
                    "水俣市,上天草市,天草市,葦北郡,天草郡"
                },
                { "人吉"=>
                    "人吉市,球磨郡"
                }
            ]},
        
            {"大分県"=>[
                {"大分"=>
                    "大分市,別府市,臼杵市,津久見市,杵築市,由布市,速見郡"
                },
                { "中津"=>
                    "中津市,豊後高田市,宇佐市,国東市,東国東郡"
                },
                { "日田"=>
                    "日田市,竹田市,玖珠郡"
                },
                { "佐伯"=>
                    "佐伯市,豊後大野市"
                }
            ]},
        
            {"宮崎県"=>[
                {"宮崎"=>
                    "宮崎市,日南市,串間市,東諸県郡"
                },
                { "延岡"=>
                    "延岡市,日向市,西都市,児湯郡,東臼杵郡"
                },
                { "都城"=>
                    "都城市,小林市,えびの市,北諸県郡,西諸県郡"
                },
                { "高千穂"=>
                    "児湯郡,東臼杵郡,西臼杵郡"
                }
            ]},
        
            {"鹿児島県"=>[
                {"鹿児島"=>
                    "鹿児島市,枕崎市,阿久根市,出水市,指宿市,薩摩川内市,日置市,霧島市,いちき串木野市,南さつま市,南九州市,伊佐市,姶良市,薩摩郡,出水郡,姶良郡"
                },
                { "鹿屋"=>
                    "鹿屋市,垂水市,曽於市,志布志市,曽於郡,肝属郡"
                },
                { "種子島"=>
                    "西之表市,鹿児島郡,熊毛郡"
                },
                { "名瀬"=>
                    "奄美市,鹿児島郡,大島郡"
                }
            ]},
        
            {"沖縄県"=>[
                {"那覇"=>
                    "那覇市,宜野湾市,浦添市,糸満市,沖縄市,豊見城市,うるま市,南城市,中頭郡,島尻郡"
                },
                { "名護"=>
                    "名護市,国頭郡,島尻郡"
                },
                { "久米島"=>
                    "島尻郡"
                },
                { "南大東"=>
                    "島尻郡"
                },
                { "宮古島"=>
                    "宮古島市,宮古郡"
                },
                { "石垣島"=>
                    "石垣市,八重山郡"
                },
                { "与那国島"=>
                    "八重山郡"
                }
            ]}
        ]
        b = ''
        area_codes = {"稚内"=>"011000","旭川"=>"012010","留萌"=>"012020","網走"=>"013010","北見"=>"013020","紋別"=>"013030","根室"=>"014010","釧路"=>"014020","帯広"=>"014030","室蘭"=>"015010","浦河"=>"015020","札幌"=>"016010","岩見沢"=>"016020","倶知安"=>"016030","函館"=>"017010","江差"=>"017020","青森"=>"020010","むつ"=>"020020","八戸"=>"020030","盛岡"=>"030010","宮古"=>"030020","大船渡"=>"030030","仙台"=>"040010","白石"=>"040020","秋田"=>"050010","横手"=>"050020","山形"=>"060010","米沢"=>"060020","酒田"=>"060030","新庄"=>"060040","福島"=>"070010","小名浜"=>"070020","若松"=>"070030","水戸"=>"080010","土浦"=>"080020","宇都宮"=>"090010","大田原"=>"090020","前橋"=>"100010","みなかみ"=>"100020","さいたま"=>"110010","熊谷"=>"110020","秩父"=>"110030","千葉"=>"120010","銚子"=>"120020","館山"=>"120030","東京"=>"130010","大島"=>"130020","八丈島"=>"130030","父島"=>"130040","横浜"=>"140010","小田原"=>"140020","新潟"=>"150010","長岡"=>"150020","高田"=>"150030","相川"=>"150040","富山"=>"160010","伏木"=>"160020","金沢"=>"170010","輪島"=>"170020","福井"=>"180010","敦賀"=>"180020","甲府"=>"190010","河口湖"=>"190020","長野"=>"200010","松本"=>"200020","飯田"=>"200030","岐阜"=>"210010","高山"=>"210020","静岡"=>"220010","網代"=>"220020","三島"=>"220030","浜松"=>"220040","名古屋"=>"230010","豊橋"=>"230020","津"=>"240010","尾鷲"=>"240020","大津"=>"250010","彦根"=>"250020","京都"=>"260010","舞鶴"=>"260020","大阪"=>"270000","神戸"=>"280010","豊岡"=>"280020","奈良"=>"290010","風屋"=>"290020","和歌山"=>"300010","潮岬"=>"300020","鳥取"=>"310010","米子"=>"310020","松江"=>"320010","浜田"=>"320020","西郷"=>"320030","岡山"=>"330010","津山"=>"330020","広島"=>"340010","庄原"=>"340020","下関"=>"350010","山口"=>"350020","柳井"=>"350030","萩"=>"350040","徳島"=>"360010","日和佐"=>"360020","高松"=>"370000","松山"=>"380010","新居浜"=>"380020","宇和島"=>"380030","高知"=>"390010","室戸岬"=>"390020","清水"=>"390030","福岡"=>"400010","八幡"=>"400020","飯塚"=>"400030","久留米"=>"400040","佐賀"=>"410010","伊万里"=>"410020","長崎"=>"420010","佐世保"=>"420020","厳原"=>"420030","福江"=>"420040","熊本"=>"430010","阿蘇乙姫"=>"430020","牛深"=>"430030","人吉"=>"430040","大分"=>"440010","中津"=>"440020","日田"=>"440030","佐伯"=>"440040","宮崎"=>"450010","延岡"=>"450020","都城"=>"450030","高千穂"=>"450040","鹿児島"=>"460010","鹿屋"=>"460020","種子島"=>"460030","名瀬"=>"460040","那覇"=>"471010","名護"=>"471020","久米島"=>"471030","南大東"=>"472000","宮古島"=>"473000","石垣島"=>"474010","与那国島"=>"474020"}
        adrs = @park.address
        prefs = ["北海道","青森県","岩手県","宮城県","秋田県","山形県","福島県","茨城県","栃木県","群馬県","埼玉県","千葉県","東京都","神奈川県","山梨県","長野県","岐阜県","静岡県","愛知県","三重県","新潟県","富山県","石川県","福井県","滋賀県","京都府","大阪府","兵庫県","奈良県","和歌山県","鳥取県","島根県","岡山県","広島県","徳島県","香川県","愛媛県","高知県","山口県","福岡県","佐賀県","長崎県","熊本県","大分県","宮崎県","鹿児島県","沖縄県"]
        prefs.each do |pref|
            if adrs.include? pref
                this_pref = pref
                area_data.each do |area|
                    if area.keys()[0] == pref
                        area[this_pref].each do |ar|
                            ar.each_value do |a|
                                al = a.split(',')
                                al.each do |l|
                                    if adrs.include? l
                                        b = ar.keys()[0]
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        area_code = area_codes[b]

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
            sleep(1)
            cmd = params[:cmd]
            file = ':' + BenchImage.where(user_id: current_user.id).last.pdf_url
            # file = ':http://54.64.49.214:3000/' + BenchImage.where(user_id: current_user.id).last.pdf_url
            socket_message(cmd.gsub(/:/, file))
        elsif params[:cmd].include? 'MP4,ON'
            cmd = params[:cmd]
            file = ':' + BenchVideo.where(user_id: current_user.id).last.video.to_s
            # file = ':http://54.64.49.214:3000/' + BenchVideo.where(user_id: current_user.id).last.video.to_s
            socket_message(cmd.gsub(/:/, file))
        elsif params[:cmd].include? 'MP3,ON'
            cmd = params[:cmd]
            file = ':' + BenchAudio.where(user_id: current_user.id).last.audio.to_s
            # file = ':http://54.64.49.214:3000/' + BenchAudio.where(user_id: current_user.id).last.audio.to_s
            socket_message(cmd.gsub(/:/, file))
        elsif params[:cmd].include? 'LEDONTIME'
            mac_adrs = params[:cmd].gsub(/(.*?)MAC,/, "")
            @bench = Bench.find_by(mac_address: mac_adrs)
            if params[:cmd].include? ',1,'
                @bench.update(timer: true)
            else
                @bench.update(timer: false)
            end
            socket_message(params[:cmd])
        elsif params[:cmd].include? 'TIMER,OFF'
            mac_adrs = params[:cmd].gsub(/(.*?)MAC,/, "")
            @bench = Bench.find_by(mac_address: mac_adrs)
            @bench.update(timer: false)
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
            file = Magick::Image.read("http://localhost:3000" + img_url)[0]
            # 保存先をフルパスで指定
            url = "/Users/komaitoshihiko/Desktop/prototype/public" + img_path + "/out.pdf"
            # url = "awsのパス/public" + img_path + "/out.pdf"
            file.write(url)
            # OK　名前をout.pdfからタイムスタンプにして保存
            new_url = img_path + "/out.pdf"

            # アップロードされたファイルを削除して完全にアップデートする（発想を変えて、imageはなくなるがurlは残る。全消ししたい場合はフォルダを丸ごと消す）
            # @bench_image.update(image: nil)
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
        @picture = Picture.last
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
        @pager = Kaminari.paginate_array(@article_datas).page(params[:page]).per(2)
        #PARCOMに関するお知らせサイドバー
        # @article_datas_cat = []
        for i in 0..article_res_json_cat.length-1
            cat = {}
            cat["link"] = (article_res_json_cat[i]["link"])
            cat["name"] = (article_res_json_cat[i]["name"])
            @article_datas_cat.push(cat)
        end

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
        @pager = Kaminari.paginate_array(@news_datas).page(params[:page]).per(3)
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









def socket_message(msg)
    maxlen = 400

    queue = []

    begin
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