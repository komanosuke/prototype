# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create(role: 'admin', user_registered: '2022-12-21', user_login: 0, display_name: '金沢市', user_email: 'aaa@mail.com', user_pass: 'aaaa', user_zip: '000-0000', user_prefecture: '石川県', user_address: '金沢市〇〇町', user_street: '111番地', user_tel: '111-1111', user_municipality: '金沢市', user_division: '〇〇課', user_image: nil, user_profile: '〇〇課です。よろしくです。', user_notification: 'OK', user_flag: 'OK', user_admin_memo: '特になし。')

Park.create(user_id: 1, post_date: '2022-12-21', post_status: 'OK', name: '〇〇公園', zip: '000-0000', prefecture: '石川県', address: '金沢市', street: '〇〇村', hours: {'Mon':'00:00-00:00','Tue':'00:00-00:00','Wed':'00:00-00:00','Thu':'00:00-00:00','Fri':'00:00-00:00','Sat':'00:00-00:00','Sun':'00:00-00:00'}, tel: '111-1111', fee: {'大人':'100円','子供':'0円'}, map: '123,456', website: 'https://aaa.jp', size: '100平方メートル', profile: '楽しい公園です。', status: 'OK', parking_info: {'無料駐車場':true,'有料駐車場':true, '大型バス駐車OK':true, '駐輪場':true, 'EV充電スタンド':true, '立体駐車場':true, '近隣コインパーキング':true}, toilet_info: {'男女別トイレ':true, '子ども用トイレ':true, 'おむつ交換台':true, 'ベビーケアルーム':true, 'ベビーチェア':true, 'オストメイト用設備':true, 'バリアフリー':true, '着替え台':true}, playground_info: {'滑り台':true, 'ブランコ':true, 'うんてい':true, 'ジャングルジム':true, '鉄棒':true, 'スプリング遊具':true, '砂場':true, 'シーソー':true, 'アスレチック':true}, facility_info: {'美術館　博物館　図書館':true, '体育館・ジム':true, '屋外プール':true, 'ドッグ':true}, sports_info: {'ボール使用OK':true, 'スケートボードOK':true, '自転車走行OK':true}, view_info: {'花見':true, '紅葉':true}, disaster_info: {'防災指定場所':true}, other_info:{'無料Wi-Fi提供':true, 'ベンチ':true, 'ゴミ箱':true, '手洗い場':true, 'AED':true, '噴水':true, '芝生':true, '充電スポット':true})

Bench.create(park_id: 1, name: 'ベンチ１', mac_address: '1111', os_name: 'OS11', introduced_date: '2022-12-21', position: '123,456', timer: false)

News.create(date: '2022-12-21', title: 'ニュース１', contents: 'ニュースです。')

Medium.create(date: '2022-12-21', title: 'メディア１', contents: 'メディアです。')

Shortcut.create(bench_id: 1, name: 'ショートカット１', program: 'a,b,c,d', introduced_date: '2022-12-21')

Event.create(park_id: 1, name: 'イベント１', contents: 'イベントがあります。')

Product.create(park_id: 1, name: 'プロダクト１', contents: 'こんなプロダクトがあります。')

Picture.create(park_id: 1, name: '春の景色', picture: nil)

TmpDatum.create(data: 'aaaa', mac_address: '1111')

TmpMessage.create(message: 'FAN,OFF,MAC,1111')

