window.GobiertoAdmin.GobiertoCommonCustomFieldRecordsDummyPluginController = (function() {

  function GobiertoCommonCustomFieldRecordsDummyPluginController() {}

  GobiertoCommonCustomFieldRecordsDummyPluginController.prototype.form = function(opts = {}) {
    _handlePluginData(opts.uid);
  };

  function _handlePluginData(uid) {
    let element = $(`[data-uid=${uid}]`)
    let id = element.attr('id')
    let data = JSON.parse($(`#${id}`).find("input[name$='[value]'").val())

    _applyPluginStyles(element)
    _insertDummyPlugin(id, data)

    $("form").submit(
      function() {
        $(".v_container .v_el .form_item.plugin_field.dummy").each(function(i) {
          let uid = $(this).data("uid")
          $(`input[name$='[${uid}][value]']`).val(JSON.stringify($(this).data("value")));
        });
      }
    );
  }

  function _applyPluginStyles(element) {
    element.wrap("<div class='v_container'><div class='v_el v_el_level v_el_full_content'></div></div>");
  }

  function _insertDummyPlugin(id, data) {
    let element = $(`#${id}`)
    element.append("Test: ", $('<input>', { type: 'text', val: data.content }))
    element.children("input").change(function() {
      $(this).parent().data("value", { content: this.value })
    })
  }
  return GobiertoCommonCustomFieldRecordsDummyPluginController;
})();

window.GobiertoAdmin.gobierto_common_custom_field_records_dummy_plugin_controller = new GobiertoAdmin.GobiertoCommonCustomFieldRecordsDummyPluginController;
