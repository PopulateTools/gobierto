this.GobiertoAdmin.ProcessStagesController = (function() {

  function ProcessStagesController() {}

  ProcessStagesController.prototype.form = function() {
    _restoreModalContent();
  };

  function _restoreModalContent() {
    debugger;
    addDatepickerBehaviors();
  };

  return ProcessStagesController;
})();

this.GobiertoAdmin.process_stages_controller = new GobiertoAdmin.ProcessStagesController;
