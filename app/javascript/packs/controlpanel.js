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
let command = '';

//ONボタン　使うときは、引数にONにしたいボタンの番号を入れる
const btn_name = ['LED', 'DISPLAY', 'AUDIO', 'MP4', 'MP3', 'CAMERA'];
const btn_num = { 'LED': 0, 'DISPLAY': 1, 'AUDIO': 2, 'MP4': 3, 'MP3': 4, 'CAMERA': 5 };
function switchOn(n, command){
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
data = document.getElementById('data').textContent.replace(/(\\|\/)/g,''); //JSON Parseの処理も関数に
data = JSON.parse(data.replaceAll('=>', ':'));
data["CAMERA"] = "ON";
for(let i = 0; i < btn_name.length; i++){
    if(data[btn_name[i]].includes('ON')){
        switchOn(i);
    } else {
        switchOff(i);
    }
}
console.log(data);


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
let rgb_select = ''; //現在選択されている色を格納

//プリセットカラーをクリック->取得->スイッチオン(送信)cまで
$('.preset_color').on('click', function(e) {
    rgb_select = e.target.value;
    command = changeColor(rgb_select);
    color_code.value = rgb_select;
    switchOn(0, command);
    led_off_counter = 0;
});
const colors = document.getElementsByClassName('preset_color');
for(let i = 0; i < colors.length; i++){
    colors[i].addEventListener('change', function(e) {
        rgb_select = e.target.value;
        command = changeColor(rgb_select);
        color_code.value = rgb_select;
        switchOn(0, command);
        led_off_counter = 0;
    });
}

//カラーコードを入力->取得->スイッチオン(送信)まで
const color_code = document.getElementById('led_color');
color_code.addEventListener('change', function(e) {
    rgb_select = e.target.value;
    command = changeColor(rgb_select);
    if(command){
        switchOn(0, command);
        led_off_counter = 0;
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
        switchOff(0, 'LED,OFF');
        led_on_counter = 0;
        rgb_select = ''; //RGBの選択 初期化
        color_code.value = '';
    } else if(on_or_off[0] == false && rgb_select != ''){
        command = changeColor(rgb_select);
        if(command != ''){
            switchOn(0, command);
            led_off_counter = 0;
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

//画像のアップロード
let pdf_permit = false;
if(document.getElementById('preview_image')){
    pdf_permit = true;
}

$('#display_switch').on('click', function() {
    if(on_or_off[1] == true){
        switchOff(1, 'PDF,OFF');
    } else if(on_or_off[1] == false){
        if(pdf_permit == false){
            alert('再生する画像ファイルをアップロードしてから押してください。');
        } else {
            switchOn(1, 'PDF,ON:');
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
    let pdf_filename = file.name;
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
        const img = document.createElement("img"); // img要素を作成
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
});


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//音量の決定
$('#volume_input').on('click', function(e) {
    //volume ベンチの仕様上、 0(最小値) ~ 100(最大値) を -1000(最小値) ~ 900(最大値) に変換して送信しないといけない。
    let volume = (e.target.value * 19) - 1000;
    command = 'VOLUME,' + volume;
    if(on_or_off[2] == true){
        if(volume == -1000){
            switchOff(2, command);
        } else {
            switchOn(2, command);
        }
    }
});

//音量初期値をビュー表示
let default_volume = '80';
let volume = document.getElementsByClassName('volume')[0];
document.getElementById('volume_input').value = default_volume;
volume.style.left = default_volume + '%';
volume.children[1].textContent = default_volume;
switchOn(2);

$('#audio_switch').on('click', function() {
    if(on_or_off[2] == true){
        switchOff(2, 'AUDIO,OFF');
        document.getElementById('volume_input').value = 0;
        volume.style.left = '0%';
        volume.children[1].textContent = '0';
    } else if(on_or_off[2] == false){
        let volume_value = document.getElementById('volume_input').value;
        switchOn(2, 'VOLUME,' + ((volume_value * 19) - 1000));
        volume.style.left = volume_value + '%';
        volume.children[1].textContent = volume_value;
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
let movie_permit = false;
if(document.getElementById('mp4_preview_video')){
    movie_permit = true;
}
const movie_submit = document.getElementById('movie_submit');

$('#mp4_switch').on('click', function() {
    if(on_or_off[3] == true){
        switchOff(3, 'MP4,OFF');
        audio_lock.style.display = 'none';
        //連動して音量もオフにする(値はそのまま)
        switchOff(2);
    } else if(on_or_off[3] == false){
        if(movie_permit == false){
            alert('再生するmp4ファイルをアップロードしてから押してください。');
        } else {
            switchOn(3, 'MP4,ON:');
            audio_lock.style.display = 'inline';
            //連動して音量もオンにする
            switchOn(2);
            if(document.getElementById('volume_input').value == 0){
                document.getElementById('volume_input').value = default_volume;
                volume.style.left = default_volume + '%';
                volume.children[1].textContent = default_volume;
            }
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
    $('#mp4_preview_video').css('visibility', 'visible');
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
      $('#mp4_preview_video').remove();
      const video = document.createElement("video"); // video要素を作成
      video.src = videoUrl; // URLをvideo要素にセット
      video.id = 'mp4_preview_dummy';
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

//再生したらボリュームはロック
let audio_lock = document.getElementById('audio_lock');

let audio_permit = false;
if(document.getElementById('audio_player')){
    audio_permit = true;
}
const audio_submit = document.getElementById('audio_submit');

$('#mp3_switch').on('click', function() {
    if(on_or_off[4] == true){
        switchOff(4, 'MP3,OFF');
        audio_lock.style.display = 'none';
        //連動して音量もオフにする(値はそのまま)
        switchOff(2);
    } else if(on_or_off[4] == false){
        if(audio_permit == false){
            alert('再生するmp3ファイルをアップロードしてから押してください。');
        } else {
            switchOn(4, 'MP3,ON:');
            audio_lock.style.display = 'inline';
            //連動して音量もオンにする
            switchOn(2);
            if(document.getElementById('volume_input').value == 0){
                document.getElementById('volume_input').value = default_volume;
                volume.style.left = default_volume + '%';
                volume.children[1].textContent = default_volume;
            }
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


//カメラ
$('#camera_switch').on('click', function() {
    if(on_or_off[5] == true){
        switchOff(5, 'CAMERA,OFF');
    } else if(on_or_off[5] == false){
        switchOn(5, 'CAMERA,ON:');
    }
});

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//ラズパイからのデータの定期更新（毎秒）
function submit(){
    const submitButton = document.getElementById("submitButton");
    submitButton.click();
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

let ctx = document.getElementsByClassName('ex_chart');
let myCharts = [];
let chart_num = document.getElementsByClassName('sidebar_cp_item_content');

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
chart_data = [];
for(let i = 0; i < ctx.length; i++){
    chart_data.push([0,0,0,0,0,0,0,0,0,0]);
}


let chart_check = false;
// setInterval(updateData, 1000);
// setInterval(submit, 1000);

function updateData(){
    let data = document.getElementById('data').textContent.replace(/(\\|\/)/g,'');
    data = JSON.parse(data.replaceAll('=>', ':'));

    destroyChart();

    //下記pushed_dataは、HTMLと順番合わせる + グラフ描画の順番も合わせる
    // ベンチのバッテリー残量
    // ベンチの基盤温度
    // ベンチ周辺の外気温
    // ベンチの着席情報
    // Wi-Fi接続台数
    // ベンチ周辺の湿度
    // ベンチ周辺の照度
    // ベンチ周辺の気圧
    // ベンチ周辺のノイズ
    // ベンチ周辺の揮発性有機化合物濃度
    // ベンチ周辺のCO2濃度
    // ベンチ周辺の不快指数
    // ベンチ周辺の熱中症警戒度
    // データ通信使用量
    pushed_data = [
        Number(data["BATTERY"]),
        Number(data["TEMPERATURE"]),
        Number(data["GTEMPERATURE"]),
        Number((data['HUMAN'].split(','))[0].replace('R:','')) + Number((data['HUMAN'].split(','))[1].replace('L:','')),
        Number(data["WIFIUSE"]),
        Number(data["HUMIDITY"]),
        Number(data["LIGHT"]),
        Number(data["PRESS"]),
        Number(data["NOISE"]),
        Number(data["ETVOC"]),
        Number(data["CO2"]),
        Number(data["DISCOMFORT"]),
        Number(data["HEAT"]),
        1 //SORACOMの数値
    ];
    for(let i = 0; i < ctx.length; i++){
        chart_data[i].shift();
        chart_data[i].push(pushed_data[i]);
        chart_num[i].querySelector('span').textContent = pushed_data[i];
    }

    chart_check = true;

    document.getElementById("fan").textContent = "FAN: " + data["FAN"];
    document.getElementById("display").textContent = "DISPLAY: " + data["DISPLAY"];
    document.getElementById("position").textContent = "POSITION: " + data["POSITION"];
    document.getElementById("led").textContent = "LED: " + data["LED"];
    document.getElementById("color").textContent = "COLOR: " + data["COLOR"];
    document.getElementById("audio").textContent = "AUDIO: " + data["AUDIO"];
    document.getElementById("mp3").textContent = "MP3: " + data["MP3"];
    document.getElementById("mp4").textContent = "MP4: " + data["MP4"];
    document.getElementById("usb").textContent = "USB5V: " + data["USB5V"];
    document.getElementById("message").textContent = "MESSAGE: " + data["MESSAGE"];


    ///////////// 以下グラフ描画 ///////////////
    // ベンチのバッテリー残量
    window.myChart1 = new Chart(ctx[0], {
        type: 'line',
        data: {
            labels: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
            datasets: [{
                pointRadius: 0,
                borderWidth: 2,
                label: '',
                data: chart_data[0],
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
    
    // ベンチの基盤温度
    window.myChart2 = new Chart(ctx[1], {
        type: 'line',
        data: {
            labels: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
            datasets: [{
                pointRadius: 0,
                borderWidth: 2,
                label: '',
                data: chart_data[1],
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
    

    // ベンチ周辺の外気温
    window.myChart3 = new Chart(ctx[2], {
        type: 'line',
        data: {
            labels: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
            datasets: [{
                pointRadius: 0,
                borderWidth: 2,
                label: '',
                data: chart_data[2],
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
    
    // ベンチの着席情報
    window.myChart4 = new Chart(ctx[3], {
        type: 'line',
        data: {
            labels: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
            datasets: [{
                pointRadius: 0,
                borderWidth: 2,
                label: '',
                data: chart_data[3],
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
    
    // Wi-Fi接続台数
    window.myChart5 = new Chart(ctx[4], {
        type: 'line',
        data: {
            labels: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
            datasets: [{
                pointRadius: 0,
                borderWidth: 2,
                label: '',
                data: chart_data[4],
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
    
    // ベンチ周辺の湿度
    window.myChart6 = new Chart(ctx[5], {
        type: 'line',
        data: {
            labels: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
            datasets: [{
                pointRadius: 0,
                borderWidth: 2,
                label: '',
                data: chart_data[5],
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
    
    // ベンチ周辺の照度
    window.myChart7 = new Chart(ctx[6], {
        type: 'line',
        data: {
            labels: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
            datasets: [{
                pointRadius: 0,
                borderWidth: 2,
                label: '',
                data: chart_data[6],
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
    
    // ベンチ周辺の気圧
    window.myChart8 = new Chart(ctx[7], {
        type: 'line',
        data: {
            labels: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
            datasets: [{
                pointRadius: 0,
                borderWidth: 2,
                label: '',
                data: chart_data[7],
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
    
    // ベンチ周辺のノイズ
    window.myChart9 = new Chart(ctx[8], {
        type: 'line',
        data: {
            labels: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
            datasets: [{
                pointRadius: 0,
                borderWidth: 2,
                label: '',
                data: chart_data[8],
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
    
    // ベンチ周辺の揮発性有機化合物濃度
    window.myChart10 = new Chart(ctx[9], {
        type: 'line',
        data: {
            labels: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
            datasets: [{
                pointRadius: 0,
                borderWidth: 2,
                label: '',
                data: chart_data[9],
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
    
    // ベンチ周辺のCO2濃度
    window.myChart11 = new Chart(ctx[10], {
        type: 'line',
        data: {
            labels: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
            datasets: [{
                pointRadius: 0,
                borderWidth: 2,
                label: '',
                data: chart_data[10],
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
    
    // ベンチ周辺の不快指数
    window.myChart12 = new Chart(ctx[11], {
        type: 'line',
        data: {
            labels: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
            datasets: [{
                pointRadius: 0,
                borderWidth: 2,
                label: '',
                data: chart_data[11],
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
    
    // ベンチ周辺の熱中症警戒度
    window.myChart13 = new Chart(ctx[12], {
        type: 'line',
        data: {
            labels: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
            datasets: [{
                pointRadius: 0,
                borderWidth: 2,
                label: '',
                data: chart_data[12],
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
    
    // データ通信使用量
    window.myChart14 = new Chart(ctx[13], {
        type: 'line',
        data: {
            labels: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
            datasets: [{
                pointRadius: 0,
                borderWidth: 2,
                label: '',
                data: chart_data[13],
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
        for(let i = 0; i < ctx.length; i++){
            myChart1.destroy();
            myChart2.destroy();
            myChart3.destroy();
            myChart4.destroy();
            myChart5.destroy();
            myChart6.destroy();
            myChart7.destroy();
            myChart8.destroy();
            myChart9.destroy();
            myChart10.destroy();
            myChart11.destroy();
            myChart12.destroy();
            myChart13.destroy();
            myChart14.destroy();
        }
    }
}

let temperature = document.getElementsByClassName('temperature')[0].children[0];
temperature.textContent = Math.round(data['GTEMPERATURE']);