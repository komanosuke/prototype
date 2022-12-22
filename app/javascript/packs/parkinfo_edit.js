jQuery(function(){

	//公園情報の編集
	jQuery(document).on("click", ".toggle", function () {
  jQuery(this).toggleClass("checked");
	  if(!jQuery(this).children('.toggle input').prop("checked")) {
	    jQuery(this).children(".toggle input").prop("checked", true);
			jQuery(this).next('.park_status').children(".off").css({
				'display':'none'
			});
			jQuery(this).next('.park_status').children(".on").css({
				'display':'block'
			});
	  } else {
	    jQuery(this).children(".toggle input").prop("checked", false);
			jQuery(this).next('.park_status').children(".on").css({
				'display':'none'
			});
			jQuery(this).next('.park_status').children(".off").css({
				'display':'block'
			});
	  }
	});

	//開園日・閉園日
	let check = jQuery(".toggle").hasClass('checked');
	if (check) {
		jQuery(".park_status .off").css({
			'display':'none'
		});
	}else {
		jQuery(".park_status .on").css({
			'display':'none'
		});
	}

	//写真の全選択
  jQuery('.item_head input[name="all_select"]').on('click', function() {
    jQuery('.picture_list input[type="checkbox"]').prop('checked', this.checked);
  });

  jQuery('.picture_list input[type="checkbox"]').on('click', function() {
    if (jQuery('.picture_list :checked').length == jQuery('.picture_list :input').length) {
      jQuery('.item_head input[name="all_select"]').prop('checked', true);
    } else {
      jQuery('.item_head input[name="all_select"]').prop('checked', false);
    }
  });

	//写真の削除ボタン表示
	jQuery("#picture_edit input[type=checkbox]").change(function(){
　　　let cnt = jQuery("#picture_edit input[type=checkbox]:checked").length;
　　　if(cnt == 0) {
			jQuery('.delete_btn').css({
				'display' : 'none'
			});
　　　}else {
			jQuery('.delete_btn').css({
				'display' : 'block'
			});
　　　}
		jQuery(this).parent().parent().parent().parent().toggleClass('bg');
　});






});
