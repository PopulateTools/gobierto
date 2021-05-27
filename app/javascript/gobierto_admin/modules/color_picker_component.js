import '@claviska/jquery-minicolors'
import '@claviska/jquery-minicolors/jquery.minicolors.css'

window.GobiertoAdmin.ColorPickerComponent = (function() {
  function ColorPickerComponent() {}

  ColorPickerComponent.prototype.handle = function() {
    $(document).on("turbolinks:load", _handleGlobalizedForm);
  };

  function _handleGlobalizedForm() {
    /* COLOR PICKER */
    /* https://github.com/claviska/jquery-minicolors */
    $('[data-behavior="colorpicker"]').each(function() {
      $(this).minicolors({
        theme: "bootstrap",
        position: "bottom left",
        format: "hex"
      });
    })
  }

  return ColorPickerComponent;
})();

window.GobiertoAdmin.color_picker_component = new GobiertoAdmin.ColorPickerComponent;
