this.GobiertoAdmin.ConsultationResponsesController = (function() {
  function ConsultationResponsesController() {}

  ConsultationResponsesController.prototype.index = function() {
    _loadReport();
  };
  
  function _loadReport() {
    var vis_ageReport = new VisAgeReport('#age_report');
    vis_ageReport.render();

    var vis_consultationIndicators = new VisIndicators('#consultation-indicators');
    vis_consultationIndicators.render();
  }

  return ConsultationResponsesController;
})();

this.GobiertoAdmin.consultation_responses_controller = new GobiertoAdmin.ConsultationResponsesController;
