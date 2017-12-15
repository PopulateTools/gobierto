//= require d3.v3
//= require crossfilter
//= require dc
//= require jsgrid.min
//= require ./invoices_controller

$(document).on('turbolinks:load', function() {

  function setFilter(filter) {

    console.log(filter);

    // Reset every button
    $('.sort-G').removeClass('active');

    $(".sort-G[data-toggle=" + filter + "]").addClass('active');

    // Render the new category
    // var vis_expenses_execution = new VisLinesExecution('.expenses_execution', 'G', expensesKind)
    // vis_expenses_execution.render();

  }

  $('#invoices-filters button').on('click', function (e) {
    var filter = $(e.target).attr('data-toggle');

    setFilter(filter);
  });

});
