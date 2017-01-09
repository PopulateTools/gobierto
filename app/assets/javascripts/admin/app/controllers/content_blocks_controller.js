this.GobiertoAdmin.ContentBlocksController = (function() {
  function ContentBlocksController() {}

  ContentBlocksController.prototype.edit = function(recordNamespace) {
    GobiertoAdmin.dynamic_content_component.handle(recordNamespace);
  };

  return ContentBlocksController;
})();

this.GobiertoAdmin.content_blocks_controller = new GobiertoAdmin.ContentBlocksController;
