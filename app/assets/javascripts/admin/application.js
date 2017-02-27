//= require trix
//= require jquery.geocomplete
//= require cleave
//= require ./trix_events
//= require ./trix_toolbar
//= require ./app/init
//= require_tree ./app

$(document).on('turbolinks:load', function() {

  if($('.air-datepicker').length){
    var start = new Date();
    start.setDate(start.getDate() + 1);
    start.setHours(start.getHours() + 1);
    start.setMinutes(0);

    var $fromDatePicker = $('.air-datepicker:eq(0)');
    var $toDatePicker = $('.air-datepicker:eq(1)');

    if($toDatePicker.length){
      // Datepicker end time
      $toDatePicker.datepicker({
        autoClose: true,
        startDate: new Date($toDatePicker.data('startdate')),
        onSelect: function onSelect(_, _, instance) {
          $(instance.el).trigger("datepicker-change");
        }
      });
    }

    // Datepicker start time
    if($fromDatePicker.data('range') === undefined) {
      $fromDatePicker.datepicker({
        autoClose: true,
        minutesStep: 5,
        startDate: new Date($fromDatePicker.data('startdate')),
        onSelect: function onSelect(_, selectedDate, instance) {
          $(instance.el).trigger("datepicker-change");
          selectedDate.setHours(selectedDate.getHours() + 1);
          if($toDatePicker.length){
            $toDatePicker.data('datepicker').selectDate(selectedDate);
          }
        }
      });

      var date = new Date($fromDatePicker.data('startdate'));
      $fromDatePicker.data('datepicker').selectDate(date);
      if($toDatePicker.length){
        date = new Date($toDatePicker.data('startdate'));
        $toDatePicker.data('datepicker').selectDate(date);
      }
    } else {
      $fromDatePicker.datepicker({
        autoClose: true,
        onSelect: function onSelect(_, selectedDate, instance) {
          $(instance.el).trigger("datepicker-change");
        }
      });
    }
  }

  $('#site_visibility_level_active').on('click', function(e){
    $('#site_username').val('');
    $('#site_password').val('');
  });

});
