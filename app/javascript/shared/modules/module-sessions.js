import 'velocity-animate'

$(document).on('turbolinks:load', function() {

	$('.show_login_box').click(function(e) {
		e.preventDefault();
		$('.password_recovery_box').addClass("hidden");
		$('.login_box').removeClass('hidden').velocity("transition.slideLeftIn");
	});

	$('.show_password_recovery_box').click(function(e) {
		e.preventDefault();
		$('.login_box').addClass("hidden");
		$('.password_recovery_box').removeClass('hidden').velocity("transition.slideLeftIn");
	});

});
