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

    // Datepicker start time
    $fromDatePicker.datepicker({
      autoClose: true,
      startDate: start,
      onSelect: function onSelect(_, selectedDate, instance) {
        $(instance.el).trigger("datepicker-change");
        selectedDate.setHours(selectedDate.getHours() + 1);
        $toDatePicker.data('datepicker').selectDate(selectedDate);
      }
    });
    // Datepicker end time
    $toDatePicker.datepicker({
      autoClose: true,
      startDate: start,
      onSelect: function onSelect(_, _, instance) {
        $(instance.el).trigger("datepicker-change");
      }
    });

    var date = $fromDatePicker.data('datepicker').date
    $fromDatePicker.data('datepicker').selectDate(date);
  }

});
