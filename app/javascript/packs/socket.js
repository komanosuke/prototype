let human_right_count = 0,
    human_left_count = 0,
    human_count = 0;
let ac1_count = 0,
    ac2_count = 0,
    ac_count = 0;

var socket = io.connect('http://54.64.49.214:3000');
socket.on('connect', function() {
 console.log('connect');
//   //0.１秒ごとにデータをリクエスト
//   setInterval(() => {
//   socket.emit('request', 'データ参照します。');
// }, 10);
  socket.emit('request', 'データ参照します。');

 socket.on('data', function(data) {
      console.log(data);
      var words = data.split(',');

      //位置情報
      //ex）POSITION,LAT:36.383,LON:136.381
      if ( words[0].match('POSITION') ){
        jQuery('#product_latlng').text( words[1].split(':')[1] + ',' + words[2].split(':')[1] );
      }

      //LED
      //ex）LED,ON
      if ( words[0].match('LED') ){
        // if( words[1].match(/ON/) ){
        //   jQuery('input[name="led_switch"]').prop('checked', true);
        //   jQuery('input[name="led_switch"]').closest('.toggle').addClass("checked");
        // } else if ( words[1].match(/OFF/) ){
        //   jQuery('input[name="led_switch"]').prop('checked', false);
        //   jQuery('input[name="led_switch"]').closest('.toggle').removeClass("checked");
        // }
      }




      //AUDIO
      //ex）AUDIO,ON
      if ( words[0].match('AUDIO') ){
        // if( words[1].match(/ON/) ){
        //   jQuery('input[name="audio_switch"]').prop('checked', true);
        //   jQuery('input[name="audio_switch"]').closest('.toggle').addClass("checked");
        // } else if ( words[1].match(/OFF/) ){
        //   jQuery('input[name="audio_switch"]').prop('checked', false);
        //   jQuery('input[name="audio_switch"]').closest('.toggle').removeClass("checked");
        // }
      }




      //ベンチのバッテリー残量
      //ex) WIFIUSE,1
      if ( words[0].match('BATTERY') ){
        jQuery('#product_battery').text( words[1] );
      }

      //ベンチの着席情報
      //ex）HUMAN,R:0,L:0
      if ( words[0].match('HUMAN') ){
        human_right_count = words[1].split(':')[1];
        human_left_count = words[2].split(':')[1];
        human_count = 'R:' + human_right_count + 'L:' + human_left_count;
        jQuery('#product_human_count').text( human_count );
      }

      //ベンチの充電機器
      //ex）AC1,ON
      //ex）AC2,OFF
      if ( words[0].match('AC1') ){
        //第2引数の文字列の後に別の文字列が残っているため、正規表現で分岐
          if( words[1].match(/ON/) && ac1_count != 1 ){
            ac1_count++;
          }else if( words[1].match(/OFF/) && ac1_count != 0 ){
            ac1_count--;
          }
      }
      if ( words[0].match('AC2') ){
        //第2引数の文字列の後に別の文字列が残っているため、正規表現で分岐
          if( words[1].match(/ON/) && ac2_count != 1 ){
            ac2_count++;
          }else if( words[1].match(/OFF/) && ac2_count != 0 ){
            ac2_count--;
          }
      }
      ac_count = ac1_count + ac2_count;
      jQuery('#product_ac_count').text( ac_count );

      //WiFiの接続台数
      //ex) WIFIUSE,1
      if ( words[0].match('WIFIUSE') ){
        jQuery('#product_wifi_count').text( words[1] );
      }
});
});
