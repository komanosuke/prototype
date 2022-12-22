jQuery(function () {

    function request( val ){
      let data = {
        action : 'request',
        val : val,
      };
      //ajax送信
      jQuery.ajax({
      type: 'POST',
      url: ajaxurl,
      data : data,
      timeout: 10000,
      success: function( response ){
        alert(response);
      },
      error: function (response) {
        //エラー文がある場合は一度削除
        jQuery('.error').remove();
        window.scroll({ top: 0 });
        jQuery('.control_panel_content').prepend(
          '<p class="error">予期せぬエラーが発生しました。ご迷惑をおかけしますが、しばらく経ってから再度試してください。</p>'
        );
      }
      });
    }

    //RGB変換コード
    function hex2rgb(hex){
        if (hex.slice(0, 1) == "#"){
          hex = hex.slice(1);
        }
        if (hex.length == 3) {
          hex = hex.slice(0, 1) + hex.slice(0, 1) + hex.slice(1, 2) + hex.slice(1, 2) + hex.slice(2, 3) + hex.slice(2, 3);
        }
        const r = parseInt("0x" + hex.slice(0, 2));
        const g = parseInt("0x" + hex.slice(2, 4));
        const b = parseInt("0x" + hex.slice(4, 6));
        //（例）'COLOR' => 'R:255,G:0,B:0'
        return "R:" + r + "," + "G:"+ g + "," + "B:" + b;
      };
    //カラーコードかどうか
    function isColor (color) {
      return color.match(/^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/) !== null;
    }
    //LEDカラー
    jQuery(document).on("click", 'input[type="color"]', function (){
      event.preventDefault();
      hex = jQuery(this).val();
      let val = 'COLOR' + '=' + hex2rgb(hex);
      request( val );
    });
    jQuery(document).on("change", 'input[name="led_color"]', function (){
      hex = jQuery(this).val();
      if( isColor(hex) ){
        let val = 'COLOR' + '=' + hex2rgb(hex);
        request( val );
      }
    });
    //LEDスイッチ
    jQuery(document).on("click", "#led_switch", function (){
      event.preventDefault();
      let val;
      if ( jQuery(this).children('input[name="led_switch"]').prop("checked") == true ) {
         val = 'LED=ON';
       } else {
         val = 'LED=OFF';
       }
       request( val );
    });

    //LEDタイマースイッチ
    jQuery(document).on("click", "#ledtime_switch", function (){
      let val;
      if ( jQuery(this).children('input[name="ledtime_switch"]').prop("checked") == true ) {
          let led_start_time_hour = jQuery('select[name="led_start_time_hour"]').val();
          let led_start_time_min = jQuery('select[name="led_start_time_min"]').val();
          let led_end_time_hour = jQuery('select[name="led_end_time_hour"]').val();
          let led_end_time_min = jQuery('select[name="led_end_time_min"]').val();
         val = 'LEDTIME' + '=' + led_start_time_hour + ':' + led_start_time_min + '-' + led_end_time_hour + ':' + led_end_time_min;
       } else {
         val = 'LEDTIMECANCEL';
       }
       request( val );
    });
    //タイマーの時刻が変更になった場合に現在ONになっていれば一度LEDタイマーを解除する
    jQuery(document).on("change", 'select[name="led_start_time_hour"] , select[name="led_start_time_min"] , select[name="led_end_time_hour"] , select[name="led_end_time_min"]', function (){
      if ( jQuery('input[name="ledtime_switch"]').prop("checked") == true ) {
      request( 'LEDTIMECANCEL' );
      }
    });

    //画像
    jQuery(document).on("click", "#pdf_switch", function (){
      let val;
      if ( jQuery(this).children('input[name="pdf_switch"]').prop("checked") == true ) {
        //モニターがONになっていなければ先に送信
         val = 'PDF=ON:http://app.parcom.jp/sample/bench.pdf';
       } else {
         //モニターがONになっていれば先に送信
         val = 'PDF=OFF';
       }
       request( val );
    });

    //MP4
    jQuery(document).on("click", "#mp4_switch", function (){
      let val;
      if ( jQuery(this).children('input[name="mp4_switch"]').prop("checked") == true ) {
        //モニターがONになっていなければ先に送信
         val = 'MP4=ON:http://app.parcom.jp/sample/sample.mp4';
       } else {
         //モニターがONになっていれば先に送信
         val = 'MP4=OFF';
        // request('DISPLAY=OFF');
       }
       request( val );
    });


    //MP3
    jQuery(document).on("click", "#mp3_switch", function (){
      let val;
      if ( jQuery(this).children('input[name="mp3_switch"]').prop("checked") == true ) {
         val = 'MP3=ON:http://app.parcom.jp//sample/sample.mp3';
       } else {
         val = 'MP3=OFF';
       }
       request( val );
    });



    //音量

    jQuery(document).on("change", "input[type='range']", function (){
      let val = 'VOLUME' + '=' + Number( jQuery(this).val() ) * 10;
      request( val );
    });
    jQuery(document).on("click", "#audio_switch", function (){
      let val;
      if ( jQuery(this).children('input[name="audio_switch"]').prop("checked") == true ) {
         val = 'AUDIO=ON';
       } else {
         val = 'AUDIO=OFF';
       }
       request( val );
    });

});
