//ショートカットメニュー
//ショートカット設定の流れ　ベンチを指定 -> トリガーを設定 -> 結果を設定

//送られてくるdataをもとに、triggersとhtml.erbのclass="trigger_options"の並び順を合わせる
const triggers = [
    'バッテリー残量が〇〇Vになったら',
    '基盤温度が〇〇℃になったら',
    '冷却ファンがON(OFF)になったら',
    '液晶ディスプレイがON(OFF)になったら',
    'Smart Benchの位置（緯度、経度）が〇〇になったら',
    'LEDがON(OFF)になったら',
    'LEDのRGBが〇〇になったら',
    '着席している人の数が〇〇人になったら',
    'スピーカーがON(OFF)になったら',
    'MP3が再生中(停止中)だったら',
    'MP4が再生中(停止中)だったら',
    'USB用5V電源供給許可がON(OFF)だったら',
    'フリーWiFi接続人数が〇〇人になったら',
    '装置の状態が正常（エラー状態）だったら',
    '外気温が〇〇℃になったら',
    '湿度が〇〇%RHになったら',
    '照度が〇〇LXになったら',
    '気圧が〇〇hPaになったら',
    'ノイズが〇〇dBになったら',
    '揮発性有機化合物濃度が〇〇ppmCになったら',
    'CO2濃度が〇〇ppmになったら',
    '不快指数が〇〇になったら',
    '熱中症警戒度が〇〇になったら',
];

const trigger_labels = {
    "BATTERY":"バッテリー残量",
    "TEMPERATURE":"基盤温度",
    "FAN":"冷却ファン",
    "DISPLAY":"液晶ディスプレイ",
    "POSITION":"Smart Benchの位置（緯度、経度）",
    "LED":"LED",
    "COLOR":"LEDのRGB",
    "HUMAN":"着席している人の数",
    "AUDIO":"スピーカー",
    "MP3":"MP3",
    "MP4":"MP4",
    "USB5V":"USB用5V電源供給許可",
    "WIFIUSE":"フリーWiFi接続人数",
    "MESSAGE":"装置",
    "GTEMPERATURE":"外気温",
    "HUMIDITY":"湿度",
    "LIGHT":"照度",
    "PRESS":"気圧",
    "NOISE":"ノイズ",
    "ETVOC":"揮発性有機化合物濃度",
    "CO2":"CO2濃度",
    "DISCOMFORT":"不快指数",
    "HEAT":"熱中症警戒度"
};

//＜トリガーに指定できるもの一覧＞
// ①送られてくるデータから判断
//     BATTERY,xxx.xxx（バッテリー残量（V））
//     TEMPERATURE,xx.xx（温度（℃））
//     FAN,ON or OFF（冷却ファンのON/OFF状態）
//     DISPLAY,ON or OFF（液晶ディスプレイのON/OFF状態）
//     POSITION,LAT:xxx.xx,LON:xxx.xx（Smart Benchの位置（緯度、経度））
//     LED,ON or OFF（イベントLEDのON/OFF状態）
//     COLOR,R:xxx,G:xxx,B:xxx（イベントLEDのRGB（各0～255））
//     HUMAN,R:x,L:y（着席している人の数（右,左））
//     AUDIO,ON or OFF（スピーカーのON/OFF状態）
//     MP3,ON or OFF（MP3の再生中/停止中）
//     MP4,ON or OFF（MP4の再生中/停止中）
//     USB5V,ON or OFF（USB用5V電源供給許可ON/OFF状態）
//     WIFIUSE,xx（フリーWiFi接続人数（人））
//     MESSAGE,xxxxxxx（本装置のエラー状態（正常時は、none））
//     GTEMPERATURE,xxx（外気温（℃））
//     HUMIDITY,xxx（湿度（%RH））
//     LIGHT,xxx（照度（LX））
//     PRESS,xxx（気圧（hPa））
//     NOISE,xxx（ノイズ（dB））
//     ETVOC,xxx（揮発性有機化合物濃度（ppmC））
//     CO2,xxx（CO2濃度（ppm））
//     DISCOMFORT,xxx（不快指数）
//     HEAT,xxx（熱中症警戒度）
// ②API情報
//     天気が〇〇だったら
// ③タイマー設定
//     〇〇年〇月〇日〇〇時になったら
//     リピート
// ④画像認識の結果から（未実装）
//     人を認識したら、、、
//     犬を認識したら、、、


//アクションのオプションで時間指定（何時から何時まで）
const actions = [
    "LEDの色を変更する",
    "画像を表示する",
    "動画を再生する",
    "音楽を再生する",
    "ボリュームを変更する"
];
const action_commands = {
    "COLOR,R:xxx,G:yyy,B:zzz":"LEDの色を変更する",
    "PDF,ON":"画像を表示する",
    "MP4,ON":"動画を再生する",
    "MP3,ON":"音楽を再生する",
    "VOLUME,xxx":"ボリュームを変更する"
};

const action_commands_keys = Object.keys(action_commands);
const action_commands_values = Object.values(action_commands);

//＜アクションできるコマンド一覧＞
// FAN,ON or OFF
// LED,ON or OFF
// COLOR,R:xxx,G:yyy,B:zzz（xxx:0,yyy:0,zzz:0,でLED OFF）
// それ以外でLED ONします。
// DISPLAY,ON or OFF
// PDF,ON or OFF:xxx
// AUDIO,ON or OFF
// MP3,ON or OFF:xxx
// MP4,ON or OFF:xxx
// USB5V,ON or OFF
// VOLUME,xxx
// POSITION,LAT:xxx,LON:yyy
// LEDONTIME,hh:mm-hh:mm,status
// LEDCANCEL
// SYSTEMDOWN
// LOG,ON or OFF


//データの取得
let data_list = [];
let data = document.getElementsByClassName('data');
for(let i = 0; i < data.length; i++){
    d = JSON.parse(data[i].textContent.replaceAll('=>', ':'));
    data_list.push(d);
}
console.log(data_list);
const data_keys = Object.keys(data_list[0]);
console.log(data_keys);

// 表示する数（デフォルト値）
const view_value = 4;
const product_set = document.getElementById('product_set');
const trigger_set = document.getElementById('trigger_set');
const action_set = document.getElementById('action_set');
const options = document.getElementsByClassName('options');
const trigger_none = document.getElementById('trigger_none');
const action_none = document.getElementById('action_none');
const sc_choice = document.getElementsByClassName('sc_choice');
const save_btn = document.getElementById('save_btn');

const symbols = document.getElementsByClassName('symbols');

const start_times = document.getElementsByClassName('time_setting')[0].querySelectorAll('select');
const end_times = document.getElementsByClassName('time_setting')[1].querySelectorAll('select');

//ショートカットモデル登録用のhiddenフォームのvalue作成用
const shortcut_title = document.getElementById('shortcut_title');
const shortcut_program = document.getElementById('shortcut_program');

//トリガーの方はAND,ORの関係で順序が厳格、アクションの方はSTARTとENDに分ける
let shortcut = {"PRODUCT1": "", "TRIGGERS": {}, "PRODUCT2": "", "ACTIONS": {"START":[], "END":[]}};
// let shortcut = {"PRODUCT1": "", "TRIGGERS": {}, "PRODUCT2": "", "ACTIONS":[]};
//イメージ
// shortcut["PRODUCT1"]:"e45f01422d6b"
// shortcut["TRIGGERS"]:["or,DISCOMFORT,50<80", "and,AUDIO,OFF"] (例)"演算子, 受信コマンド, 数値"　※(A and B) or C みたいなことはできないので順番を守る
// shortcut["PRODUCT2"]:"e45f01422d6b"
// shortcut["ACTIONS"]:{"START":["MP4,ON:xxx.pdf"],"END":["MP4,ON:xxx.pdf"]}

// サイドバーのトリガーの項目を3つ複製して４つにする
let $trigger_views = document.getElementsByClassName('trigger');
for(let i = 0; i < view_value-1; i++){
	let triggerClone = $trigger_views[i].cloneNode(true);
	$trigger_views[i].after(triggerClone);
}
// サイドバーのトリガーの項目を残りのトリガー数分、複製する
let $trigger_more_views = document.getElementsByClassName('trigger_more');
for(let i = 0; i < triggers.length-view_value-1; i++){
	let triggerMoreClone = $trigger_more_views[i].cloneNode(true);
	$trigger_more_views[i].after(triggerMoreClone);
}
// トリガー名書き込み、ボタン有効化
const trigger_title = document.getElementsByClassName('trigger_title');
for(let i = 0; i < triggers.length; i++){
    document.getElementsByClassName('trigger_title')[i].querySelector('.sidebar_sc_txt').textContent = triggers[i];
    // trigger_title[i].addEventListener('click', function() {
	// 	trigger_set.textContent = triggers[i];
    //     trigger_none.style.display = 'none';
    //     options[0].style.display = 'block';
	// });
}

// サイドバーのアクションの項目を3つ複製して４つにする
let $action_views = document.getElementsByClassName('action');
for(let i = 0; i < view_value-1; i++){
	let actionClone = $action_views[i].cloneNode(true);
	$action_views[i].after(actionClone);
}
// サイドバーのアクションの項目を残りのアクション数分、複製する
let $action_more_views = document.getElementsByClassName('action_more');
for(let i = 0; i < actions.length-view_value-1; i++){
	let actionMoreClone = $action_more_views[i].cloneNode(true);
	$action_more_views[i].after(actionMoreClone);
}
// アクション名書き込み、ボタン有効化
const action_title = document.getElementsByClassName('action_title');
for(let i = 0; i < actions.length; i++){
    document.getElementsByClassName('action_title')[i].querySelector('.sidebar_sc_txt').textContent = actions[i];
    action_title[i].addEventListener('click', function() {
		action_set.textContent = actions[i];
	});
}

//トリガーをセレクトボタンに反映
const triggers_select = document.getElementById('triggers_select');
for(let i = 0; i < triggers.length; i++){
    let option = document.createElement('option');
    option.textContent = triggers[i];
    option.value = i;
    triggers_select.appendChild(option);
}

//アクションをセレクトボタンに反映
const actions_select = document.getElementById('actions_select');
for(let i = 0; i < actions.length; i++){
    let option = document.createElement('option');
    option.textContent = actions[i];
    option.value = i;
    actions_select.appendChild(option);
}


////////////////////////////////////
//表示＆ショートカット登録

//プロダクト、トリガー、アクションが設定されたら画像変更
const choice_status = document.getElementsByClassName('choice_status');

//トリガーのプロダクトを選択すると表示する
const products_select = document.getElementById('products_select');
products_select.addEventListener('change', function(e) {
    trigger_set.textContent = e.target.value;
    confirmShortcut();
    shortcut["PRODUCT1"] = e.target.value;
});

//トリガーを選択すると表示する
const trigger_options = document.getElementsByClassName('trigger_options');
triggers_select.addEventListener('change', function(e) {
    if(e.target.value != ''){
        trigger_options[e.target.value].style.display = 'block';
        trigger_set.textContent = products_select[0].value;
        trigger_set.textContent += 'の' + triggers[e.target.value] + '、';
        choice_status[0].src = '/ctrlpanel/icon_shortcut_check.svg';
        shortcut["TRIGGERS"][data_keys[e.target.value]] = ["and","","","",""];
        confirmShortcut();
    }
});

//アクションのプロダクトを選択すると表示する
const action_products_select = document.getElementById('action_products_select');
action_products_select.addEventListener('change', function(e) {
    action_set.textContent = e.target.value;
    confirmShortcut();
    shortcut["PRODUCT2"] = e.target.value;
});

//アクションを選択すると表示する
const action_options = document.getElementsByClassName('action_options');
actions_select.addEventListener('change', function(e) {
    if(e.target.value != ''){
        action_options[e.target.value].style.display = 'block';
        action_set.textContent = action_products_select[0].value;
        action_set.textContent += 'の' + actions[e.target.value];
        choice_status[1].src = '/ctrlpanel/icon_shortcut_check.svg';
        shortcut["ACTIONS"]["START"].push(action_commands_keys[e.target.value]);
        // shortcut["ACTIONS"]["END"]の設定を["START"]のデータから行う
        if(action_commands_keys[e.target.value] == "COLOR,R:xxx,G:yyy,B:zzz"){
            shortcut["ACTIONS"]["END"].push("LED,OFF");
        } else if(action_commands_keys[e.target.value] == "PDF,ON"){
            shortcut["ACTIONS"]["END"].push("PDF,OFF");
        } else if(action_commands_keys[e.target.value] == "MP4,ON"){
            shortcut["ACTIONS"]["END"].push("MP4,OFF");
        } else if(action_commands_keys[e.target.value] == "MP3,ON"){
            shortcut["ACTIONS"]["END"].push("MP3,OFF");
        }
    }
    confirmShortcut();
});

//時間を設定する
let time = {"START":["","","","",""], "END":["","","","",""], "REPEAT":""};
//初期化
for(let i = 0; i < start_times.length; i++){
    time["START"][i] = start_times[i].value;
    time["END"][i] = end_times[i].value;
}
//リピート
let repeat = document.getElementById('repeat');
repeat.addEventListener('change', function(e) {
    time["REPEAT"] = e.target.value;
    confirmShortcut();
});

//時間を変更するとショートカットのビューに表示する
for(let i = 0; i < start_times.length; i++){
    start_times[i].addEventListener('change', function(e) {
        if(e.target.id.includes('1')){
            time["START"][0] = e.target.value;
        }else if(e.target.id.includes('2')){
            time["START"][1] = e.target.value;
        }else if(e.target.id.includes('3')){
            time["START"][2] = e.target.value;
        }else if(e.target.id.includes('4')){
            time["START"][3] = e.target.value;
        }else if(e.target.id.includes('5')){
            time["START"][4] = e.target.value;
        }
        confirmShortcut();
	});
    end_times[i].addEventListener('change', function(e) {
        if(e.target.id.includes('1')){
            time["END"][0] = e.target.value;
        }else if(e.target.id.includes('2')){
            time["END"][1] = e.target.value;
        }else if(e.target.id.includes('3')){
            time["END"][2] = e.target.value;
        }else if(e.target.id.includes('4')){
            time["END"][3] = e.target.value;
        }else if(e.target.id.includes('5')){
            time["END"][4] = e.target.value;
        }
        confirmShortcut();
	});
}

//トリガーとアクションのプロダクトをデフォルト状態に設定
shortcut["PRODUCT1"] = products_select.value;
shortcut["PRODUCT2"] = action_products_select.value;

//andボタン、orボタン
const and_btn = document.getElementsByClassName('and_btn');
const or_btn = document.getElementsByClassName('or_btn');
for(let i = 0; i < and_btn.length; i++){
    and_btn[i].addEventListener('click', function(e) {
        or_btn[i].style.background = '#fff';
        or_btn[i].style.color = '#46C541';
        e.target.style.background = '#46C541';
        e.target.style.color = '#fff';
        shortcut["TRIGGERS"][data_keys[i]][0] = "and";
        confirmShortcut();
        // console.log('and');
	});
    or_btn[i].addEventListener('click', function(e) {
        and_btn[i].style.background = '#fff';
        and_btn[i].style.color = '#46C541';
        e.target.style.background = '#46C541';
        e.target.style.color = '#fff';
        shortcut["TRIGGERS"][data_keys[i]][0] = "or";
        confirmShortcut();
        // console.log('or');
	});
}

// トリガーのキャンセルボタン有効化
const trigger_cancel = document.getElementsByClassName('trigger_cancel');
for(let i = 0; i < trigger_cancel.length; i++){
    trigger_cancel[i].addEventListener('click', function() {
		trigger_options[i].style.display = 'none';
        triggers_select.selectedIndex = -1;
	});
}

// アクションのキャンセルボタン有効化
const action_cancel = document.getElementsByClassName('action_cancel');
for(let i = 0; i < action_cancel.length; i++){
    action_cancel[i].addEventListener('click', function() {
		action_options[i].style.display = 'none';
        actions_select.selectedIndex = -1;
        console.log(action_commands_keys[i]);
        if(shortcut["ACTIONS"]["START"].includes(action_commands_keys[i])){
            let index_base = [].slice.call(shortcut["ACTIONS"]["START"]);
            index = index_base.indexOf(action_commands_keys[i]);
            shortcut["ACTIONS"]["START"].splice(index, 1);
            shortcut["ACTIONS"]["END"].splice(index, 1);
        }
	});
}

//数値のインプットを取得
const choice_num = document.getElementsByClassName('choice_num');
for(let i = 0; i < choice_num.length; i++){
    choice_num[i].addEventListener('change', function(e) {
        let index_base = [].slice.call(trigger_options);
        index = index_base.indexOf(e.target.parentNode);
        if(e.target.className.includes('num1')){
            shortcut["TRIGGERS"][data_keys[index]][1] = e.target.value;
        } else if(e.target.className.includes('num2')){
            shortcut["TRIGGERS"][data_keys[index]][3] = e.target.value;
        }
        // console.log(shortcut["TRIGGERS"][data_keys[index]]);
        confirmShortcut();
	});
}

//以上以下のインプットを取得
const above_below = document.getElementsByClassName('above_below');
for(let i = 0; i < above_below.length; i++){
    above_below[i].addEventListener('change', function(e) {
        let index_base = [].slice.call(trigger_options);
        index = index_base.indexOf(e.target.parentNode.parentNode);
        if(e.target.className.includes('option1') && e.target.value != ''){
            shortcut["TRIGGERS"][data_keys[index]][2] = e.target.value;
        } else if(e.target.className.includes('option2') && e.target.value != ''){
            shortcut["TRIGGERS"][data_keys[index]][4] = e.target.value;
        }
        confirmShortcut();
	});
}


////////////////////////////////////

function confirmShortcut(){
    //初期化
    sc_choice[0].textContent = 'ベンチAで';
    sc_choice[1].textContent = '△△の状態なら、';
    sc_choice[2].textContent = '□時から';
    sc_choice[3].textContent = '×時まで';
    sc_choice[4].textContent = 'ベンチBで';
    sc_choice[5].textContent = '〇〇を実行する';
    ///

    let keys = Object.keys(shortcut["TRIGGERS"]);
    let values = Object.values(shortcut["TRIGGERS"]);
    let trigger_text = '';
    for(let i = 0; i < values.length; i++){
        if(values[i].includes('and')){
            trigger_text += ' かつ、'
        } else if(values[i].includes('or')){
            trigger_text += ' または、'
        }
        trigger_text += trigger_labels[keys[i]] + 'が'
        for(let j = 0; j < values[i].length; j++){
            trigger_text += values[i][j];
        }

        if(values[i][1] == "" && values[i][3] == ""){
            sc_choice[1].style.color = '#eb7457';
        } else {
            sc_choice[1].style.color = '#000000';
        }
    }
    trigger_text = trigger_text.replaceAll('and', '').replaceAll('or', '');
    trigger_text = trigger_text.substr(trigger_text.indexOf('、') + 1);

    console.log(trigger_text);

    sc_choice[0].textContent = 'ベンチ: ' + shortcut["PRODUCT1"] + ' で';
    if(trigger_text != ""){sc_choice[1].textContent = trigger_text + ' なら、';}
    if(time["REPEAT"] == "1"){
        sc_choice[2].textContent = '毎日、' + time["START"][3] + ':' + time["START"][4] + 'から';
        sc_choice[3].textContent = time["END"][3] + ':' + time["END"][4] + 'まで';
    } else {
        sc_choice[2].textContent = time["START"][0] + '/' + time["START"][1] + '/' + time["START"][2] + ' の ' + time["START"][3] + ':' + time["START"][4] + ' から';
        sc_choice[3].textContent = time["END"][0] + '/' + time["END"][1] + '/' + time["END"][2] + ' の ' + time["END"][3] + ':' + time["END"][4] + ' まで';
    }
    sc_choice[4].textContent =  'ベンチ: ' + shortcut["PRODUCT2"] + ' で';
    if(shortcut["ACTIONS"]["START"] != ""){sc_choice[5].textContent = action_commands[shortcut["ACTIONS"]["START"]];}
    console.log(shortcut);
    shortcut_title.value = trigger_text;
    shortcut_program.value = JSON.stringify(shortcut);
}

// contact_submit.removeAttribute("disabled");
// contact_submit.setAttribute("disabled", true);



// //人気のショートカットボタンを有効化
// const popular_items = document.getElementsByClassName('shortcut_popular_item');
// //音楽
// popular_items[0].addEventListener('click', function() {
//     action_options[3].style.display = 'block'; 
// });
// //画像
// popular_items[1].addEventListener('click', function() {
//     action_options[2].style.display = 'block'; 
// });
// //動画
// popular_items[2].addEventListener('click', function() {
//     action_options[1].style.display = 'block';
// });
// //LED
// popular_items[3].addEventListener('click', function() {
//     action_options[0].style.display = 'block';
// });
// //スクロール移動
// let $target = document.getElementById('scroll_point');
// for(let i = 0; i < popular_items.length; i++){
//     popular_items[i].addEventListener('click', function() {
//         $target.scrollIntoView({
//             behavior: "smooth",
//             block: "start",
//             inline: "center"
//         });
//     });
// }



//とりあえずBATTERYだけ

//受信データを受けたら、非同期でコントローラーにajaxPOST -> タイマー指定ありならスケジュール作成、タイマー指定なしならすぐにsocket_message
//そのへんの判断はSTARTとTIMEが設定されているかで判断？



//コマンド送信メソッド（すぐにベンチに命令を送る（タイマー設定がない場合））
function postCommand(command, mac_adrs){;
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

//コマンド予約メソッド（コントローラーに命令予約をさせる（タイマー設定がある場合））
function setSchedule(command, mac_adrs){;
    let request_cmd =  command + ',MAC,' + mac_adrs;
    console.log('コマンド: ' + request_cmd + '（' + '00:00から00:00' + '） をMACアドレス: ' + mac_adrs + ' のベンチに予約');
	$.ajax({
		url: '/schedule/create',
		type: 'GET',
		dataType: 'text',
		async: true,
		data: {
			cmd: request_cmd
		},
	});
}


//判断メソッド　①ショートカットモデルのショートカットをif文に変換して通ったらPOSTデータ
let dummy = {"BATTERY":['and', '23', '以上', '44', '以下'],"TEMPERATURE":['and', '23', '以上', '44', '以下'],"GTEMPERATURE":['or', '23', '以上', '44', '以下']};
//登録時にORを最初にしないよう配慮する
//登録時に最後にORが来るように配慮する
let dummy_json = {"BATTERY": 24, "TEMPERATURE":35, "GTEMPERATURE": 36};
const symbols_json = {
    "以上":">=",
    "以下":"<=",
    "より大きい":">",
    "より小さい":"<",
    "に等しい":"="
};

let dummy_keys = Object.keys(dummy);
let dummy_values = Object.values(dummy);
let dummy_data = "(";

for(let i = 0; i < dummy_keys.length; i++){
    if(dummy_values[i].includes('and')){
        dummy_data += '&&' + dummy_json[dummy_keys[i]] + symbols_json[dummy_values[i][2]] + dummy_values[i][1];
        if(dummy_values[i][3] != ''){
            dummy_data += '&&' + dummy_json[dummy_keys[i]] + symbols_json[dummy_values[i][4]] + dummy_values[i][3];
        }
    } else if(dummy_values[i].includes('or')){
        dummy_data += '||' + dummy_json[dummy_keys[i]] + symbols_json[dummy_values[i][2]] + dummy_values[i][1];
        if(dummy_values[i][3] != ''){
            dummy_data += '&&' + dummy_json[dummy_keys[i]] + symbols_json[dummy_values[i][4]] + dummy_values[i][3];
        }
    }
}
dummy_data += ")";
dummy_data = dummy_data.replace('&&', '');

console.log(dummy_data);

function checkData(script){
    return Function('"use strict";return (' + script + ')')();
}
console.log(checkData(dummy_data));
// if(checkData(dummy_data)){
//     postCommand();
// }

if(dummy_data){
    postCommand('LED,OFF', 'e45f01422d6b');
}

