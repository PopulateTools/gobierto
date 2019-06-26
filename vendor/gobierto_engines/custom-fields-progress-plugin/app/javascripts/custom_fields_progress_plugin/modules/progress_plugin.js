window.GobiertoAdmin.GobiertoCommonCustomFieldRecordsProgressPluginController = (function() {

  function GobiertoCommonCustomFieldRecordsProgressPluginController() {}

  GobiertoCommonCustomFieldRecordsProgressPluginController.prototype.form = function(opts = {}) {
    _handlePluginData(opts.uid);
  };

  function _handlePluginData(uid) {
    let element = $(`[data-uid=${uid}]`)
    let id = element.attr('id')
    let data = JSON.parse($(`#${id}`).find("input[name$='[value]'").val())

    _insertProgressPlugin(id, data)
  }

  function _insertProgressPlugin(id, data) {
    let element = $(`#${id}`)
    element.remove();
    let progress_select = $("select[id$='_progress'")
    if(progress_select.length) {
      progress_select.replaceWith(
        $('<input type="text" disabled="disabled" data-plugin-type="progress">').val(
          data
            ? data.toLocaleString(I18n.locale, { style: 'percent', maximumFractionDigits: 1 })
            : "-"
        )
      );
    }
  }

  return GobiertoCommonCustomFieldRecordsProgressPluginController;
})();

window.GobiertoAdmin.gobierto_common_custom_field_records_progress_plugin_controller = new GobiertoAdmin.GobiertoCommonCustomFieldRecordsProgressPluginController;
