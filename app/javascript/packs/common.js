$(function(){

	//ヘッダーメニュー開閉
	$(document).on('click',function(e) {
	   if(!$(e.target).closest('.header_menu_user').length) {
	     // ターゲット要素の外側をクリックした時の操作
			 $('.user_nav').slideUp();
			 $('.header_menu_user').removeClass('open');
	   } else {
	     // ターゲット要素をクリックした時の操作
			 $('.user_nav').slideToggle();
			 $('.header_menu_user').toggleClass('open');
	   }
	});

	//ハンバーガーメニュー
	$(".menu-trigger").click(function (){
		$(this).toggleClass("active");
		$('.sidebar_product').toggleClass('open');
	});

	//ホバー 画像反転
	$(function(){
	  $('.hover').each(function(){
	      var src_off = $(this).find('img').attr('src');
	      var src_on = src_off.replace('_off','_on');
	      $('<img />').attr('src',src_on);
	      $(this).hover(function(){
	          $(this).find('img').attr('src',src_on);
	      },function(){
	          $(this).find('img').attr('src',src_off);
	      });
	  });
	});

	//ページ内リンク　スムーススクロール
	$('a[href^="#"]').click(function(){
		let speed = 500;
		let href = $(this).attr("href");
		let target = $(href == "#" || href == "" ? 'html' : href);
		var header = $('header').height();
		let position = target.offset().top - header;
			$("html, body").animate({scrollTop:position}, speed, "swing");
		return false;
	});

	//サイドバープロダクト
	$(document).on("click", ".park_name", function () {
  	$(this).next('ul').slideToggle();
		$(this).toggleClass('open');
	});

	//サイドバー ショートカット
	$(document).on("click", ".readmore", function(){
    $(this).prev('.sidebar_sc_item_more').slideToggle();
		$(this).prev('.sidebar_sc_item_more').toggleClass('show');
    if($(this).prev('.sidebar_sc_item_more').hasClass('show')){
    $(this).text('閉じる');
    }else{
    $(this).text('もっと見る');
    }
  });

	//チェックボックス共通
	$(document).on("change", 'input.label_style_checkbox', function (){
	  $('input.label_style_checkbox').each(function(){
	    	if( $(this).prop('checked') ){
	        	$(this).parent().addClass('check');
	       	}else{
	        	$(this).parent().removeClass('check');
	       	}
	   });
	});

	//三点リーダークリック
	$(document).on("click", '.popup_btn', function (){
	  $('.popup_window').not(this).each(function(){
	      $(this).css({
	        'display': 'none'
	      })
	    });
	  $(this).next('.popup_window').slideUp();
		$(this).next('.popup_window').slideToggle();

	});
	$(document).on("click", '.popup_close', function (){
		$(this).parent('.popup_window').slideUp();
	});

	//free_wifi
	$('#terms_checkbox').change(function() {
    if($(this).is(':checked') ){
        $('input[type="submit"]').prop('disabled', false);
    }else{
      	$('input[type="submit"]').prop('disabled', true);
    }
	});

	//ヘルプ関連
	$('.faq_question').on('click',function(){
		$(this).toggleClass('open');
		$(this).next('.faq_answer').slideToggle();
	});
	$('.beginners_select_tab.tab_sp li.first').on('click',function(){
		$(this).toggleClass('open');
		$('.beginners_select_tab.tab_sp li').not(this).slideToggle();
	});




});
