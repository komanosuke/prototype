function postData(command){
    let mac_adrs = '1111';
    // let mac_adrs = data['MAC_ADDRESS']; //MACアドレスをViewで選択
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

let usb_btn = document.getElementById('');
let log_btn = document.getElementById('');
let position_btn = document.getElementById('');
let systemdown_btn = document.getElementById('');

$('#usb_btn').on('click', function() {
    postData('USB5V,ON');
});

$('#log_btn').on('click', function() {
    postData('LOG,ON');
});

$('#position_btn').on('click', function() {
    let lat = document.getElementById('lat').value;
    let lon = document.getElementById('lon').value;
    postData('POSITION,LAT:' + lat + ',LON:' + lon);
});

$('#systemdown_btn').on('click', function() {
    postData('SYSTEMDOWN');
});