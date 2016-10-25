$(function () {
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