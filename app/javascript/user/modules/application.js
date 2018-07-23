function currentLocationMatches(controller_action) {
  return $("body.user." + controller_action).length > 0
}

$(document).on('turbolinks:load', function() {

  if (currentLocationMatches('subscriptions_index')) {
    window.User.subscription_preferences_controller.index();
  } else if (currentLocationMatches('sessions_new')) {
    window.User.registration_controller.new();
  }

});
