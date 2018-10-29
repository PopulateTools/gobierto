import '@claviska/jquery-minicolors'


window.GobiertoAdmin.ColorPickerComponent = (function() {
  function ColorPickerComponent() {}

  ColorPickerComponent.prototype.handle = function() {
    $(document).on("turbolinks:load", _handleGlobalizedForm);
  };

  ColorPickerComponent.prototype.handleColorPicker = function() {
    _handleColorPicker();
  };

  function _handleGlobalizedForm() {
    /* COLOR PICKER */
    /* https://github.com/claviska/jquery-minicolors */
    $('[data-behavior="colorpicker"]').each(function() {
      $(this).minicolors({
        theme: "bootstrap",
        format: "hex"
      });
    })
  }

  return ColorPickerComponent;
})();

window.GobiertoAdmin.color_picker_component = new GobiertoAdmin.ColorPickerComponent;
