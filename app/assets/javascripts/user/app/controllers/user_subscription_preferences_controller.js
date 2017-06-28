this.User.SubscriptionPreferencesController = (function() {
  function SubscriptionPreferencesController() {}

  SubscriptionPreferencesController.prototype.index = function(){
    _handleSiteSelected();
  };

  function _handleSiteSelected(){
    $('#user_subscription_preferences_site_to_subscribe').on('change', function(e){
      if($(this).is(':checked') === false){
        _uncheckAllOptions();
      } else {
        _checkAllOoptions();
      }
    });
  }

  function _checkAllOoptions(){
    $('input[data-selected]').prop('checked', 'checked');
  }

  function _uncheckAllOptions(){
    $('input[data-selected]').each(function(){
      if($(this).data('selected') === false){
        $(this).prop('checked', null);
      }
    });
  }

  return SubscriptionPreferencesController;
})();

this.User.subscription_preferences_controller = new User.SubscriptionPreferencesController;
