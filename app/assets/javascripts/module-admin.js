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

	$('.open-new_row_content').click(function(e) {
		e.preventDefault();
		$('.new_row_add').hide();
		$('.new_row_content').show();
	});	

	$('.close-new_row_content').click(function(e) {
		e.preventDefault();
		$('.new_row_add').show();
		$('.new_row_content').hide();
	});	

	$('.open-new_block').click(function(e) {
		e.preventDefault();
		$('.new_block_content').show();
	});	

  $(".stick_in_parent, #stick_in_parent, stick_in_parent").stick_in_parent();


  // module-budget_consultations
  $('.check_participation_control').on('click', function(e){
    e.preventDefault();
    $('#check_participation').toggle();
    $('#check_participation').find('input').first().focus();
    $('#check_participation_start').toggle();
  });
  $('.check_participation_search').on('click', function(e){
  	e.preventDefault();
  	$('#check_participation').toggle();
  	$('#check_participation_results').toggle();
  });
  $('.check_participation_start').on('click', function(e){
  	e.preventDefault();
  	$('#check_participation').toggle();
    $('#check_participation').find('input').first().focus();
  	$('#check_participation_results').toggle();
  	$('#check_participation_start').toggle();

  });



});
