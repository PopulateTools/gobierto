import './modules/indicators_plugin.js'
import './modules/human_resources_plugin.js'
import './modules/budgets_plugin.js'

$(document).on('turbolinks:load', function() {
  $('form').submit(function(e) {

    // Indicators
    $('.v_container .v_el .form_item.plugin_field.indicators').each(function(i) {
      let uid = $(this).data('uid')
      $(`input[name$='[${uid}][value]']`).val(
        window.GobiertoAdmin.serializeIndicatorsPluginData($(this).data('slickGrid').getData())
      );
    });

    // Human Resources
    $('.v_container .v_el .form_item.plugin_field.human_resources').each(function(i) {
      let uid = $(this).data('uid')
      $(`input[name$='[${uid}][value]']`).val(
        window.GobiertoAdmin.serializeHumanResourcesPluginData($(this).data('slickGrid').getData())
      );
    });

    // Budgets
    $('.v_container .v_el .form_item.plugin_field.budgets').each(function(i) {
      let uid = $(this).data('uid')
      $(`input[name$='[${uid}][value]']`).val(
        window.GobiertoAdmin.serializeBudgetsPluginData($(this).data('slickGrid').getData())
      );
    });
  })
})
