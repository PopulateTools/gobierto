window.GobiertoAdmin.GobiertoCommonCustomFieldRecordsProgressPluginController = (function() {

  function GobiertoCommonCustomFieldRecordsProgressPluginController() {}

  var grid;

  GobiertoCommonCustomFieldRecordsProgressPluginController.prototype.form = function(opts = {}) {
    _handlePluginData(opts.uid);
  };

  function _applyPluginStyles(element, plugin_name_hint) {
    element.wrap("<div class='v_container'><div class='v_el v_el_level v_el_full_content'></div></div>");
  }

  function _handlePluginData(uid) {
    let element = $(`[data-uid=${uid}]`)
    let id = element.attr('id')
    let data = JSON.parse($(`#${id}`).find("input[name$='[value]'").val())

    _applyPluginStyles(element, "progress")
    _insertProgressPlugin(id, data)
  }

  function _insertProgressPlugin(id, data) {
    let element = $(`#${id}`)
    let formatted_data = data
      ? data.toLocaleString(I18n.locale, { style: 'percent', maximumFractionDigits: 1 })
      : "-"

    element.append(formatted_data);
    // element.append($('<input>', { disabled: true, type: 'text', val: formatted_data }))
  }

  return GobiertoCommonCustomFieldRecordsProgressPluginController;
})();

window.GobiertoAdmin.gobierto_common_custom_field_records_progress_plugin_controller = new GobiertoAdmin.GobiertoCommonCustomFieldRecordsProgressPluginController;
