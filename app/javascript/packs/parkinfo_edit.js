$(function(){

	//公園情報の編集
	$(document).on("click", ".toggle", function () {
  	$(this).toggleClass("checked");
		if(!$(this).children('.toggle input').prop("checked")) {
			$(this).children(".toggle input").prop("checked", true);
			$(this).next('.park_status').children(".off").css({
				'display':'none'
			});
			$(this).next('.park_status').children(".on").css({
				'display':'block'
			});
		} else {
			$(this).children(".toggle input").prop("checked", false);
			$(this).next('.park_status').children(".on").css({
				'display':'none'
			});
			$(this).next('.park_status').children(".off").css({
				'display':'block'
			});
		}
		});

	//開園日・閉園日
	let check = $(".toggle").hasClass('checked');
	if (check) {
		$(".park_status .off").css({
			'display':'none'
		});
	}else {
		$(".park_status .on").css({
			'display':'none'
		});
	}

		//写真の全選択
	$('.item_head input[name="all_select"]').on('click', function() {
		$('.picture_list input[type="checkbox"]').prop('checked', this.checked);
	});

	$('.picture_list input[type="checkbox"]').on('click', function() {
		if ($('.picture_list :checked').length == $('.picture_list :input').length) {
			$('.item_head input[name="all_select"]').prop('checked', true);
		} else {
			$('.item_head input[name="all_select"]').prop('checked', false);
		}
	});

	//写真の削除ボタン表示
	$("#picture_edit input[type=checkbox]").change(function(){
		let cnt = $("#picture_edit input[type=checkbox]:checked").length;
		if(cnt == 0) {
			$('.delete_btn').css({
				'display' : 'none'
			});
		}else {
			$('.delete_btn').css({
				'display' : 'block'
			});
		}
		$(this).parent().parent().parent().parent().toggleClass('bg');
	});






});


const time_hour_select = document.getElementsByName('time_hour');
const time_min_select = document.getElementsByName('time_min');

const time_hour = ["00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"];
const time_min = ["00", "05", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55"];

for(let i = 0; i < time_hour_select.length; i++){
	time_hour.forEach((v) => {
		const option = document.createElement('option');
		option.value = v;
		option.textContent = v;
		time_hour_select[i].appendChild(option);
	});
	time_min.forEach((v) => {
		const option = document.createElement('option');
		option.value = v;
		option.textContent = v;
		time_min_select[i].appendChild(option);
	});
}

//toggleのクラス名でチェックあるなし判定
let adapt_same = document.getElementById('adapt_same');
adapt_same.addEventListener('click', function() {
	if(adapt_same.className == 'label_style'){
		for(let i = 2; i < 14; i++){
			if(i % 2 == 0){
				time_hour_select[i].value = time_hour_select[0].value;
				time_min_select[i].value = time_min_select[0].value;
			} else {
				time_hour_select[i].value = time_hour_select[1].value;
				time_min_select[i].value = time_min_select[1].value;
			}
		}
		for(let i = 0; i < hours_keys.length; i++){
			hours[hours_keys[i]] = hours['Sun']; //hours['Sun']に合わせる
			toggleCheck(i*2+1, i*2+1);
		}
		makeHoursJson();
	}
});

//開園、閉園判定（閉園の場合は、営業時間 00:00~00:00 とする）
const open_or_close = document.getElementsByClassName('toggle');
for(let i = 0; i < open_or_close.length; i++){
	open_or_close[i].addEventListener('click', function() {
		if(open_or_close[i].className != 'toggle'){
			time_hour_select[i*2].value = time_hour_select[i*2+1].value = '00';
			time_min_select[i*2].value = time_min_select[i*2+1].value = '00';
			hours[hours_keys[i]] = [['00','00'],['00','00']];
			makeHoursJson();
		}
	});
}


//時間の初期設定 hoursの配列を最終的に 00:00-00:00 の形にする
let hours = {
	'Sun':[['00','00'],['00','00']],
	'Mon':[['00','00'],['00','00']],
	'Tue':[['00','00'],['00','00']],
	'Wed':[['00','00'],['00','00']],
	'Thu':[['00','00'],['00','00']],
	'Fri':[['00','00'],['00','00']],
	'Sat':[['00','00'],['00','00']]
};
let hours_keys = Object.keys(hours);


let hours_json = document.getElementById('hours').textContent.replace(/(\\|\/)/g,'').slice(1).slice(0,-1); //StringデータをJSONにできる状態にする
const park_hours = document.getElementById('park_hours');
park_hours.value = hours_json;
hours_json = JSON.parse(hours_json);
console.log(hours_json);

let hours_json_keys = Object.keys(hours_json);
for(let i = 0; i < hours_json_keys.length; i++){
	hours_json[hours_json_keys[i]] = hours_json[hours_json_keys[i]].replace('-', ',').replaceAll(':', ',').split(',');
	time_hour_select[i*2].value = hours_json[hours_json_keys[i]][0];
	time_hour_select[i*2+1].value = hours_json[hours_json_keys[i]][2];
	time_min_select[i*2].value = hours_json[hours_json_keys[i]][1];
	time_min_select[i*2+1].value = hours_json[hours_json_keys[i]][3];
	hours[hours_json_keys[i]][0][0] = String(hours_json[hours_json_keys[i]][0]);
	hours[hours_json_keys[i]][1][0] = String(hours_json[hours_json_keys[i]][2]);
	hours[hours_json_keys[i]][0][1] = String(hours_json[hours_json_keys[i]][1]);
	hours[hours_json_keys[i]][1][1] = String(hours_json[hours_json_keys[i]][3]);
}


const toggles = document.getElementsByClassName('toggle');

for(let i = 0; i < time_hour_select.length; i++){
	toggleCheck(i, i);
	time_hour_select[i].addEventListener('change', function(e) {
		let time_hour_select = [].slice.call(document.getElementsByName('time_hour'));
		let target_id = time_hour_select.indexOf(e.target);
		let target_value = e.target.value;
		setHour(target_id, target_value);
		makeHoursJson();
		toggleCheck(i, target_id);
	});
}
for(let i = 0; i < time_min_select.length; i++){
	toggleCheck(i, i);
	time_min_select[i].addEventListener('change', function(e) {
		let time_min_select = [].slice.call(document.getElementsByName('time_min'));
		let target_id = time_min_select.indexOf(e.target);
		let target_value = e.target.value;
		setMinute(target_id, target_value);
		makeHoursJson();
		toggleCheck(i,target_id);
	});
}

//00があったらトグルOFF、それ以外はON
function toggleCheck(i, target_id){
	if(i < 2){
		if(!(hours['Sun'][0][0] == '00' && hours['Sun'][0][1] == '00' && hours['Sun'][1][0] == '00' && hours['Sun'][1][1] == '00')){
			toggles[0].classList.add('checked');
		} else {
			toggles[0].classList.remove('checked');
		}
	} else if(2 <= target_id && target_id < 4){
		if(!(hours['Mon'][0][0] == '00' && hours['Mon'][0][1] == '00' && hours['Mon'][1][0] == '00' && hours['Mon'][1][1] == '00')){
			toggles[1].classList.add('checked');
		} else {
			toggles[1].classList.remove('checked');
		}
	} else if(4 <= target_id && target_id < 6){
		if(!(hours['Tue'][0][0] == '00' && hours['Tue'][0][1] == '00' && hours['Tue'][1][0] == '00' && hours['Tue'][1][1] == '00')){
			toggles[2].classList.add('checked');
		} else {
			toggles[2].classList.remove('checked');
		}
	} else if(6 <= target_id && target_id < 8){
		if(!(hours['Wed'][0][0] == '00' && hours['Wed'][0][1] == '00' && hours['Wed'][1][0] == '00' && hours['Wed'][1][1] == '00')){
			toggles[3].classList.add('checked');
		} else {
			toggles[3].classList.remove('checked');
		}
	} else if(8 <= target_id && target_id < 10){
		if(!(hours['Thu'][0][0] == '00' && hours['Thu'][0][1] == '00' && hours['Thu'][1][0] == '00' && hours['Thu'][1][1] == '00')){
			toggles[4].classList.add('checked');
		} else {
			toggles[4].classList.remove('checked');
		}
	} else if(10 <= target_id && target_id < 12){
		if(!(hours['Fri'][0][0] == '00' && hours['Fri'][0][1] == '00' && hours['Fri'][1][0] == '00' && hours['Fri'][1][1] == '00')){
			toggles[5].classList.add('checked');
		} else {
			toggles[5].classList.remove('checked');
		}
	} else if(12 <= target_id && target_id < 14){
		if(!(hours['Sat'][0][0] == '00' && hours['Sat'][0][1] == '00' && hours['Sat'][1][0] == '00' && hours['Sat'][1][1] == '00')){
			toggles[6].classList.add('checked');
		} else {
			toggles[6].classList.remove('checked');
		}
	}
}


function setHour(id, value){
	if(id < 2){	
		hours['Sun'][0][id%2] = value;
	} else if(2 <= id && id < 4){
		hours['Mon'][0][id%2] = value;
	} else if(4 <= id && id < 6){
		hours['Tue'][0][id%2] = value;
	} else if(6 <= id && id < 8){
		hours['Wed'][0][id%2] = value;
	} else if(8 <= id && id < 10){
		hours['Thu'][0][id%2] = value;
	} else if(10 <= id && id < 12){
		hours['Fri'][0][id%2] = value;
	} else if(12 <= id && id < 14){
		hours['Sat'][0][id%2] = value;
	}
	//console.log(JSON.stringify(hours));
}
function setMinute(id, value){
	console.log(id);
	if(id < 2){	
		hours['Sun'][1][id%2] = value;
	} else if(2 <= id && id < 4){
		hours['Mon'][1][id%2] = value;
	} else if(4 <= id && id < 6){
		hours['Tue'][1][id%2] = value;
	} else if(6 <= id && id < 8){
		hours['Wed'][1][id%2] = value;
	} else if(8 <= id && id < 10){
		hours['Thu'][1][id%2] = value;
	} else if(10 <= id && id < 12){
		hours['Fri'][1][id%2] = value;
	} else if(12 <= id && id < 14){
		hours['Sat'][1][id%2] = value;
	}
	//console.log(JSON.stringify(hours));
}
function makeHoursJson(){
	let new_hours = {
		'Sun':'',
		'Mon':'',
		'Tue':'',
		'Wed':'',
		'Thu':'',
		'Fri':'',
		'Sat':''
	};
	new_hours['Sun'] = hours['Sun'][0][0] + ':' + hours['Sun'][1][0] + '-' +  hours['Sun'][0][1] + ':' +  hours['Sun'][1][1];
	new_hours['Mon'] = hours['Mon'][0][0] + ':' + hours['Mon'][1][0] + '-' +  hours['Mon'][0][1] + ':' +  hours['Mon'][1][1];
	new_hours['Tue'] = hours['Tue'][0][0] + ':' + hours['Tue'][1][0] + '-' +  hours['Tue'][0][1] + ':' +  hours['Tue'][1][1];
	new_hours['Wed'] = hours['Wed'][0][0] + ':' + hours['Wed'][1][0] + '-' +  hours['Wed'][0][1] + ':' +  hours['Wed'][1][1];
	new_hours['Thu'] = hours['Thu'][0][0] + ':' + hours['Thu'][1][0] + '-' +  hours['Thu'][0][1] + ':' +  hours['Thu'][1][1];
	new_hours['Fri'] = hours['Fri'][0][0] + ':' + hours['Fri'][1][0] + '-' +  hours['Fri'][0][1] + ':' +  hours['Fri'][1][1];
	new_hours['Sat'] = hours['Sat'][0][0] + ':' + hours['Sat'][1][0] + '-' +  hours['Sat'][0][1] + ':' +  hours['Sat'][1][1];
	park_hours.value = JSON.stringify(new_hours);
	//console.log(hours);
	console.log(park_hours.value);
}







let fee = document.getElementById('fee').textContent.replace(/(\\|\/)/g,'').slice(1).slice(0,-1);
const park_fee = document.getElementById('park_fee');
park_fee.value = fee;
fee = JSON.parse(fee);
console.log(fee);
let adult_fee = document.getElementsByName('adult_fee')[0];
let child_fee = document.getElementsByName('child_fee')[0];
adult_fee.value = fee['大人'];
child_fee.value = fee['子供'];
adult_fee.addEventListener('change', function(e) {
	fee['大人'] = e.target.value;
	park_fee.value = JSON.stringify(fee);
});
child_fee.addEventListener('change', function(e) {
	fee['子供'] = e.target.value;
	park_fee.value = JSON.stringify(fee);
});






/////////////////////////////////////////
//データ取得、JSON化
let parking_info = document.getElementById('parking_info').textContent.replace(/(\\|\/)/g,'').slice(1).slice(0,-1);
const park_parking_info = document.getElementById('park_parking_info');
park_parking_info.value = parking_info;
parking_info = JSON.parse(parking_info);
console.log(parking_info);
let parking_info_keys = Object.keys(parking_info);

//JSONデータをビューに反映
let parking_labels = document.getElementsByName('parking');
for(let i = 0; i < parking_labels.length; i++){
	if(parking_info[parking_info_keys[i]] == true){
		parking_labels[i].parentElement.classList.add('check');
		parking_labels[i].checked = true;
	}
}

//parking_labelsデータの変更をhiddenパラメータのvalueに反映
let parking_inputs = document.getElementsByName('parking');
for(let i = 0; i < parking_inputs.length; i++){
	parking_inputs[i].addEventListener('click', function(e) {
		if(e.target.parentElement.className.includes('check')){
			parking_info[parking_info_keys[i]] = false;
		} else {
			parking_info[parking_info_keys[i]] = true;
		}
		park_parking_info.value = JSON.stringify(parking_info);
		console.log(parking_info);
	});
}


/////////////////////////////////////////
//データ取得、JSON化
let toilet_info = document.getElementById('toilet_info').textContent.replace(/(\\|\/)/g,'').slice(1).slice(0,-1);
const park_toilet_info = document.getElementById('park_toilet_info');
park_toilet_info.value = toilet_info;
toilet_info = JSON.parse(toilet_info);
console.log(toilet_info);
let toilet_info_keys = Object.keys(toilet_info);

//JSONデータをビューに反映
let toilet_labels = document.getElementsByName('toilet');
for(let i = 0; i < toilet_labels.length; i++){
	if(toilet_info[toilet_info_keys[i]] == true){
		toilet_labels[i].parentElement.classList.add('check');
		toilet_labels[i].checked = true;
	}
}

//toilet_labelsデータの変更をhiddenパラメータのvalueに反映
let toilet_inputs = document.getElementsByName('toilet');
for(let i = 0; i < toilet_inputs.length; i++){
	toilet_inputs[i].addEventListener('click', function(e) {
		if(e.target.parentElement.className.includes('check')){
			toilet_info[toilet_info_keys[i]] = false;
		} else {
			toilet_info[toilet_info_keys[i]] = true;
		}
		park_toilet_info.value = JSON.stringify(toilet_info);
		console.log(toilet_info);
	});
}


/////////////////////////////////////////
//データ取得、JSON化
let playground_info = document.getElementById('playground_info').textContent.replace(/(\\|\/)/g,'').slice(1).slice(0,-1);
const park_playground_info = document.getElementById('park_playground_info');
park_playground_info.value = playground_info;
playground_info = JSON.parse(playground_info);
console.log(playground_info);
let playground_info_keys = Object.keys(playground_info)

//JSONデータをビューに反映
let playground_labels = document.getElementsByName('playground');
for(let i = 0; i < playground_labels.length; i++){
	if(playground_info[playground_info_keys[i]] == true){
		playground_labels[i].parentElement.classList.add('check');
		playground_labels[i].checked = true;
	}
}

//playground_labelsデータの変更をhiddenパラメータのvalueに反映
let playground_inputs = document.getElementsByName('playground');
for(let i = 0; i < playground_inputs.length; i++){
	playground_inputs[i].addEventListener('click', function(e) {
		if(e.target.parentElement.className.includes('check')){
			playground_info[playground_info_keys[i]] = false;
		} else {
			playground_info[playground_info_keys[i]] = true;
		}
		park_playground_info.value = JSON.stringify(playground_info);
		console.log(playground_info);
	});
}





// const pdf_file = document.getElementById('pdf_file');
// const sizeLimit = 1024 * 1024 * 1; // 制限サイズ
// // changeイベントで呼び出す関数
// function handleFileSelect(){
//     let file = pdf_file.files[0];
//     if (file && file.size > sizeLimit) {
//         // ファイルサイズが制限以上
//         alert('ファイルサイズは1MB以下にしてください'); // エラーメッセージを表示
//         // pdf_file.value = ''; // inputの中身をリセット
//         return; // この時点で処理を終了する
//     }
//     previewFile(file);
//     // $('#preview_image').css('visibility', 'visible');
//     // $('.preview_close_btn').css('visibility', 'visible');
// }
// // ファイル選択時にhandleFileSelectを発火
// pdf_file.addEventListener('change', handleFileSelect);

// function previewFile(file) {
//     // プレビュー画像を追加する要素
//     // const preview = document.getElementById('preview');
//     // FileReaderオブジェクトを作成
//     const reader = new FileReader();
  
//     // URLとして読み込まれたときに実行する処理
//     // reader.onload = function (e) {
//     //   const imageUrl = e.target.result; // URLはevent.target.resultで呼び出せる
//     //   $('#preview_dummy').css('display', 'none');
//     // //   const img = document.createElement("img"); // img要素を作成
//     // //   img.src = imageUrl; // URLをimg要素にセット
//     // //   img.id = 'preview_image';
//     // //   preview.appendChild(img); // #previewの中に追加
//       console.log('アップロード準備OK');
//       //postData('PDF,ON:' + imageUrl);  //アップロード画像を液晶表示するコマンドをベンチに送る(previewと連動)
//     // }
//     // いざファイルをURLとして読み込む
//     reader.readAsDataURL(file);
// }

const img_file = document.getElementById('img_file');
let img_name = document.getElementById('img_name');
let img_size = document.getElementById('img_size');
img_file.addEventListener('change', function() {
	img_name.value = img_file.files[0].name;
	img_size.value = Math.round((img_file.files[0].size/1000000)*100)/100 + 'MB';
});


const add_picture = document.getElementById('add_picture');
const upload_box = document.getElementById('upload_box');
const cover = document.getElementById('cover');
add_picture.addEventListener('click', function() {
	// submitPicture();
	upload_box.style.display = 'block';
	cover.style.display = 'block';
});
cover.addEventListener('click', function() {
	upload_box.style.display = 'none';
	cover.style.display = 'none';
});

// function submitPicture(){
//     const submitButton = document.getElementById("add_picture_submit");
//     submitButton.click();
// }



//写真の管理　チェックを入れると、削除写真のインデックスをpark_pic_listのvalueに格納
const park_pic_list = document.getElementById('park_pic_list');
const picture_id = document.getElementsByName('pic');
const all_select = document.getElementsByName('all_select')[0];
all_select.addEventListener('click', function() {
	if(all_select.checked){
		for(let i = 0; i < picture_id.length; i++){
			picture_id[i].checked = true;
		}
	} else {
		for(let i = 0; i < picture_id.length; i++){
			picture_id[i].checked = false;
		}
	}
	checkPicId();
});
for(let i = 0; i < picture_id.length; i++){
	picture_id[i].addEventListener('click', function() {
		checkPicId();
	});
}

console.log(picture_id);

function checkPicId(){
	let pic_list = ''
	for(let i = 0; i < picture_id.length; i++){
		if(picture_id[i].checked){
			pic_list += i + ',';
		}
	}
	park_pic_list.value = pic_list;
	console.log(pic_list);
}