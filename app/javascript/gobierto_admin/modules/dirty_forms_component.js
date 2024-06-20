window.GobiertoAdmin.DirtyFormsComponent = (function() {
  var isDirty;
  var t1, t2;

  function DirtyFormsComponent() {}

  DirtyFormsComponent.prototype.handle = function(message) {
    $(document).on("turbolinks:load", _handleDirtyFlag);

    $(document).on("turbolinks:before-visit", function() {
      if (isDirty) { return confirm(message); }
    });

    $(window).on("beforeunload", function() {
      if (isDirty) { return message; }
    });
  };

  function _handleDirtyFlag() {
    isDirty = false;
    var date = new Date();
    t1 = date.getTime();

    var checkingForm = $("form:not(.skip-dirty-check)");

    checkingForm.on("submit", _unsetDirty);
    checkingForm.on("change", "input, select, textarea", _setDirty);
    checkingForm.on("datepicker-change", _setDirty);
  }

  function _setDirty(e) {
    var $target = $(e.target);
    if ($target.data('skip-dirty-check') === undefined){
      var date = new Date();
      t2 = date.getTime();
      // For some reason, when the WYSIWYG has an image, it triggers a trix-change event.
      // Here, we check if the time difference between the load and the event is big than 1 sec.
      if (t2 - t1 > 1000) {
        isDirty = true;
      }
    }
  }

  function _unsetDirty() {
    isDirty = false;
  }

  return DirtyFormsComponent;
})();

window.GobiertoAdmin.dirty_forms_component = new GobiertoAdmin.DirtyFormsComponent;
