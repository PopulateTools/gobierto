import 'velocity-animate'

window.GobiertoParticipation.ProcessesController = (function() {

  function ProcessesController() {}

  ProcessesController.prototype.show = function() {
    _addProgressMapBehaviors();
  };

  function _addProgressMapBehaviors() {
    var $progressMap = $('#progress_map');

    if ($progressMap) {
      var $dots = $progressMap.find('.dots');
      $dots.click(function() {
        $('#timeline').velocity('scroll', {
          duration: 1500
        });
      });
    }
  }

  return ProcessesController;
})();

window.GobiertoParticipation.processes_controller = new GobiertoParticipation.ProcessesController;
