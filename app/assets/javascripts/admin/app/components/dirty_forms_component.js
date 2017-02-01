this.GobiertoAdmin.DirtyFormsComponent = (function() {
  var isDirty;

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

    var checkingForm = $("form:not(.skip-dirty-check)");

    checkingForm.on("submit", _unsetDirty);
    checkingForm.on("change", "input, select, textarea", _setDirty);
    checkingForm.on("trix-change", _setDirty);
    checkingForm.on("datepicker-change", _setDirty);
  }

  function _setDirty(e) {
    console.log('_setDirty', e);
    isDirty = true;
  }

  function _unsetDirty() {
    isDirty = false;
  }

  return DirtyFormsComponent;
})();

this.GobiertoAdmin.dirty_forms_component = new GobiertoAdmin.DirtyFormsComponent;
