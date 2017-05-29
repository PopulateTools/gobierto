this.GobiertoAdmin.GobiertoAttachmentsController = (function() {
  function GobiertoAttachmentsController() {}

  GobiertoAttachmentsController.prototype.index = function() {
    app();
  };

  function app() {
    Vue.component('modal', {
      template: '#modal-template'
    })

    Vue.component('file-list', {
      template: '#file-list-template'
    })

    // start app
    new Vue({
      el: '#gobierto-attachment',
      data: {
        showModal: false,
        showFiles: false
      }
    })
  }

  return GobiertoAttachmentsController;
})();

this.GobiertoAdmin.gobierto_attachments_controller = new GobiertoAdmin.GobiertoAttachmentsController;
