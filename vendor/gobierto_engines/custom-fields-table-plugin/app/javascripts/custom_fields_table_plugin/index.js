import './modules/table_plugin.js'

$(document).on('turbolinks:load', function() {
  $('form').submit(function(e) {

    // Table
    $('.v_container .v_el .form_item.plugin_field.table').each(function(i) {
      let uid = $(this).data('uid')
      $(`input[name$='[${uid}][value]']`).val(
        window.GobiertoAdmin.serializeTablePluginData($(this).data('slickGrid').getData(), uid)
      );
    });

  })
})
