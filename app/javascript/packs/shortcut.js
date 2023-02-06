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
// ②API情報（未実装）
//     天気が〇〇だったら
// ③画像認識の結果から（未実装）
//     人を認識したら、、、
//     犬を認識したら、、、


//アクションのオプションで時間指定（何時から何時まで）
const actions = [
    "LEDの色を変更する",
    "画像を表示する",
    "動画を再生する",
    "音楽を再生する"
];
const action_commands = {
    "COLOR,R:xxx,G:yyy,B:zzz":"LEDの色を変更する",
    "PDF,ON":"画像を表示する",
    "MP4,ON":"動画を再生する",
    "MP3,ON":"音楽を再生する"
};
// 上記action_commandsのキーだけの配列
const action_commands_keys = Object.keys(action_commands);

//＜アクションできるコマンド一覧＞
// ①オプション：タイマー設定
//     〇〇年〇月〇日〇〇時〇〇分から〇〇年〇月〇日〇〇時〇〇分まで
// ②オプション：リピート
// FAN,ON or OFF
// LED,ON or OFF
// COLOR,R:xxx,G:yyy,B:zzz（xxx:0,yyy:0,zzz:0,でLED OFF）それ以外でLED ONします。
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
save_btn.setAttribute("disabled", true);
save_btn.style.backgroundColor = '#E2E7F0';
save_btn.style.color = '#415964';
save_btn.style.cursor = 'auto';
// const save_filter = document.getElementById('save_filter');
// save_filter.addEventListener('click', function(e) {
//     alert('ショートカットを完成させてから押してください。');
// });


const symbols = document.getElementsByClassName('symbols');

const start_times = document.getElementsByClassName('time_setting')[0].querySelectorAll('select');
const end_times = document.getElementsByClassName('time_setting')[1].querySelectorAll('select');

//ショートカットモデル登録用のhiddenフォームのvalue作成用
let sc_title = document.getElementById('shortcut_title');
let sc_nickname = document.getElementById('shortcut_nickname');
//トリガーの方はAND,ORの関係で順序が厳格、アクションの方はSTARTとENDに分ける
let sc_mac_address1 = document.getElementById('shortcut_mac_address1');
let sc_triggers = document.getElementById('shortcut_triggers');
let triggers_json = {};
let sc_mac_address2 = document.getElementById('shortcut_mac_address2');
let sc_actions = document.getElementById('shortcut_actions');
let actions_json = {};
//イメージ
// sc_mac_address1  ->  "e45f01422d6b"
// triggers_json  ->  {"BATTERY":['and', '23', '以上', '44', '以下'],"TEMPERATURE":['and', '23', '以上', '44', '以下'],"GTEMPERATURE":['or', '23', '以上', '44', '以下'],.....}
//    (例)"演算子, 受信コマンド, 数値"　※(A and B) or C みたいなことはできないので順番を守る 前半のandでの連結が全て優先されて、後半のor条件が順番に認識される
// sc_mac_address2  ->  "e45f01422d6b"
// actions_json  ->  {{"COLOR,R:xxx,G:yyy,B:zzz":[], "PDF,ON":[], "MP4,ON":[], "MP3,ON":[]}

// リピート
let repeat = document.getElementById('repeat');
let sc_repeat = document.getElementById('shortcut_repeat');
sc_repeat.value = repeat.value;
repeat.addEventListener('change', function(e) {
    sc_repeat.value = e.target.value;
    confirmShortcut();
});


//////////////////////  描画  ///////////////////////

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



//////////////////////  表示＆ショートカット登録  ///////////////////////

//プロダクト、トリガー、アクションが設定されたら画像変更
const choice_status = document.getElementsByClassName('choice_status');

// トリガーの「プロダクト」を選択すると表示する
const products_select = document.getElementById('products_select');
products_select.addEventListener('change', function(e) {
    trigger_set.textContent = e.target.value;
    sc_mac_address1.value = e.target.value;
    confirmShortcut();
});

//「トリガー」を選択すると表示する
const trigger_options = document.getElementsByClassName('trigger_options');
triggers_select.addEventListener('change', function(e) {
    if(e.target.value != ''){
        trigger_options[e.target.value].style.display = 'block';
        triggers_json[data_keys[e.target.value]] = ["and","","","",""];
        confirmShortcut();
    }
});

// アクションの「プロダクト」を選択すると表示する
const action_products_select = document.getElementById('action_products_select');
action_products_select.addEventListener('change', function(e) {
    action_set.textContent = e.target.value;
    sc_mac_address2.value = e.target.value;
    confirmShortcut();
});

//「アクション」を選択すると表示する　　//要検討
const action_options = document.getElementsByClassName('action_options');
actions_select.addEventListener('change', function(e) {
    if(e.target.value != ''){
        action_options[e.target.value].style.display = 'block';
        action_set.textContent = action_products_select.value;
        action_set.textContent += 'の' + actions[e.target.value];
        choice_status[1].src = '/ctrlpanel/icon_shortcut_check.svg';
        command = action_commands_keys[e.target.value]; //"COLOR,R:xxx,G:yyy,B:zzz"とかが入る
        if(command == "COLOR,R:xxx,G:yyy,B:zzz"){
            actions_json[command] = ["COLOR,R:xxx,G:yyy,B:zzz", "LED,OFF"];
        } else if(command == "PDF,ON"){
            actions_json[command] = ["PDF,ON", "PDF,OFF"];
        } else if(command == "MP4,ON"){
            actions_json[command] = ["MP4,ON", "MP4,OFF"];
        } else if(command == "MP3,ON"){
            actions_json[command] = ["MP3,ON", "MP3,OFF"];
        }
    }
    confirmShortcut();
});

//トリガーとアクションのプロダクトをデフォルト状態に設定
sc_mac_address1.value = products_select.value;
sc_mac_address2.value = action_products_select.value;


//////////////////////  時間を設定する（ここはビューに日本語表示するためだけのもの ※時刻はパラメータに勝手に入る）  ///////////////////////
let time = {"START":["","","","",""], "END":["","","","",""]};
// 初期化（現在の時刻をビューから取得して初期値とする）
for(let i = 0; i < start_times.length; i++){
    time["START"][i] = start_times[i].value;
    time["END"][i] = end_times[i].value;
}

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



//////////////////////  トリガー条件設定用の andボタン、orボタン  ///////////////////////
const and_btn = document.getElementsByClassName('and_btn');
const or_btn = document.getElementsByClassName('or_btn');
for(let i = 0; i < and_btn.length; i++){
    and_btn[i].addEventListener('click', function(e) {
        or_btn[i].style.background = '#fff';
        or_btn[i].style.color = '#46C541';
        e.target.style.background = '#46C541';
        e.target.style.color = '#fff';
        triggers_json[data_keys[i]][0] = "and";
        confirmShortcut();
        // console.log('and');
	});
    or_btn[i].addEventListener('click', function(e) {
        and_btn[i].style.background = '#fff';
        and_btn[i].style.color = '#46C541';
        e.target.style.background = '#46C541';
        e.target.style.color = '#fff';
        triggers_json[data_keys[i]][0] = "or";
        confirmShortcut();
        // console.log('or');
	});
}


//////////////////////  キャンセルボタン有効化  ///////////////////////
// トリガーのキャンセルボタン有効化
const trigger_cancel = document.getElementsByClassName('trigger_cancel');
for(let i = 0; i < trigger_cancel.length; i++){
    trigger_cancel[i].addEventListener('click', function() {
		trigger_options[i].style.display = 'none';
        triggers_select.selectedIndex = -1;
        confirmShortcut();
	});
}

// アクションのキャンセルボタン有効化
const action_cancel = document.getElementsByClassName('action_cancel');
for(let i = 0; i < action_cancel.length; i++){
    action_cancel[i].addEventListener('click', function() {
		action_options[i].style.display = 'none';
        actions_select.selectedIndex = -1;
        console.log(action_commands_keys[i]);
        action_keys = Object.keys(actions_json);
        if(action_keys.includes(action_commands_keys[i])){
            delete actions_json[action_commands_keys[i]];
        }
        confirmShortcut();
	});
}


//////////////////////  〇〇以上、以下の設定  ///////////////////////
//数値のインプットを取得
const choice_num = document.getElementsByClassName('choice_num');
const num1 = document.getElementsByClassName('num1');
const num2 = document.getElementsByClassName('num2');
for(let i = 0; i < choice_num.length; i++){
    choice_num[i].addEventListener('change', function(e) {
        let index_base = [].slice.call(trigger_options);
        index = index_base.indexOf(e.target.parentNode);
        if(e.target.className.includes('num1')){
            triggers_json[data_keys[index]][1] = e.target.value;
        } else if(e.target.className.includes('num2')){
            if(Number(num1[index].value) >= Number(num2[index].value)){
                alert('トリガーの条件を正しく設定してください。');
                num2[index].value = '';
                option2[index].children[0].selected = true;
            } else {
                triggers_json[data_keys[index]][3] = e.target.value;
            }
        }
        // console.log(triggers_json[data_keys[index]]);
        confirmShortcut();
	});
}

//以上以下のインプットを取得
const above_below = document.getElementsByClassName('above_below');
const option1 = document.getElementsByClassName('option1');
const option2 = document.getElementsByClassName('option2');
const select2 = document.getElementsByClassName('select2');
for(let i = 0; i < above_below.length; i++){
    above_below[i].addEventListener('change', function(e) {
        let index_base = [].slice.call(trigger_options);
        index = index_base.indexOf(e.target.parentNode.parentNode);
        if(e.target.className.includes('option1') && e.target.value != ''){
            triggers_json[data_keys[index]][2] = e.target.value;
            if(e.target.value == '以上' || e.target.value == 'より大きい'){
                num2[index].style.display = 'block';
                select2[index].style.display = 'block';
            } else {
                num2[index].style.display = 'none';
                select2[index].style.display = 'none';
            }
        } else if(e.target.className.includes('option2') && e.target.value != ''){
            if(Number(num1[index].value) >= Number(num2[index].value)){
                alert('トリガーの条件を正しく設定してください。');
                num2[index].value = '';
                option2[index].children[0].selected = true;
            } else {
                triggers_json[data_keys[index]][4] = e.target.value;
            }
        }
        confirmShortcut();
	});
}


console.log(sc_mac_address1.value);
console.log(JSON.stringify(triggers_json));
console.log(JSON.stringify(time));
console.log(sc_mac_address2.value);
console.log(JSON.stringify(actions_json));

//////////////////////  ショートカットの概要確認メソッド（各select値が変更のたびに実行）  ///////////////////////
// sc_choiceのプロダクト１のカラー初期化
if(sc_mac_address1.value != ''){
    sc_choice[0].style.color = "#46C541";
    sc_choice[0].textContent = 'ベンチ: ' + sc_mac_address1.value + ' で';
}
// sc_choiceのプロダクト２のカラー初期化
if(sc_mac_address2.value != ''){
    sc_choice[4].style.color = "#46C541";
    sc_choice[4].textContent = 'ベンチ: ' + sc_mac_address2.value + ' で';
}

function confirmShortcut(){
    //////////////////////// 表示初期化  /////////////////////////
    sc_choice[0].textContent = 'ベンチAで';
    sc_choice[1].textContent = '△△の状態なら、';
    sc_choice[2].textContent = '□時から';
    sc_choice[3].textContent = '×時まで';
    sc_choice[4].textContent = 'ベンチBで';
    sc_choice[5].textContent = '〇〇を実行する';

    let trigger_keys = Object.keys(triggers_json);
    let trigger_values = Object.values(triggers_json);
    let trigger_text = '';
    for(let i = 0; i < trigger_values.length; i++){
        if(trigger_values[i].includes('and')){
            trigger_text += ' かつ、'
        } else if(trigger_values[i].includes('or')){
            trigger_text += ' または、'
        }
        trigger_text += trigger_labels[trigger_keys[i]] + 'が'
        for(let j = 0; j < trigger_values[i].length; j++){
            trigger_text += trigger_values[i][j];
        }

        // if(trigger_values[i][1] == "" && trigger_values[i][3] == ""){
        //     sc_choice[1].style.color = '#eb7457';
        // } else {
        //     sc_choice[1].style.color = '#000000';
        // }
    }
    trigger_text = trigger_text.replaceAll('and', '').replaceAll('or', '');
    trigger_text = trigger_text.substr(trigger_text.indexOf('、') + 1);

    // console.log('トリガー: ' + trigger_text);

    sc_choice[0].textContent = 'ベンチ: ' + sc_mac_address1.value + ' で';
    if(trigger_text != ""){sc_choice[1].textContent = trigger_text + ' なら、';}
    if(sc_repeat.value == "1"){
        sc_choice[2].textContent = '毎日、' + time["START"][3] + ':' + time["START"][4] + 'から';
        sc_choice[3].textContent = time["END"][3] + ':' + time["END"][4] + 'まで';
    } else {
        sc_choice[2].textContent = time["START"][0] + '/' + time["START"][1] + '/' + time["START"][2] + ' の ' + time["START"][3] + ':' + time["START"][4] + ' から';
        sc_choice[3].textContent = time["END"][0] + '/' + time["END"][1] + '/' + time["END"][2] + ' の ' + time["END"][3] + ':' + time["END"][4] + ' まで';
    }
    sc_choice[4].textContent =  'ベンチ: ' + sc_mac_address2.value + ' で';

    let action_keys = Object.keys(actions_json);
    let action_values = Object.values(actions_json);
    let action_text = '';
    for(let i = 0; i < action_values.length; i++){
        action_text += action_commands[action_keys[i]] + 'かつ、'
    }

    action_text = action_text.substr( 0, action_text.length - 3 );
    // console.log('アクション: ' + action_text);
    
    if(action_keys.length != 0){sc_choice[5].textContent = action_text;}
    
    // if(Object.keys(triggers_json).length == 0 || shortcut["ACTIONS"]["START"].length == 0 || actions_json[action_commands_keys[e.target.value]][1].length == 0){
    //     save_filter.style.display = 'block';
    // } else {
    //     save_filter.style.display = 'none';
    // }

    //////////////////////////////////  設定の最終確認  /////////////////////////////////
    let final_check = [false, false, false, false]; //MACアドレス1、トリガー、MACアドレス2、アクションが正しく設定されているかチェック
    // プロダクト１の確認
    if(sc_mac_address1.value != ''){
        sc_choice[0].style.color = "#46C541";
        final_check[0] = true;
    } else {
        sc_choice[0].style.color = "#eb7457";
        final_check[0] = false;
    }
    // トリガーの確認
    if(trigger_keys.length != 0){
        let trigger_check = 0;
        for(let i = 0; i < trigger_values.length; i++){
            if(trigger_values[i][2] != ""){
                trigger_check ++;
            }
        }
        if(trigger_check == trigger_keys.length){
            sc_choice[1].style.color = "#46C541";
            trigger_set.textContent = sc_choice[1].textContent;
            choice_status[0].src = '/ctrlpanel/icon_shortcut_check.svg';
            final_check[1] = true;
        } else {
            final_check[1] = false;
        }
    }
    // タイマーの確認
    // 開始時間<終了時間のチェック
    let time_check = 0;
    for(let i = 0; i < start_times.length; i++){
        if(start_times[i].value > end_times[i].value){
            alert('終了時間は、開始時間よりも進んだ時間に設定してください。');
            break;
        } else {
            time_check++;
        }
    }
    if(time_check == 5){
        sc_choice[2].style.color = "#46C541";
        sc_choice[3].style.color = "#46C541";
    } else {
        sc_choice[2].style.color = "#eb7457";
        sc_choice[3].style.color = "#eb7457";
    }
    
    // プロダクト２の確認
    if(sc_mac_address2.value != ''){
        sc_choice[4].style.color = "#46C541";
        final_check[2] = true;
    } else {
        sc_choice[4].style.color = "#eb7457";
        final_check[2] = false;
    }

    // アクションの確認
    if(action_keys.length != 0){
        sc_choice[5].style.color = "#46C541";
        final_check[3] = true;
    } else {
        sc_choice[5].style.color = "#eb7457";
        final_check[3] = false;
    }

    if(final_check.includes(false)){
        save_btn.setAttribute("disabled", true);
        save_btn.style.backgroundColor = '#E2E7F0';
        save_btn.style.color = '#415964';
        save_btn.style.cursor = 'auto';
        choice_status[2].src = '/ctrlpanel/icon_shortcut_error.svg';
    } else {
        save_btn.removeAttribute("disabled");
        save_btn.style.backgroundColor = '#415964';
        save_btn.style.color = '#E2E7F0';
        save_btn.style.cursor = 'pointer';
        choice_status[2].src = '/ctrlpanel/icon_shortcut_check.svg';
    }

    sc_title.value = sc_choice[0] + sc_choice[1] + sc_choice[2] + sc_choice[3] + sc_choice[4] + sc_choice[5];
    sc_triggers.value = JSON.stringify(triggers_json);
    sc_actions.value = JSON.stringify(Object.values(actions_json));

    // console.log('MAC1: ' + sc_mac_address1.value);
    // console.log('トリガー: ' + sc_triggers.value);
    // console.log('時間: ' + JSON.stringify(time));
    // console.log('MAC2: ' + sc_mac_address2.value);
    // console.log('アクション: ' + sc_actions.value);

}


//////////////////////  「人気のショートカット」ボタンを有効化  ///////////////////////
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


//多分いらない
//コマンド送信メソッド（すぐにベンチに命令を送る（タイマー設定がない場合））
// function postCommand(command, mac_adrs){;
//     let request_cmd =  command + ',MAC,' + mac_adrs;
//     console.log('コマンド: ' + request_cmd + ' をMACアドレス: ' + mac_adrs + ' のベンチに送信');
// 	$.ajax({
// 		url: '/parcom/post_data',
// 		type: 'GET',
// 		dataType: 'text',
// 		async: true,
// 		data: {
// 			cmd: request_cmd
// 		},
// 	});
// }

// //コマンド予約メソッド（コントローラーに命令予約をさせる（タイマー設定がある場合））
// function setSchedule(command, mac_adrs){;
//     let request_cmd =  command + ',MAC,' + mac_adrs;
//     console.log('コマンド: ' + request_cmd + '（' + '00:00から00:00' + '） をMACアドレス: ' + mac_adrs + ' のベンチに予約');
// 	$.ajax({
// 		url: '/schedule/create',
// 		type: 'GET',
// 		dataType: 'text',
// 		async: true,
// 		data: {
// 			cmd: request_cmd
// 		},
// 	});
// }


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

// if(dummy_data){
//     postCommand('LED,OFF', 'e45f01422d6b');
// }

