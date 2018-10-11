window.GobiertoAdmin.GobiertoCitizensChartersEditionsIntervalsController = (function() {
  function GobiertoCitizensChartersEditionsIntervalsController() {}

  GobiertoCitizensChartersEditionsIntervalsController.prototype.handleForm = function() {
    _handleDateSelect();
  };

  function _handleDateSelect() {
    $("#editions_interval_period_interval").change(function() {
      _handleButtonEnable($(this));
      let disabledType = _selectDisabledType($(this).val());
      $.each($("div[data-disabled]"), function(){
        if ($(this).data("disabled") == disabledType) {
          $(this).show();
          _handleButtonEnable($(this).find("select"));
          $(this).find("select").change(function() { _handleButtonEnable($(this));});
        } else {
          $(this).hide();
        }
      });
    });
  }

  function _handleButtonEnable(selection) {
    $("input.button").prop('disabled', !selection.val());
  }

  function _selectDisabledType(interval) {
    if (interval == "year") {
      return "month";
    } else if (["month", "quarter"].includes(interval)) {
      return "day";
    } else if (!interval) {
      return false
    } else {
      return "nothing";
    }
  }

  return GobiertoCitizensChartersEditionsIntervalsController;
})();

window.GobiertoAdmin.gobierto_citizens_charters_editions_intervals_controller = new GobiertoAdmin.GobiertoCitizensChartersEditionsIntervalsController;
