$(document).on('turbolinks:load', function() {

	$('.menu_control, menu.complete .close').click(function(e) {
		e.preventDefault();
		if( $('menu.complete').css('display') == 'none' ) {
			$('menu.complete').velocity("slideDown");
			$('menu.complete .close').velocity({
				display: 'block', 
				top: '-2em',
				"z-index": 1,
				opacity: 1
			}, {
				delay: 150
			});
		}
		else {
			$('menu.complete .close').velocity({
				"z-index": -1,
				top: '2em',
				opacity: 0
			});
			$('menu.complete').velocity("slideUp", { delay: 150 });
		}	
	});

});