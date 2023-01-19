//課題
// バグ検証
// タイマーの繰り返し処理 　ctrl+F 繰り返し処理
// 画像、動画、音楽ファイルのファイル制限と、アップロード先
// ボリュームの中途半端な初期値
// 映像ファイルの×ボタン
// 音楽ファイルの×ボタン

// [ベンチへのコマンド]
// FAN,ON or OFF
// LED,ON or OFF
// COLOR,R:xxx,G:yyy,B:zzz
// xxx:0,yyy:0,zzz:0でLED OFF
// それ以外でLED ONします。
// DISPLAY,ON or OFF
// PDF,ON:xxx or OFF xxxにファイル名（要確認）
// AUDIO,ON or OFF
// MP3,ON:xxx or OFF xxxにファイル名（要確認）
// MP4,ON:xxx or OFF xxxにファイル名（要確認）
// USB5V,ON or OFF
// VOLUME,xxx xxxにボリューム指定
// POSITION,LAT:xxx,LON:yyy
// LEDONTIME,hh:mm-hh:mm
// LEDCANCEL
// SYSTEMDOWN
// LOG,ON or OFF


// ボタンのON,OFF切り替え処理
//オンオフ判定変数
let on_or_off = [false, false, false, false, false, false];
let command = ''

//ONボタン　使うときは、引数にONにしたいボタンの番号を入れる
// ※TIMERだけは、Railsのデータベースで管理する
const btn_name = ['LED', 'TIMER', 'DISPLAY', 'AUDIO', 'MP4', 'MP3'];
const btn_num = { 'LED': 0, 'TIMER': 1, 'DISPLAY': 2, 'AUDIO': 3, 'MP4': 4, 'MP3': 5 };
function switchOn(n, command){
    data = document.getElementById('data').textContent;
    data = JSON.parse(data.replaceAll('=>', ':'));
    $('.toggle').eq(n).addClass('checked');
    $('.on').eq(n).css({'display':'block'});
    $('.off').eq(n).css({'display':'none'});
    $('.onoff_switch .off').eq(n).css({'display':'none'});
    on_or_off[n] = true; //ON,OFF判定 ONに
    if(command){
        postData(command);
    }
}

//OFFボタン
function switchOff(n, command){
    data = document.getElementById('data').textContent;
    data = JSON.parse(data.replaceAll('=>', ':'));
    $('.toggle').eq(n).removeClass('checked');
    $('.on').eq(n).css({'display':'none'});
    $('.off').eq(n).css({'display':'block'});
    $('.onoff_switch .on').eq(n).css({'display':'none'});
    on_or_off[n] = false; //ON,OFF判定 OFFに
    if(command){
        postData(command);
    }
}

//リロード時に、ベンチからの最新のJSONデータを取得してViewに表示（hiddenなのでコンソールログから確認）
let data = document.getElementById('data').textContent.replace(/(\\|\/)/g,''); //JSON Parseの処理も関数に
console.log(data);

data = JSON.parse(data.replaceAll('=>', ':'));
for(let i = 0; i < btn_name.length; i++){
    if(data[btn_name[i]].includes('ON')){
        switchOn(i);
    } else {
        switchOff(i);
    }
}

//RailsのコントローラーにAjaxでデータを送信する処理(request_cmdはそのままベンチまで行く)
function postData(command){
    let mac_adrs = data['MAC_ADDRESS']; //MACアドレスをViewで選択
    let request_cmd =  command + ',MAC,' + mac_adrs;
    console.log('コマンド: ' + request_cmd + ' をMACアドレス: ' + mac_adrs + ' のベンチに送信');
	$.ajax({
		url: '/parcom/post_data',
		type: 'GET',
		dataType: 'text',
		async: true,
		data: {
			cmd: request_cmd
		},
	});
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//LEDカラー変更ボタン（変更ボタンを押すとベンチのLEDカラーを変えるコマンドを送る）

//RGBの取得
let rgb_select = '' //現在選択されている色を格納

//プリセットカラーをクリック->取得->スイッチオン(送信)cまで
$('.preset_color').on('click', function(e) {
    rgb_select = e.target.value;
    command = changeColor(rgb_select);
    switchOn(0, command);
});
const colors = document.getElementsByClassName('preset_color');
for(let i = 0; i < colors.length; i++){
    colors[i].addEventListener('change', function(e) {
        rgb_select = e.target.value;
        command = changeColor(rgb_select);
        switchOn(0, command);
    });
}

//カラーコードを入力->取得->スイッチオン(送信)まで
const color_code = document.getElementById('led_color');
color_code.addEventListener('change', function(e) {
    rgb_select = e.target.value;
    command = changeColor(rgb_select);
    if(command){
        switchOn(0, command);
    }
});


//カラーの変換・変更(送信用コマンドを返す)
function changeColor(rgb_select){
    rgb_select = hex2rgb(rgb_select);
    if(rgb_select.includes(NaN)){
        alert('入力されたカラーコードは正しくありません。再入力をお願いします。');
        rgb_select = '';
        return '';
    } else {
        command = 'R:xxx,G:xxx,B:xxx';
        for(let i = 0; i < rgb_select.length; i++){
            command = command.replace('xxx', rgb_select[i]);
        }
        return 'COLOR,' + command;
    }
}

//LEDカラーのON,OFFスイッチ
$('#led_switch').on('click', function() {
    if(on_or_off[0] == true){
        switchOff(0, 'COLOR,R:0,G:0,B:0');
        rgb_select = ''; //RGBの選択 初期化
        color_code.value = '';
    } else if(on_or_off[0] == false && rgb_select != ''){
        command = changeColor(rgb_select);
        if(command != ''){
            switchOn(0, command)
        }
        
    } else {
        alert('プリセットカラーをクリック、またはカラーコードを入力すると自動でONになります。');
    }
});




//カラーコードからRGBに変換する処理
function hex2rgb ( hex ) {
	if ( hex.slice(0, 1) == "#" ) hex = hex.slice(1);
	if ( hex.length == 3 ) hex = hex.slice(0,1) + hex.slice(0,1) + hex.slice(1,2) + hex.slice(1,2) + hex.slice(2,3) + hex.slice(2,3);

	return [ hex.slice(0, 2), hex.slice(2, 4), hex.slice(4, 6) ].map( function (str) {
		return parseInt(str, 16);
	} ) ;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//LEDタイマーのセット  ※リピート処理コマンドに追加

//LEDタイマー
const start_hour = document.getElementById('led_start_time_hour');
const start_min = document.getElementById('led_start_time_min');
const end_hour = document.getElementById('led_end_time_hour');
const end_min = document.getElementById('led_end_time_min');
const led_repeat = document.getElementById('led_repeat');

//LEDタイマー　ON,OFFスイッチ
$('#ledtime_switch').on('click', function() {
    command = start_hour.value + ':' + start_min.value + '-' + end_hour.value + ':' + end_min.value;
    if(on_or_off[1] == true){
        switchOff(1, 'LEDCANCEL');
        start_hour.value = start_min.value = end_hour.value = end_min.value = '00';
        led_repeat.value = '繰り返ししない';
    } else if(on_or_off[1] == false){
        if(led_repeat.value == '1'){ //繰り返し処理のコマンド
            command += ',1';
        } else {
            command += ',0';
        }
        switchOn(1, 'LEDONTIME,' + command);
    }
});


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//画像のアップロード
function setDisplay(){

}

let pdf_default = true; //デフォルト画像あり
if(document.getElementById('preview_image')){
    pdf_default = false;
}

$('#display_switch').on('click', function() {
    if(on_or_off[2] == true){
        switchOff(2, 'DISPLAY,OFF');
        postData('PDF,OFF')
    } else if(on_or_off[2] == false){
        switchOn(2, 'DISPLAY,ON');
        if(pdf_default == false){
            postData('PDF,ON:')
        } else {
            postData('PDF,ON:/ctrlpanel/preview_dummy.svg')
        }
    }
});

const pdf_submit = document.getElementById('pdf_submit');

////////PDF,MP3,MP4で繰り返し、まとめて関数化????
const pdf_file = document.getElementById('pdf_file');
// const sizeLimit = 1024 * 1024 * 1; // 制限サイズ
// changeイベントで呼び出す関数
function handleFileSelect(){
    let file = pdf_file.files[0];
    // let pdf_filename = file.name;
    // let pdf_filesize = file.size;

    // if (file && file.size > sizeLimit) {
    //     // ファイルサイズが制限以上
    //     alert('ファイルサイズは1MB以下にしてください'); // エラーメッセージを表示
    //     pdf_file.value = ''; // inputの中身をリセット
    //     return; // この時点で処理を終了する
    // }
    previewFile(file);
    $('#preview_image').css('visibility', 'visible');
    $('.preview_close_btn').css('visibility', 'visible');
}
// ファイル選択時にhandleFileSelectを発火
pdf_file.addEventListener('change', handleFileSelect);

function previewFile(file) {
    // プレビュー画像を追加する要素
    const preview = document.getElementById('preview');
    // FileReaderオブジェクトを作成
    const reader = new FileReader();
  
    // URLとして読み込まれたときに実行する処理
    reader.onload = function (e) {
        const imageUrl = e.target.result; // URLはevent.target.resultで呼び出せる
        $('#preview_dummy').css('display', 'none');
        $('#preview_image').remove();
        const img = document.createElement("iframe"); // img要素を作成
        img.src = imageUrl; // URLをimg要素にセット
        img.id = 'preview_image';
        preview.appendChild(img); // #previewの中に追加
    }
    // いざファイルをURLとして読み込む
    reader.readAsDataURL(file);
    console.log('PDF,ON:xxxを送信しました。ファイル名の処理はコントローラーで行います。');
    pdf_default = false; //デフォルト画像が消滅
    pdf_submit.click();
    postData('PDF,ON:');
}

$('.preview_close_btn').on('click', function() {
    $('#preview_dummy').css('display', 'none');
    $('#preview_image').remove();
    $('.preview_close_btn').css('visibility', 'hidden');
    pdf_file.value = '';
    postData('PDF,OFF');  //画像表示をやめる(previewと連動)※液晶はついている
});


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//音量の決定   ※ボリュームの初期値500は、ビューの数字としては中途半端???
$('#volume_input').on('click', function(e) {
    //volume ベンチの仕様上、 0(最小値) ~ 100(最大値) を -3000(最小値) ~ 1000(最大値) に変換して送信しないといけない。
    let volume = (e.target.value * 40) - 3000;
    command = 'VOLUME,' + volume;
    postData(command);
    if(on_or_off[3] == false){
        switchOn(3, 'AUDIO,ON');
    }
});

let volume = document.getElementsByClassName('volume')[0];
$('#audio_switch').on('click', function() {
    if(on_or_off[3] == true){
        switchOff(3, 'AUDIO,OFF');
        document.getElementById('volume_input').value = 0;
        volume.style.left = '0%';
        volume.children[1].textContent = '0';
    } else if(on_or_off[3] == false){
        postData('VOLUME,480'); //初期値
        document.getElementById('volume_input').value = 12;
        volume.style.left = '12%';
        volume.children[1].textContent = '12';
        switchOn(3, 'AUDIO,ON');
    }
});

let rangePercent = $('[type="range"]').val();
$('[type="range"]').on('change input', function() {
    rangePercent = $('[type="range"]').val();
    $('.volume p').html(rangePercent+'<span></span>');
    $('.volume').css({'left': rangePercent+'%'});
});



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//動画のアップロード
function setMovie(){

}

let movie_permit = false;
if(document.getElementById('mp4_preview_video')){
    movie_permit = true;
}
const movie_submit = document.getElementById('movie_submit');

$('#mp4_switch').on('click', function() {
    if(on_or_off[4] == true){
        switchOff(4, 'MP4,OFF');
    } else if(on_or_off[4] == false){
        if(movie_permit == false){
            alert('再生するmp4ファイルをアップロードしてから押してください。');
        } else {
            switchOn(4, 'MP4,ON:');
        }
    }
});

const movie_file = document.getElementById('movie_file');
// const sizeLimit = 1024 * 1024 * 1; // 制限サイズ
// changeイベントで呼び出す関数
function handle_mv_FileSelect(){
    let file = movie_file.files[0];
    let movie_filename = file.name;
    let movie_filesize = file.size;
    
    preview_mv_File(file);
    $('#preview_image').css('visibility', 'visible');
}
// ファイル選択時にhandleFileSelectを発火
movie_file.addEventListener('change', handle_mv_FileSelect);

function preview_mv_File(file) {
    // プレビュー画像を追加する要素
    const preview = document.getElementsByClassName('preview_file_video')[0];
    // FileReaderオブジェクトを作成
    const reader = new FileReader();
  
    // URLとして読み込まれたときに実行する処理
    reader.onload = function (e) {
      const videoUrl = e.target.result; // URLはevent.target.resultで呼び出せる
      $('#mp4_preview_dummy').css('display', 'none');
      const video = document.createElement("video"); // video要素を作成
      video.src = videoUrl; // URLをvideo要素にセット
      video.id = 'mp4_preview_video';
      preview.appendChild(video); // #previewの中に追加
    }
    // いざファイルをURLとして読み込む
    reader.readAsDataURL(file);
    console.log('MP4,ON:xxxを送信しました。ファイル名の処理はコントローラーで行います。');
    movie_permit = true;
    movie_submit.click();
}



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//音楽のアップロード
function setMusic(){

}
let audio_permit = false;
if(document.getElementById('audio_player')){
    audio_permit = true;
}
const audio_submit = document.getElementById('audio_submit');

$('#mp3_switch').on('click', function() {
    if(on_or_off[5] == true){
        switchOff(5, 'MP3,OFF');
    } else if(on_or_off[5] == false){
        if(audio_permit == false){
            alert('再生するmp3ファイルをアップロードしてから押してください。');
        } else {
            switchOn(5, 'MP3,ON:');
        }
    }
});

const audio_file = document.getElementById('audio_file');
let audio_name = document.getElementById('audio_name');
// const sizeLimit = 1024 * 1024 * 1; // 制限サイズ
// changeイベントで呼び出す関数
function handle_audio_FileSelect(){
    let file = audio_file.files[0];
    let audio_filename = file.name;
    audio_name.value = audio_filename;
    let audio_filesize = file.size;
    preview_audio_File(file);
}
// ファイル選択時にhandleFileSelectを発火
audio_file.addEventListener('change', handle_audio_FileSelect);

let audio_preview = document.getElementById('audio_preview');

function preview_audio_File(file) {
    // FileReaderオブジェクトを作成
    const reader = new FileReader();
    // URLとして読み込まれたときに実行する処理
    reader.onload = function (e) {
        const audioUrl = e.target.result; // URLはevent.target.resultで呼び出せる
        audio_preview.style.visibility = 'visible';
        audio_preview.innerHTML = file.name + '<button type="button" class="delete_cancel_btn">×</button>';
        $('.delete_cancel_btn').on('click', function() {
            audio_preview.style.visibility = 'hidden';
            audio_file.value = '';
        });
    }
    // いざファイルをURLとして読み込む
    reader.readAsDataURL(file);
    console.log('MP3,ON:xxxを送信しました。ファイル名の処理はコントローラーで行います。');
    audio_permit = true;
    audio_submit.click();
}

$('.delete_cancel_btn').on('click', function() {
    audio_preview.style.visibility = 'hidden';
    audio_file.value = '';
});

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////



//ラズパイからのデータの定期更新（毎秒）
function submit(){
    const submitButton = document.getElementById("submitButton");
    submitButton.click();
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// 現在の電圧、現在の着席人数、現在の充電機器、現在の接続台数、通信使用量合計?　の数字描画変更
let battery_num = document.getElementById('product_battery');
let human_num = document.getElementById('product_human_count');
let ac_num = document.getElementById('product_ac_count');
let wifi_num = document.getElementById('product_wifi_count');

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// 各グラフの変数定義
let ctx1 = document.getElementById('battery_chart');
let ctx2 = document.getElementById('human_chart');
let ctx3 = document.getElementById('wifi_chart');
let ctx4 = document.getElementById('data_sum_chart');

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
data1 = [0,0,0,0,0,0,0,0,0,0]
data2 = [0,0,0,0,0,0,0,0,0,0]
data3 = [0,0,0,0,0,0,0,0,0,0]
data4 = [0,0,0,0,0,0,0,0,0,0]


let chart_check = false;
// setInterval(updateData, 1000);
// setInterval(submit, 1000);

function updateData(){
    destroyChart();
    data1.shift();
    data2.shift();
    data3.shift();
    data4.shift();
    let data = document.getElementById('data').textContent.replace(/(\\|\/)/g,'');
    data = JSON.parse(data.replaceAll('=>', ':'));
    data1.push(Number(data['BATTERY']));
    data2.push(Number((data['HUMAN'].split(','))[0].replace('R:','')) + Number((data['HUMAN'].split(','))[1].replace('L:','')));
    data3.push(Number(data['WIFIUSE']));
    data4.push(0);
    battery_num.textContent = (data['BATTERY']);
    human_num.textContent = Number((data['HUMAN'].split(','))[0].replace('R:','')) + Number((data['HUMAN'].split(','))[1].replace('L:',''));
    wifi_num.textContent = (data['WIFIUSE']);
    // 通信使用量合計の処理(SORACOMからもってくる)

    // console.log(data1)
    chart_check = true;

    window.myChart1 = new Chart(ctx1, {
        type: 'line',
        data: {
            labels: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
            datasets: [{
                pointRadius: 0,
                borderWidth: 2,
                label: '',
                data: data1,
                // data: [5.635, 6.635, 8.635, 2.635, 3.635, 7.635, 6.635, 4.635, 5.635, 2.635],
                // データライン
                borderColor: 'rgb(70,197,64)',
                xAxisID: 'x',
                yAxisID: 'y'
            }],
        },
        options: {
            animation: false,
            scales: {  // 軸設定
                x: {  // Ｘ軸設定
                    ticks: {  // 目盛り
                        display: false
                        // min: 0,            // 最小値
                        // max: 25,           // 最大値
                        // stepSize: 5,       // 間隔
                    },
                    grid: {
                        display: false,
                        drawBorder: false
                    }
                },
                y: { // Ｙ軸設定
                    ticks: {  // 目盛り
                        display: false
                    },
                    grid: {  // グリッド線
                        display: false,
                        drawBorder: false
                    }
                }
            },
            plugins: {
                legend: {
                    display: false
                }
            }
        }
    });




    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    window.myChart2 = new Chart(ctx2, {
        type: 'line',
        data: {
            labels: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
            datasets: [{
                pointRadius: 0,
                borderWidth: 2,
                label: '',
                data: data2,
                // data: [1, 2, 0, 2, 2, 2, 1, 1, 1, 0],
                // データライン
                borderColor: 'rgb(70,197,64)',
                xAxisID: 'x',
                yAxisID: 'y'
            }],
        },
        options: {
            animation: false,
            scales: {  // 軸設定
                x: {  // Ｘ軸設定
                    ticks: {  // 目盛り
                        display: false
                        // min: 0,            // 最小値
                        // max: 25,           // 最大値
                        // stepSize: 5,       // 間隔
                    },
                    grid: {
                        display: false,
                        drawBorder: false
                    }
                },
                y: { // Ｙ軸設定
                    ticks: {  // 目盛り
                        display: false
                    },
                    grid: {  // グリッド線
                        display: false,
                        drawBorder: false
                    }
                }
            },
            plugins: {
                legend: {
                    display: false
                }
            }
        }
    });

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    window.myChart3 = new Chart(ctx3, {
        type: 'line',
        data: {
            labels: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
            datasets: [{
                pointRadius: 0,
                borderWidth: 2,
                label: '',
                data: data3,
                // data: [1, 2, 2, 2, 3, 4, 7, 6, 10, 0],
                // データライン
                borderColor: 'rgb(70,197,64)',
                xAxisID: 'x',
                yAxisID: 'y'
            }],
        },
        options: {
            animation: false,
            scales: {  // 軸設定
                x: {  // Ｘ軸設定
                    ticks: {  // 目盛り
                        display: false
                        // min: 0,            // 最小値
                        // max: 25,           // 最大値
                        // stepSize: 5,       // 間隔
                    },
                    grid: {
                        display: false,
                        drawBorder: false
                    }
                },
                y: { // Ｙ軸設定
                    ticks: {  // 目盛り
                        display: false
                    },
                    grid: {  // グリッド線
                        display: false,
                        drawBorder: false
                    }
                }
            },
            plugins: {
                legend: {
                    display: false
                }
            }
        }
    });

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    window.myChart4 = new Chart(ctx4, {
        type: 'line',
        data: {
            labels: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
            datasets: [{
                pointRadius: 0,
                borderWidth: 2,
                label: '',
                data: data4,
                // data: [40, 35, 40, 30, 45, 35, 40, 30, 45, 35],
                // データライン
                borderColor: 'rgb(70,197,64)',
                xAxisID: 'x',
                yAxisID: 'y'
            }],
        },
        options: {
            animation: false,
            scales: {  // 軸設定
                x: {  // Ｘ軸設定
                    ticks: {  // 目盛り
                        display: false
                        // min: 0,            // 最小値
                        // max: 25,           // 最大値
                        // stepSize: 5,       // 間隔
                    },
                    grid: {
                        display: false,
                        drawBorder: false
                    }
                },
                y: { // Ｙ軸設定
                    ticks: {  // 目盛り
                        display: false
                    },
                    grid: {  // グリッド線
                        display: false,
                        drawBorder: false
                    }
                }
            },
            plugins: {
                legend: {
                    display: false
                }
            }
        }
    });
}

updateData();

function destroyChart(){
    if (chart_check) {
        myChart1.destroy();
        myChart2.destroy();
        myChart3.destroy();
        myChart4.destroy();
        //chart1_check = false;
    }
}



let temperature = document.getElementsByClassName('temperature')[0].children[0];
temperature.textContent = Math.round(data['GTEMPERATURE']);