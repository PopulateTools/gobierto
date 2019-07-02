window.GobiertoAdmin.GobiertoCommonCustomFieldsController = (function() {
  function GobiertoCommonCustomFieldsController() {}

  GobiertoCommonCustomFieldsController.prototype.handleForm = function() {
    _handleItemTypeSelection()
    _handlePluginTypeSelection()
    _handleBehaviors()
    _handlePluginOptionsDefault()
  };

  function _handleItemTypeSelection() {
    $(document).on("change", "input[data-has-options]", function(e) {
      $("div.configuration .form_block").children("div").hide();

      if ($(this).data().hasVocabulary) {
        $("#vocabulary").show();
        if ($(this).data().hasOptions) {
          $("#vocabulary_type").show();
        }
      } else if ($(this).data().hasOptions) {
        $("#options").show();
      }

      if ($(this).data().type === "plugin") {
        _handlePluginOptionsVisibility($('.js-plugin-type-option[checked="checked"]'));
        _handlePluginOptionsDefault();
      }

      // Show options related to type
      if ($(this).data().type) {
        $(`#${$(this).data().type}`).show();
      }
    })
  }

  function _handlePluginOptionsVisibility(selection) {
    let defaults = $("#configuration").data("defaults");
    let current_type = $("#configuration").data("type");
    let current_value = $("#configuration").attr("data-value")

    selection.attr("has_vocabulary") === "true"
      ? $("#vocabulary").show()
      : $("#vocabulary").hide()

    if (selection.attr("has_configuration") === "true") {
      $("#configuration").show();

      selection.val() === current_type
        ? $("#custom_field_plugin_configuration").val(current_value)
        : $("#custom_field_plugin_configuration").val(defaults[selection.val()]);
    } else {
      $("#configuration").hide();
    }
  }

  function _handlePluginOptionsDefault() {
    let defaults = $("#configuration").data("defaults");

    $("#custom_field_plugin_configuration").change(function(e) {
      if ($("#custom_field_plugin_configuration").val().length === 0) {
        let selection = $('.js-plugin-type-option:checked').val();
        $("#custom_field_plugin_configuration").val(defaults[selection]);
      }
    });
  }

  function _handlePluginTypeSelection() {
    $(".js-plugin-type-option").click(e => _handlePluginOptionsVisibility($(e.target)));
  }

  function _handleBehaviors() {
    $(document).on("click", "[data-behavior]", function handler(e) {
      if ($(this).data("behavior") === "delete_option") {
        e.preventDefault()
        _deleteOption($(this).data("index"))
      } else if ($(this).data("behavior") === "new_option") {
        e.preventDefault()
        _showNew()
      } else if ($(this).data("behavior") === "cancel_new") {
        e.preventDefault()
        _hideNew()
      } else if ($(this).data("behavior") === "create") {
        e.preventDefault()
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
