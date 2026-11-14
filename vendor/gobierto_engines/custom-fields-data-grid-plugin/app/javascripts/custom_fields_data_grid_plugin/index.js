import './modules/budgets_plugin.js'

$(document).on('turbolinks:load', function() {
  $('form').submit(function() {

    // Budgets
    $('.v_container .v_el .form_item.plugin_field.budgets').each(function() {
      let uid = $(this).data('uid')
      let input = $(`input[name$='[${uid}][value]']`)
      let data = $(this).data('slickGrid').getData()

      // An empty grid on a field without data must keep it empty: serializing it
      // would be detected as a change and create a new version of the item.
      if (data.length === 0 && input.val() === 'null') return

      input.val(window.GobiertoAdmin.serializeBudgetsPluginData(data));
    });
  })
})
