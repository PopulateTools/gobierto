//= require d3.v3
//= require crossfilter
//= require dc
//= require jsgrid.min
//= require moment
//= require ./invoices_controller

$(document).on('turbolinks:load', function() {

  $('#invoices-filters button').on('click', function (e) {
    var filter = $(e.target).attr('data-toggle');

    // Reset every button
    $('.sort-G').removeClass('active');

    $(".sort-G[data-toggle=" + filter + "]").addClass('active');

    window.GobiertoBudgets.invoices_controller.show(filter);
  });

});
