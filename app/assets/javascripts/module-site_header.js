$(document).on('turbolinks:load', function() {

	$('.menu_control, .close').click(function(e) {
		e.preventDefault();
		if( $('menu.complete').css('display') == 'none' ) {
			$('menu.complete').velocity("transition.slideDownIn");
			if(($(window).width() < 740)) {
				$('menu.complete').velocity("scroll", { offset: -30});
			}
			$('menu.complete .close').velocity({
				display: 'block', 
				top: '-2em'
				
			}, {
				delay: 150
			});
		}
		else {
			$('menu.complete .close').velocity({
				top: '2em'
			});
			$('menu.complete').velocity("transition.slideUpOut", { delay: 150 });
		}	
	});

	$('menu.nav .search_box input').focus(function(e) {
		$(this).velocity({width: '250px'});
	});
	$('menu.nav .search_box input').blur(function(e) {
		$(this).velocity({width: '150px'});
	});

});