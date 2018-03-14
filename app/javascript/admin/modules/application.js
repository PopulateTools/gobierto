import { AUTOCOMPLETE_DEFAULTS } from 'shared'

$(document).on('turbolinks:load', function() {
  $('.open_remote_modal').magnificPopup({
    type: 'ajax',
    removalDelay: 300,
    mainClass: 'mfp-fade',
    callbacks: {
      ajaxContentAdded: function() {
        window.GobiertoAdmin.process_stages_controller.form();
        window.GobiertoAdmin.globalized_forms_component.handleGlobalizedForm();
      }
    }
  });

  $(".stick_in_parent").stick_in_parent();

  addDatepickerBehaviors();

  $('#site_visibility_level_active').on('click', function(){
    $('#site_username').val('');
    $('#site_password').val('');
  });

  $('a[data-disabled]').on('click', function(e){
    e.preventDefault();
  });

  var $autocomplete = $('[data-autocomplete]');

  var searchOptions = {
    serviceUrl: $autocomplete.data('autocomplete'),
    onSelect: function(suggestion) {
      Turbolinks.visit(suggestion.data.url);
    }
  };

  $autocomplete.autocomplete($.extend({}, AUTOCOMPLETE_DEFAULTS, searchOptions));

  $('[data-wysiwyg]').each(function(){
    var $el = $(this);
    var simplemde = new SimpleMDE({
      element: $el[0],
      autofocus: true,
      forceSync: true,
      spellChecker: false,
      renderingConfig: {
        singleLineBreaks: false
      },
      status: false
    });

    $el.data({editor: simplemde});
    simplemde.codemirror.on("change", function(){
      var id = "#" + $el.attr('id').replace('_source', '');
      $(id).val(simplemde.markdown(simplemde.value()))
    });
  });
});

function addDatepickerBehaviors() {
  if ($('.air-datepicker').length == 1) {
    initializePageWithOnlyOneDatepicker();
  } else if($('.air-datepicker').length){
    var $fromDatePickers = $('.air-datepicker:even');
    var $toDatePickers   = $('.air-datepicker:odd');

    $toDatePickers.each(function(index, toDatePicker) {

      // Datepicker end time
      $(toDatePicker).datepicker({
        autoClose: true,
        startDate: new Date($(toDatePicker).data('startdate')),
        onSelect: function onSelect(a, b, instance) {
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
}

function initializePageWithOnlyOneDatepicker() {
  $('.air-datepicker').datepicker({
    autoClose: true,
    startDate: new Date($('.air-datepicker').data('startdate')),
    onSelect: function onSelect(_, selectedDate, instance) {
      $(instance.el).trigger("datepicker-change");
    }
  });
}
