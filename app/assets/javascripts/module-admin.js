$(document).on('turbolinks:load', function() {

	var header_height = $('header.main').height() + 1;
	$('menu.main').css('top', header_height);
	$('.admin_content_column').css('padding-top', header_height);
	

	$('.js-collapse-menu').click(function(e) {
		e.preventDefault();
		// $('menu.main').velocity({translateX: "-200px"});

		if($('menu.main').attr('data-menu-status') == 'open') {
			$('menu.main').attr('data-menu-status', 'closed');
			$('.container').removeClass('admin_content_column_with_menu_opened');	
			$('.container').addClass('admin_content_column_with_menu_closed');	
		}
		else if($('menu.main').attr('data-menu-status') == 'closed') {
			console.log('si');
			$('menu.main').attr('data-menu-status', 'open');
			$('.container').addClass('admin_content_column_with_menu_opened');	
			$('.container').removeClass('admin_content_column_with_menu_closed');	
		}
		

	});

	$('.tabs li a').click(function(e) {
    e.preventDefault();
    $(this).parent().parent().find('li a').removeClass('active');
    $(this).addClass('active');
    var tab = $(this).data("tab-target");
    $('.tab_content').hide();
    $('.tab_content[data-tab="'+tab+'"]').show();
  });

  $(".stick_in_parent, #stick_in_parent, stick_in_parent").stick_in_parent();


});