window.GobiertoAdmin.GobiertoCommonCustomFieldsController = (function() {
  function GobiertoCommonCustomFieldsController() {}

  GobiertoCommonCustomFieldsController.prototype.handleForm = function() {
    _handleItemTypeSelection()
    _handlePluginTypeSelection()
    _handleBehaviors()
  };

  function _handleItemTypeSelection() {
    $(document).on("change", "input[data-has-options]", function(e) {
      $("div.configuration .form_item").children("div").hide();

      if ($(this).data().hasVocabulary) {
        $("#vocabulary").show();
      } else if ($(this).data().hasOptions) {
        $("#options").show();
      }

      if ($(this).data().type === "plugin") {
        $(".js-plugin-type-option").each(function() {
          if ($(this).is(":checked") && $(this).attr("has_vocabulary")) {
            $("#vocabulary").show();
          }
        });
      }

      // Show options related to type
      if ($(this).data().type) {
        $(`#${$(this).data().type}`).show();
      }
    })
  }

  function _handlePluginTypeSelection() {
    $(".js-plugin-type-option").click(function(e) {
      if ($(e.target).attr("has_vocabulary") === "true") {
        $("#vocabulary").show();
      } else {
        $("#vocabulary").hide();
      }
    })
  }

  function _handleBehaviors() {
    $(document).on("click", "[data-behavior]", function handler(e) {
      e.preventDefault()
      if ($(this).data("behavior") === "delete_option") {
        _deleteOption($(this).data("index"))
      } else if ($(this).data("behavior") === "new_option") {
        _showNew()
      } else if ($(this).data("behavior") === "cancel_new") {
        _hideNew()
      } else if ($(this).data("behavior") === "create") {
        $(`div[data-option=${$(this).data("index")}]`).find("input#custom_field_options_translations_new_option_es").val()
        let elems = $(`div[data-option=${$(this).data("index")}]`).find("input")
        let translations = {}
        elems.each(function() {
          let translation = $(this).val().trim()
          if (translation.length > 0) {
            translations[$(this).data("locale")] = translation
          }
        })
        if (!$.isEmptyObject(translations)) {
          _clearNew()
          _create(translations)
        }
      }
    })
  }

  function _deleteOption(index) {
    if (confirm(I18n.t("gobierto_admin.gobierto_common.custom_fields.custom_fields.form.confirm"))) {
      $(`div[data-option=${index}]`).remove()
    }
  }

  function _showNew() {
    $("#new-option-form").show()
    $("div#add-option").hide()
  }

  function _hideNew() {
    $("#new-option-form").hide()
    $("div#add-option").show()
  }

  function _clearNew() {
    $("#new-option-form").find("input").val("")
  }

  function _create(translations) {
    $.ajax({
      type: "POST",
      url: '/admin/custom_fields/create_option',
      dataType: 'html',
      data: { translations: translations },
      success: function(data) {
        $("#options-list").append(data)
      }
    })
  }

  return GobiertoCommonCustomFieldsController;
})();

window.GobiertoAdmin.gobierto_custom_fields_controller = new GobiertoAdmin.GobiertoCommonCustomFieldsController;
