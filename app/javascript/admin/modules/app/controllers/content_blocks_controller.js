this.GobiertoAdmin.ContentBlocksController = (function() {
  function ContentBlocksController() {}

  ContentBlocksController.prototype.edit = function(wrapper, namespace) {
    GobiertoAdmin.dynamic_content_component.handle(wrapper, namespace);
  };

  return ContentBlocksController;
})();

this.GobiertoAdmin.content_blocks_controller = new GobiertoAdmin.ContentBlocksController;
