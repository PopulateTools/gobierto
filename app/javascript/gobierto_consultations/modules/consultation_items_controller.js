import { isMobile } from 'lib/shared'
import Turbolinks from 'turbolinks'

window.GobiertoBudgetConsultations.ConsultationItemsController = (function() {
  function ConsultationItemsController() {}

  ConsultationItemsController.prototype.index = function(url){
    _redirectIfMobile(url);
  };

  ConsultationItemsController.prototype.summary = function(urls){
    var $target = $('[data-consultation-link]');
    if($target.length){
      if(isMobile()){
        $target.attr('href', urls.responseUrl);
      } else {
        $target.attr('href', urls.summaryUrl);
      }
    }
  };

  function _redirectIfMobile(url){
    if(isMobile()){
      Turbolinks.visit(url);
    } else {
      $('.consultation').removeClass('hidden');
    }
  }

  return ConsultationItemsController;
})();

window.GobiertoBudgetConsultations.consultation_items_controller = new GobiertoBudgetConsultations.ConsultationItemsController;
