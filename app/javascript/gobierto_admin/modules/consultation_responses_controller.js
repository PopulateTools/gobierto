import { VisAgeReport, VisIndicators } from '../../lib/visualizations'

window.GobiertoAdmin.ConsultationResponsesController = (function() {
  function ConsultationResponsesController() {}

  ConsultationResponsesController.prototype.index = function(dataUrl) {
    _loadReport(dataUrl);
  };

  function _loadReport(dataUrl) {
    var vis_ageReport = new VisAgeReport('#age_report .vis', dataUrl);
    vis_ageReport.render();

    var vis_consultationIndicators = new VisIndicators('#consultation-indicators', dataUrl);
    vis_consultationIndicators.render();
  }

  return ConsultationResponsesController;
})();

window.GobiertoAdmin.consultation_responses_controller = new GobiertoAdmin.ConsultationResponsesController;
