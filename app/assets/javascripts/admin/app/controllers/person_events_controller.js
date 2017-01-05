this.GobiertoAdmin.PersonEventsController = (function() {
  function PersonEventsController() {}

  PersonEventsController.prototype.edit = function(recordNamespace) {
    GobiertoAdmin.dynamic_content_component.handle(recordNamespace);
  };

  return PersonEventsController;
})();

this.GobiertoAdmin.person_events_controller = new GobiertoAdmin.PersonEventsController;
