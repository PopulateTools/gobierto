import 'select2'

window.GobiertoAdmin.ProcessStagePagesController = (function() {

  function ProcessStagePagesController() {}

  ProcessStagePagesController.prototype.form = function() {
    _selectPage();
  };

  function _selectPage() {
    $(document).ready(function() {
      $("select#process_stage_page_page_id").select2({
        width: '100%'
      });
    });
  }

  return ProcessStagePagesController;
})();

window.GobiertoAdmin.process_stage_pages_controller = new GobiertoAdmin.ProcessStagePagesController;
