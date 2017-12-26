this.GobiertoAdmin.ProcessStagePagesController = (function() {

  function ProcessStagePagesController() {}

  ProcessStagePagesController.prototype.form = function() {
    _selectPage();
  };

  function _selectPage() {
    $(document).ready(function() {
      $("select#process_page_id").select2({
        width: '100%'
      });
    });
  }

  return ProcessStagePagesController;
})();

this.GobiertoAdmin.process_stages_controller = new GobiertoAdmin.ProcessStagePagesController;
