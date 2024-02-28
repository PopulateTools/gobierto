import Cropper from 'cropperjs'

window.GobiertoAdmin.GobiertoCommonCustomFieldRecordsController = (function() {
  function GobiertoCommonCustomFieldRecordsController() {}

  GobiertoCommonCustomFieldRecordsController.prototype.handleForm = function(options) {
    for (let image_field of options.image_fields) {
      _cropImage(image_field)
    }
    _handleSelectBehaviors()
    _handleMultipleElementsBehaviors()
  }

  function _handleMultipleElementsBehaviors() {
    $(document).on("click", "[data-behavior]", function handler(e) {
      if ($(this).data("behavior") === "delete_item") {
        e.preventDefault();
        _deleteItem($(this).data("index"), $(this).data("uid"));
      } else if ($(this).data("behavior") === "new_item") {
        e.preventDefault();
        _showNewItem();
      } else if ($(this).data("behavior") === "cancel_new") {
        e.preventDefault();
        if ($(this).parents("span#new-item-form").length > 0 ) {
          _hideNewItem();
        } else {
          $(this).parents("span").remove();
        }
      }
    })
  }

  function _handleCropper({ target, image_field }) {
    if (target.files.length > 0) {
      validatesImageDimensionsToCrop(target, image_field);
    }
  }

  function _cropImage(image_field) {
    let uid = image_field.uid
    $(`#${ uid }`).change(e => _handleCropper({ ...e, image_field }));

    $(`#btnCrop_${ uid }`).click(function({ target }) {
      const output = document.getElementById(`image_${ uid }`);

      $.magnificPopup.close();

      $(`#saved_image_${ uid }`).hide();

      output.cropper.getCroppedCanvas().toBlob((blob) => {
        let { from } = target.dataset

        // when we are adding a new item, the "from" attribute is wrong (it does not contain any "index" value to distinguish the others)
        // so this block is required to guess which ID will have the new input[type=file]
        if (!document.getElementById(from).files.length) {
          // the one that contains "add_item" class is the template (fake item),
          // so the valid one will be the last item, except the template 🤯🤯🤯
          const [{ id }] = Array.from(document.querySelectorAll(`[id^=${from}]`)).filter(x => !x.classList.contains("add_item")).slice(-1)
          if (!id) return

          from = id
        }

        // https://pqina.nl/blog/set-value-to-file-input/
        const file = new File([blob], `chopped-${document.getElementById(from).files[0].name}`, { type: blob.type })
        const dt = new DataTransfer()
        dt.items.add(file)

        document.getElementById(from).files = dt.files
      });

      _createNewItem(image_field)
    });
  }

  function _createNewItem(image_field) {
    if ($("#new-item-form").length == 0) return

    let uid = image_field.uid
    let index = $(".new_item").last().data("index") === undefined ? 0 : $(".new_item").last().data("index") + 1
    let item_uid = `${uid}_${index}`

    let addItemForm = $("#new-item-form").clone().prop("id", `new-item-form-${index}`).addClass("new_item")
    addItemForm.find("input").each(function(){
      $(this).prop('name', $(this).prop("name").replace("add_item", index))
      $(this).prop('id', $(this).prop("id").replace(uid, item_uid))
      // re-assign the cropper event for the new created elements
      $(this).change(e => _handleCropper({ ...e, image_field }));
    });
    addItemForm.find(".add_item").removeClass("add_item")
    addItemForm.data("index", index)

    $("#new-item-form").before(addItemForm)
    _hideNewItem()
    $('.add_item').val('');
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

            // required to identify which input[type=file] is triggering the modal
            $(`#btnCrop_${ uid }`).attr("data-from", loaded_image.id)
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
          _createNewItem(image_field)
          $(`#saved_image_${ image_field.uid }`).hide();
        }
      };
    };
  }

  function _deleteItem(index, uid) {
    if (confirm(I18n.t("gobierto_admin.gobierto_common.custom_fields.custom_fields.form.confirm"))) {
      $(`div[data-index=${index}][data-uid=${uid}]`).remove()
    }
  }

  function _showNewItem() {
    $("div#add-item").hide()
    $("#new-item-form").show()
    $("#new-item-form").find(".add_item").click()
  }

  function _hideNewItem() {
    $("#new-item-form").hide()
    $("div#add-item").show()
  }

  function _handleSelectBehaviors() {
    $("[data-behavior=single_select]").select2()
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
