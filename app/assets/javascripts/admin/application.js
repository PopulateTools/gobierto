//= require trix
//= require ./trix_events
//= require ./app/init
//= require_tree ./app

$(document).on('turbolinks:load', function() {

  // Datepicker
  $('.air-datepicker').datepicker({
    autoClose: true
  });

});
