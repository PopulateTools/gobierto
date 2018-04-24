window.GobiertoAdmin.GobiertoCalendarsEventsController = (function() {
  function GobiertoCalendarsEventsController() {}

  GobiertoCalendarsEventsController.prototype.index = function(wrapper, namespace) {
    $('a[data-toggle]').on('click', function(e){
      $('div#archived-list').toggle();
    });
  };

  return GobiertoCalendarsEventsController;
})();

window.GobiertoAdmin.gobierto_calendars_events_controller = new GobiertoAdmin.GobiertoCalendarsEventsController;
