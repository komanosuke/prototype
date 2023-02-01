let bench_mac_adrs = document.getElementById('bench_mac_adrs');
let hidden_mac_adrs = document.getElementById('hidden_mac_adrs');
bench_mac_adrs.addEventListener('change', function(e) {
    hidden_mac_adrs.textContent = e.target.value;
    console.log(e.target.value);
});

function postData(command){
    let mac_adrs = hidden_mac_adrs.textContent;
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

$('.usb_btn').eq(0).on('click', function() {
    postData('USB5V,ON');
});

$('.usb_btn').eq(1).on('click', function() {
    postData('USB5V,OFF');
});

$('.log_btn').eq(0).on('click', function() {
    postData('LOG,ON');
});

$('.log_btn').eq(1).on('click', function() {
    postData('LOG,OFF');
});

$('#position_btn').on('click', function() {
    let lat = document.getElementById('lat').value;
    let lon = document.getElementById('lon').value;
    postData('POSITION,LAT:' + lat + ',LON:' + lon);
});

$('#systemdown_btn').on('click', function() {
    postData('SYSTEMDOWN');
});

