//公園詳細ページ　特徴
	jQuery('.park_utility_detail ul').css("display", "none");
	jQuery('.detail_btn').on('click',function(){
		jQuery(this).prev('.park_utility_detail ul').slideToggle();
		if (jQuery(this).text() === '↑ 詳細を閉じる') {
	    jQuery(this).text('↓ 詳細を見る');
	  } else {
	    jQuery(this).text('↑ 詳細を閉じる');
	  }
	});


//詳細ページサイドバー　周辺施設
	jQuery('.more').css("display", "none");
	jQuery('.readmore').click(function () {
		jQuery(this).prev('.park_content_wrap ul').children('.more').slideToggle();
		if (jQuery(this).text() === '閉じる') {
	    jQuery(this).text('もっと見る');
	  } else {
	    jQuery(this).text('閉じる');
	  }
	});

//スマホ時表示順変更
	if (window.matchMedia('(max-width: 960px)').matches){
		jQuery('#basicinfo').after(jQuery('#utility'),jQuery('#photo'),jQuery('#event'),jQuery('#review'),jQuery('#around_facility'),jQuery('#park_access'),jQuery('#park_contact'),jQuery('#around_park'),jQuery('#saw_recently'),jQuery('#park_manager'));
	} else {
		jQuery('#basicinfo').after(jQuery('#utility'),jQuery('#photo'),jQuery('#event'),jQuery('#review'),jQuery('#park_manager'));
	}
