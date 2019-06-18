import Cropper from 'cropperjs'

window.GobiertoAdmin.GobiertoCommonCustomFieldRecordsController = (function() {
  function GobiertoCommonCustomFieldRecordsController() {}

  GobiertoCommonCustomFieldRecordsController.prototype.handleForm = function(options) {
    for (let image_field of options.image_fields) {
      _cropImage(image_field)
    }
    _handleSelectBehaviors()
  }

  function _cropImage(image_field) {
    let uid = image_field.uid
    $(`#${ uid }`).change(function () {
      let $loaded_image = this;

      if ($loaded_image.files.length > 0) {
        validatesImageDimensionsToCrop($loaded_image, image_field);
      }
    });

    $(`#btnCrop_${ uid }`).click(function() {
      let $crop_x = $(`input#${ uid }_crop_x`),
          $crop_y = $(`input#${ uid }_crop_y`),
          $crop_w = $(`input#${ uid }_crop_w`),
          $crop_h = $(`input#${ uid }_crop_h`);
      let output = document.getElementById(`image_${ uid }`);

      $.magnificPopup.close();

      $(`#saved_image_${ uid }`).hide();

      $crop_x.val(output.cropper.getData()["x"]);
      $crop_y.val(output.cropper.getData()["y"]);
      $crop_w.val(output.cropper.getData()["width"]);
      $crop_h.val(output.cropper.getData()["height"]);
    });
  }

  function openCropModal(loaded_image, image_field) {
    let uid = image_field.uid

    $.magnificPopup.open({
      items: {
        src: `#crop-popup_${ uid }`
      },
      type: 'inline',
      callbacks: {
        open: function() {
          if (loaded_image.files && loaded_image.files[0]) {
            let reader = new FileReader();
            reader.onload = function () {
              let dataURL = reader.result;

              let output = document.getElementById(`image_${ uid }`);

              // Hack: Clear cropper
              if (output.classList.contains("cropper-hidden")) {
                output.src= "";
                output.cropper.destroy();
              }

              output.src = dataURL;

              new Cropper(output, { });
            }
            reader.readAsDataURL(loaded_image.files[0]);
          }
        }
      }
    });
  }

  function validatesImageDimensionsToCrop(loaded_image, image_field) {
    let reader = new FileReader();

    reader.readAsDataURL(loaded_image.files[0]);
    reader.onload = function (e) {
      let image = new Image();

      image.src = e.target.result;

      image.onload = function () {
        let height = this.height;
        let width = this.width;
        if ((height > image_field.max_height || width > image_field.max_width)) {
          openCropModal(loaded_image, image_field);
        } else {
          $(`#saved_image_${ image_field.uid }`).hide();
        }
      };
    };
  }

  function _handleSelectBehaviors() {
    $("[data-behavior=multiple_select]").select2()
    $("[data-behavior=tags]").select2({
      tags: true,
      createTag: function(params) {
        var term = $.trim(params.term);

        if (term === '') {
          return null;
        }
        if (_hasAccent(term)) {
          term = _fixNonAsciiChars(term)
          this.$element.parent().find(':input.select2-search__field').val(term)
        }

        return {
          id: term,
          text: term
        }
      }
    })

    // This should be controlled via css
    $(".select2-container").css("padding-top", "22px");
  }

  function _fixNonAsciiChars(text) {
    let transformations = {
      "´a": "á",
      "´e": "é",
      "´i": "í",
      "´o": "ó",
      "´u": "ú",
      "´A": "Á",
      "´E": "É",
      "´I": "Í",
      "´O": "Ó",
      "´U": "Ú",
      "`a": "à",
      "`e": "è",
      "`i": "ì",
      "`o": "ó",
      "`u": "ù",
      "`A": "À",
      "`E": "È",
      "`I": "Ì",
      "`O": "Ò",
      "`U": "Ù",
      "^a": "â",
      "^e": "ê",
      "^i": "î",
      "^o": "ô",
      "^u": "û",
      "^A": "Â",
      "^E": "Ê",
      "^I": "Î",
      "^O": "Ô",
      "^U": "Û",
      "¨a": "ä",
      "¨e": "ë",
      "¨i": "ï",
      "¨o": "ö",
      "¨u": "ü",
      "¨A": "Ä",
      "¨E": "Ë",
      "¨I": "Ï",
      "¨O": "Ö",
      "¨U": "Ü"
    };
    return text.replace(/[`´^¨][aeiouAEIOU]/, function(matched){
      return transformations[matched];
    });
  }

  function _hasAccent(term) {
    return term.match(/[`´^¨][aeiouAEIOU]/)
  }

  return GobiertoCommonCustomFieldRecordsController;
})();

window.GobiertoAdmin.gobierto_custom_field_records_controller = new GobiertoAdmin.GobiertoCommonCustomFieldRecordsController;
