import SimpleMDE from 'simplemde'
import Turbolinks from 'turbolinks'
import 'devbridge-autocomplete'
import 'sticky-kit/dist/sticky-kit.js'
import 'air-datepicker'
import 'magnific-popup'
import { AUTOCOMPLETE_DEFAULTS } from 'lib/shared'

$(document).on('turbolinks:load', function() {
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

  $autocomplete.devbridgeAutocomplete($.extend({}, AUTOCOMPLETE_DEFAULTS, searchOptions));

  $('[data-wysiwyg]').each(function(){
    var $el = $(this);
    var simplemde = new SimpleMDE({
      element: $el[0],
      autofocus: false,
      forceSync: true,
      spellChecker: false,
      renderingConfig: {
        singleLineBreaks: false
      },
      toolbar: [
        "bold",
        "italic",
        "heading",
        "|",
        "quote",
        "unordered-list",
        "ordered-list",
        "|",
        "link",
        "image",
        "|",
        "preview",
        "side-by-side",
        "fullscreen",
        "|",
        {name: "guide",
          action: function openlink() {
            var win = window.open("https://gobierto.readme.io/v0.1/docs/guia-de-markdown", "_blank");
            win.focus();
          },
          className: "fas fa-question-circle",
          title: "Markdown Guide",
        default: true},
        "|"],
      status: false
    });

    $el.data({editor: simplemde});
    simplemde.codemirror.on("change", function(){
      var id = "#" + $el.attr('id').replace('_source', '');
      $(id).val(simplemde.markdown(simplemde.value()))
    });

    // Add event once it's rendered
    $(document).ready(() => toggleStickyToolbar($el))
  });
});

function addDatepickerBehaviors() {
  if ($('.air-datepicker').length == 1) {
    initializePageWithOnlyOneDatepicker();
  } else if($('.air-datepicker').length){
    var $fromDatePickers = $('.air-datepicker:even');
    var $toDatePickers   = $('.air-datepicker:odd');

    $toDatePickers.each(function(index, toDatePicker) {

      // Check if properties were informed before set defaults
      const toDatePickerDEFAULTS = {
        autoClose: ($(toDatePicker).data('autoclose') === undefined)
          ? true
          : ($(toDatePicker).data('autoclose')),
        startDate: ($(toDatePicker).data('startdate') === undefined)
          ? new Date()
          : new Date($(toDatePicker).data('startdate'))
      }

      // Datepicker end time
      $(toDatePicker).datepicker({
        autoClose: toDatePickerDEFAULTS.autoClose,
        startDate: toDatePickerDEFAULTS.startDate,
        onSelect: function onSelect(a, selectedDate, instance) {
          $(instance.el).trigger("datepicker-change");

          // Updates first datepicker if end_date is earlier
          if (selectedDate < $(fromDatePicker).data('datepicker').lastSelectedDate) {
            selectedDate.setHours(selectedDate.getHours() - 1)
            setDateOnBindedDatepicker(selectedDate, fromDatePicker)
          }
        }
      });

      // Datepicker start time
      var fromDatePicker = $fromDatePickers[index];

      // Check if properties were informed before set defaults
      const fromDatePickerDEFAULTS = {
        autoClose: ($(fromDatePicker).data('autoclose') === undefined)
          ? true
          : ($(fromDatePicker).data('autoclose')),
        minutesStep: ($(fromDatePicker).data('minutesstep') === undefined)
          ? 5
          : ($(fromDatePicker).data('minutesstep')),
        startDate: ($(fromDatePicker).data('startdate') === undefined)
          ? new Date()
          : new Date($(fromDatePicker).data('startdate')),
      }

      if($(fromDatePicker).data('range') === undefined) {
        $(fromDatePicker).datepicker({
          autoClose: fromDatePickerDEFAULTS.autoClose,
          minutesStep: fromDatePickerDEFAULTS.minutesStep,
          startDate: fromDatePickerDEFAULTS.startDate,
          onSelect: function onSelect(_, selectedDate, instance) {
            $(instance.el).trigger("datepicker-change");

            // data-bind=true links fromDatePicker to toDatePicker
            // on fromDatePicker selection, updates toDatePicker +1h
            if ($(instance.el).data('bind')) {
              selectedDate.setHours(selectedDate.getHours() + 1)
            }

            if (selectedDate > $(toDatePicker).data('datepicker').lastSelectedDate) {
              setDateOnBindedDatepicker(selectedDate, toDatePicker)
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
          autoClose: fromDatePickerDEFAULTS.autoClose,
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
  const $datepicker = $('.air-datepicker')

  // Check if properties were informed before set defaults
  const datePickerDEFAULTS = {
    autoClose: ($datepicker.data('autoclose') === undefined) ? true : ($datepicker.data('autoclose')),
    startDate: ($datepicker.data('startdate') === undefined) ? new Date() : new Date($datepicker.data('startdate'))
  }

  $('.air-datepicker').datepicker({
    autoClose: datePickerDEFAULTS.autoClose,
    startDate: datePickerDEFAULTS.startDate,
    onSelect: function onSelect(_, selectedDate, instance) {
      $(instance.el).trigger("datepicker-change");
    }
  });

  // If a default value was set, force datepicker parse it so the TZ offset is
  // not shown to the user
  $('.air-datepicker').each(function() {
    if (this.value) {
      var dateAttr = $(this).data('startdate');
      setDateOnBindedDatepicker(new Date(dateAttr), $(this));
    }
  });
}

function setDateOnBindedDatepicker(date, datepicker) {
  if($(datepicker).length) {
    $(datepicker).data('datepicker').selectDate(date);
  }
}

function toggleStickyToolbar(wysiwyg) {
  // Unique locale id
  const id = wysiwyg.attr("id").substring(0, wysiwyg.attr("id").length - 3)
  // Header height
  const headerHeight = $("header").height()
  // Toolbar from the element itself
  const toolbar = wysiwyg.siblings(".editor-toolbar")

  // Group who gathers the same form element toolbars, but different locales
  const localeToolbarGroup = wysiwyg.parent().parent().find(`[id^=${id}]`).siblings(".editor-toolbar")
  // If element is visible, get its offset, otherwise, get the visible offset height from its locale group
  const toolbarOffsetTop = toolbar.is(":visible")
    ? toolbar.offset().top - headerHeight
    : localeToolbarGroup.filter(":visible").offset().top - headerHeight

  $(window).on("scroll resize", function () {
    const scroll = $(this).scrollTop();
    // Add the height of the floating globalize tool, if exists
    const localeBarHeight = $('.is-floating .globalize_tool').outerHeight() || 0;

    if (toolbar.is(":visible")) {
      if (scroll > (toolbarOffsetTop - localeBarHeight)) {
        localeToolbarGroup.each((i, item) => {
          $(item).addClass("is-sticky");
          $(item).css({ top: `${headerHeight + localeBarHeight}px` });
        })
      } else if (toolbar.hasClass("is-sticky")) {
        localeToolbarGroup.each((i, item) => {
          $(item).removeClass("is-sticky");
          $(item).removeAttr("style");
        })
      }
    }
  })
}

export { addDatepickerBehaviors }
