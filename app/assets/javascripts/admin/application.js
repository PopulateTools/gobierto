//= require trix
//= require jquery.geocomplete
//= require cleave
//= require tipsy
//= require air-datepicker/datepicker.min
//= require air-datepicker/i18n/datepicker.es
//= require air-datepicker/i18n/datepicker.en
//= require air-datepicker/i18n/datepicker.ca
//= require ./trix_events
//= require ./trix_toolbar
//= require ./app/init
//= require sticky-kit.min
//= require_tree ./app

//= require module-admin


$(document).on('turbolinks:load', function() {
  $('.open_remote_modal').magnificPopup({
    type: 'ajax',
    removalDelay: 300,
    mainClass: 'mfp-fade',
    callbacks: {
      ajaxContentAdded: function() {
        window.GobiertoAdmin.globalized_forms_component.handleGlobalizedForm();
      }
    }
  });

  $(".stick_in_parent").stick_in_parent();

  addDatepickerBehaviors();

  $('#site_visibility_level_active').on('click', function(e){
    $('#site_username').val('');
    $('#site_password').val('');
  });

  $('a[data-disabled]').on('click', function(e){
    e.preventDefault();
  });

});

function addDatepickerBehaviors() {
  if ($('.air-datepicker').length == 1) {
    initializePageWithOnlyOneDatepicker();
  } else if($('.air-datepicker').length){
    var $fromDatePickers = $('.air-datepicker:even');
    var $toDatePickers   = $('.air-datepicker:odd');

    var index = 0;

    $toDatePickers.each(function(index, toDatePicker) {

      // Datepicker end time
      $(toDatePicker).datepicker({
        autoClose: true,
        startDate: new Date($(toDatePicker).data('startdate')),
        onSelect: function onSelect(_, _, instance) {
          $(instance.el).trigger("datepicker-change");
        }
      });

      // Datepicker start time
      var fromDatePicker = $fromDatePickers[index];

      if($(fromDatePicker).data('range') === undefined) {
        $(fromDatePicker).datepicker({
          autoClose: true,
          minutesStep: 5,
          startDate: new Date($(fromDatePicker).data('startdate')),
          onSelect: function onSelect(_, selectedDate, instance) {
            $(instance.el).trigger("datepicker-change");
            selectedDate.setHours(selectedDate.getHours() + 1);
            if($(toDatePicker).length && selectedDate > $(toDatePicker).data('datepicker').lastSelectedDate) {
              $(toDatePicker).data('datepicker').selectDate(selectedDate);
            }
          }
        });

        var date = new Date($(fromDatePicker).data('startdate'));

        $(fromDatePicker).data('datepicker').selectDate(date);
        if($(toDatePicker).length){
          date = new Date($(toDatePicker).data('startdate'));
          $(toDatePicker).data('datepicker').selectDate(date);
        }
      } else {
        $(fromDatePicker).datepicker({
          autoClose: true,
          onSelect: function onSelect(_, selectedDate, instance) {
            $(instance.el).trigger("datepicker-change");
          }
        });
      }

      index++;
    });
  }
};

function initializePageWithOnlyOneDatepicker() {
  $('.air-datepicker').datepicker({
    autoClose: true,
    startDate: new Date($('.air-datepicker').data('startdate')),
    onSelect: function onSelect(_, selectedDate, instance) {
      $(instance.el).trigger("datepicker-change");
    }
  });
};