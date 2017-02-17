this.GobiertoBudgetConsultations.ConsultationItemsController = (function() {
  function ConsultationItemsController() {}

  ConsultationItemsController.prototype.index = function(url){
    _redirectIfMobile(url);
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

this.GobiertoBudgetConsultations.consultation_items_controller = new GobiertoBudgetConsultations.ConsultationItemsController;
