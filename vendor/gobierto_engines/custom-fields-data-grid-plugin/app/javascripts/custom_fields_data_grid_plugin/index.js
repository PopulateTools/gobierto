import './modules/budgets_plugin.js'

$(document).on('turbolinks:load', function() {
  $('form').submit(function(e) {

    // Budgets
    $('.v_container .v_el .form_item.plugin_field.budgets').each(function(i) {
      let uid = $(this).data('uid')
      $(`input[name$='[${uid}][value]']`).val(
        window.GobiertoAdmin.serializeBudgetsPluginData($(this).data('slickGrid').getData())
      );
    });
  })
})
