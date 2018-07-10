window.GobiertoAdmin.ContentBlocksController = (function() {
  function ContentBlocksController() {}

  ContentBlocksController.prototype.edit = function(wrapper, namespace) {
    GobiertoAdmin.dynamic_content_component.handle(wrapper, namespace);
  };

  return ContentBlocksController;
})();

window.GobiertoAdmin.content_blocks_controller = new GobiertoAdmin.ContentBlocksController;
