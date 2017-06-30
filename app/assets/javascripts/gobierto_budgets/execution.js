$( document ).on('turbolinks:load', function() {
  'use strict';

  $('.execution_vs_budget_table tr:nth-of-type(n+6)').hide()

  $('.execution_vs_budget_table + .more').on('click', function(e) {
    e.preventDefault();
    $(this).prev('.execution_vs_budget_table').find('tr:nth-of-type(n+6)').toggle();
    if ($(this).text() == $(this).data('more-literal'))
      $(this).text($(this).data('less-literal'));
    else
      $(this).text($(this).data('more-literal'));
  })

  if ($('.expenses_execution').length) {
    var vis_expenses_execution = new VisLinesExecution('.expenses_execution', 'G', 'functional')
    vis_expenses_execution.render();
  }

  if ($('.income_execution').length) {
    var vis_income_execution = new VisLinesExecution('.income_execution', 'I', 'economic')
    vis_income_execution.render();
  }
});
var vis_evoline = [];
function render_evo_line($widget_node) {
  var data = $widget_node.find('.vizz').data('series');
  var container_id = "#" + $widget_node.find('.vizz').attr('id');
  var current_year = $('body').data('year');
  var vis = new VisEvoLine(container_id, data, current_year);
  vis.render();
  vis_evoline.push(vis);
}
