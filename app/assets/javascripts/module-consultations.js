$(document).on('turbolinks:load', function() {

	function deficitEnter() {
		// e.preventDefault();
		$('.debt_marker').addClass('debt_warning');	
		$('.debt_marker .qty')
			.velocity({backgroundColor: '#AC3E3E'})
			.velocity("callout.flash");
		$('.warning_text').velocity("transition.slideDownBigIn");
	}
	function deficitExit() {
		$('.debt_marker').removeClass('debt_warning');	
		$('.debt_marker .qty').velocity({backgroundColor: '#F0F0F0'});
		$('.warning_text').velocity("transition.slideUpBigOut");
	}
	$('.consultation_marker .increase').click(function(e) {
		// e.preventDefault();
		deficitEnter();
	});
	$('.consultation_marker .reduce').click(function(e) {
		// e.preventDefault();
		deficitExit();
	});

});
