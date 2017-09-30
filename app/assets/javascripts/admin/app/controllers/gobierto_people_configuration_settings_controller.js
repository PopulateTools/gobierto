this.GobiertoAdmin.GobiertoPeopleConfigurationSettingsController = (function() {
  function GobiertoPeopleConfigurationSettingsController() {}

  GobiertoPeopleConfigurationSettingsController.prototype.edit = function() {
    _hide_irrelevant_fields();
    _ibm_settings_fields();
  };

  function _hide_irrelevant_fields(){
    if ($("#calendar-integration-picker select").val() !== 'ibm_notes') {
      $(".ibm_notes_setting").hide();
    }
    if ($("#calendar-integration-picker select").val() !== 'microsoft_exchange') {
      $(".microsoft_exchange_setting").hide();
    }
  }

  function _ibm_settings_fields() {
    $("#calendar-integration-picker select").on('change', function(){
      if ($(this).val() === "ibm_notes") {
        $(".ibm_notes_setting").show('slow');
      } else {
        $(".ibm_notes_setting input").val('');
        $(".ibm_notes_setting").hide('slow');
      }
      if ($(this).val() === "microsoft_exchange") {
        $(".microsoft_exchange_setting").show('slow');
      } else {
        $(".microsoft_exchange_setting input").val('');
        $(".microsoft_exchange_setting").hide('slow');
      }
    });
  }

  return GobiertoPeopleConfigurationSettingsController;
})();

this.GobiertoAdmin.gobierto_people_configuration_settings_controller = new GobiertoAdmin.GobiertoPeopleConfigurationSettingsController;
