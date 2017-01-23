//= require trix
//= require jquery.geocomplete
//= require cleave
//= require ./trix_events
//= require ./trix_toolbar
//= require ./app/init
//= require_tree ./app

$(document).on('turbolinks:load', function() {

  // Datepicker
  $('.air-datepicker').datepicker({
    autoClose: true,
    minutesStep: 5,
    onSelect: function onSelect(_, _, instance) {
      $(instance.el).trigger("datepicker-change");
    }
  });

});
