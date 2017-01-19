//= require trix
//= require jquery.geocomplete
//= require ./trix_events
//= require ./trix_toolbar
//= require ./app/init
//= require_tree ./app

$(document).on('turbolinks:load', function() {

  // Datepicker
  $('.air-datepicker').datepicker({
    autoClose: true,
    onSelect: function onSelect(_, _, instance) {
      $(instance.el).trigger("datepicker-change");
    }
  });

});
