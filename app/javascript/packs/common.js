jQuery(function(){

	//ヘッダーメニュー開閉
	jQuery(document).on('click',function(e) {
	   if(!jQuery(e.target).closest('.header_menu_user').length) {
	     // ターゲット要素の外側をクリックした時の操作
			 jQuery('.user_nav').slideUp();
			 jQuery('.header_menu_user').removeClass('open');
	   } else {
	     // ターゲット要素をクリックした時の操作
			 jQuery('.user_nav').slideToggle();
			 jQuery('.header_menu_user').toggleClass('open');
	   }
	});

	//ハンバーガーメニュー
	jQuery(".menu-trigger").click(function (){
		jQuery(this).toggleClass("active");
		jQuery('.sidebar_product').toggleClass('open');
	});

	//ホバー 画像反転
	jQuery(function(){
	  jQuery('.hover').each(function(){
	      var src_off = jQuery(this).find('img').attr('src');
	      var src_on = src_off.replace('_off','_on');
	      jQuery('<img />').attr('src',src_on);
	      jQuery(this).hover(function(){
	          jQuery(this).find('img').attr('src',src_on);
	      },function(){
	          jQuery(this).find('img').attr('src',src_off);
	      });
	  });
	});

	//ページ内リンク　スムーススクロール
	jQuery('a[href^="#"]').click(function(){
		let speed = 500;
		let href = jQuery(this).attr("href");
		let target = jQuery(href == "#" || href == "" ? 'html' : href);
		var header = jQuery('header').height();
		let position = target.offset().top - header;
			jQuery("html, body").animate({scrollTop:position}, speed, "swing");
		return false;
	});

	//サイドバープロダクト
	jQuery(document).on("click", ".park_name", function () {
  	jQuery(this).next('ul').slideToggle();
		jQuery(this).toggleClass('open');
	});

	//サイドバー ショートカット
	jQuery(document).on("click", ".readmore", function(){
    jQuery(this).prev('.sidebar_sc_item_more').slideToggle();
		jQuery(this).prev('.sidebar_sc_item_more').toggleClass('show');
    if(jQuery(this).prev('.sidebar_sc_item_more').hasClass('show')){
    jQuery(this).text('閉じる');
    }else{
    jQuery(this).text('もっと見る');
    }
  });

	//チェックボックス共通
	jQuery(document).on("change", 'input.label_style_checkbox', function (){
	  jQuery('input.label_style_checkbox').each(function(){
	        if( jQuery(this).prop('checked') ){
	        jQuery(this).parent().addClass('check');
	       }else{
	        jQuery(this).parent().removeClass('check');
	       }
	   });
	});

	//三点リーダークリック
	jQuery(document).on("click", '.popup_btn', function (){
	  jQuery('.popup_window').not(this).each(function(){
	      jQuery(this).css({
	        'display': 'none'
	      })
	    });
	  jQuery(this).next('.popup_window').slideUp();
		jQuery(this).next('.popup_window').slideToggle();

	});
	jQuery(document).on("click", '.popup_close', function (){
		jQuery(this).parent('.popup_window').slideUp();
	});

	//free_wifi
	jQuery('#terms_checkbox').change(function() {
    if(jQuery(this).is(':checked') ){
        jQuery('input[type="submit"]').prop('disabled', false);
    }else{
      	jQuery('input[type="submit"]').prop('disabled', true);
    }
	});

	//ヘルプ関連
	jQuery('.faq_question').on('click',function(){
		jQuery(this).toggleClass('open');
		jQuery(this).next('.faq_answer').slideToggle();
	});
	jQuery('.beginners_select_tab.tab_sp li.first').on('click',function(){
		jQuery(this).toggleClass('open');
		jQuery('.beginners_select_tab.tab_sp li').not(this).slideToggle();
	});




});
