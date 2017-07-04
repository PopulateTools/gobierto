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
    // Render functional data by default, let the user switch between datasets
    var vis_expenses_execution = new VisLinesExecution('.expenses_execution', 'G', 'functional')
    vis_expenses_execution.render();

    $('.expenses_switcher').on('click', function (e) {
      var economicKind = $(e.target).attr('data-toggle');

      $('.expenses_execution').html('');

      $('.expenses_switcher').removeClass('active');
      $(e.target).addClass('active');

      // Reset every button
      $('.sort-G').removeClass('active');
      $('.value-switcher-G').removeClass('active');

      $(".sort-G[data-toggle='highest']").addClass('active');
      $(".value-switcher-G[data-toggle='pct_executed']").addClass('active');

      // Render the new category
      var vis_expenses_execution = new VisLinesExecution('.expenses_execution', 'G', economicKind)
      vis_expenses_execution.render();
    });

    $('.expenses_execution .tooltiped').tipsy({
      gravity: 's',
      trigger: 'hover',
      html: true,
      live: true
    });
  }

  if ($('.income_execution').length) {
    var vis_income_execution = new VisLinesExecution('.income_execution', 'I', 'economic')
    vis_income_execution.render();

    $('.income_execution .tooltiped').tipsy({
      gravity: 's',
      trigger: 'hover',
      html: true,
      live: true
    });
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
