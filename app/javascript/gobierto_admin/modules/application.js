import 'air-datepicker'
import 'devbridge-autocomplete'
import 'magnific-popup'
import SimpleMDE from 'simplemde'
import 'sticky-kit/dist/sticky-kit.js'
import Turbolinks from 'turbolinks'
import { AUTOCOMPLETE_DEFAULTS } from '../../lib/shared'

$(document).on('turbolinks:load', function() {
  $(".stick_in_parent").stick_in_parent();

  addDatepickerBehaviors();
  initializeDatepickersWithoutBehavior();

  $('#site_visibility_level_active').on('click', function(){
    $('#site_username').val('');
    $('#site_password').val('');
  });

  $('a[data-disabled]').on('click', function(e){
    e.preventDefault();
  });

  $('input[autofocus]').focus();

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
        { name: "guide",
          action: function openlink() {
            var win = window.open("https://gobierto.readme.io/v0.1/docs/guia-de-markdown", "_blank");
            win.focus();
          },
          className: "fas fa-question-circle",
          title: "Markdown Guide",
        default: true },
        "|"],
      status: false
    });

    $el.data({ editor: simplemde });
    simplemde.codemirror.on("change", function(){
      var id = "#" + $el.attr('id').replace('_source', '');
      $(id).val(simplemde.markdown(simplemde.value()))
    });

    // Add event once it's rendered
    $(document).ready(() => toggleStickyToolbar($el))
  });
});

function datepickerStartDate($datepicker) {
  if ($datepicker.data("startdate")) {
    return new Date($datepicker.data("startdate"))
  } else if ($datepicker.data("allowBlank")) {
    return undefined
  } else {
    return new Date()
  }
}

function addDatepickerBehaviors() {
  let $datepickerWithBehavior = $('input[data-behavior!="none"].air-datepicker')

  if ($datepickerWithBehavior.length == 1) {
    initializePageWithOnlyOneDatepicker();
  } else if ($datepickerWithBehavior.length){
    var $fromDatePickers = $datepickerWithBehavior.filter(':even');
    var $toDatePickers = $datepickerWithBehavior.filter(':odd');

    $toDatePickers.each(function(index, toDatePicker) {
      let $toDatePicker = $(toDatePicker);

      // Check if properties were informed before set defaults
      const toDatePickerDEFAULTS = {
        autoClose: ($toDatePicker.data('autoclose') === undefined)
          ? true
          : ($toDatePicker.data('autoclose'))
      }

      // Datepicker end time
      let toDatePickerOPTIONS = {
        autoClose: toDatePickerDEFAULTS.autoClose,
        onSelect: function onSelect(a, selectedDate, instance) {
          if (instance.visible) $(instance.el).trigger("datepicker-change");

          // Updates first datepicker if end_date is earlier
          if (selectedDate < $fromDatePicker.data('datepicker').lastSelectedDate) {
            selectedDate.setHours(selectedDate.getHours() - 1)
            setDateOnBindedDatepicker(selectedDate, $fromDatePicker[0])
          }
        }
      }

      let toDatepickerDate = datepickerStartDate($toDatePicker);

      if (toDatepickerDate) toDatePickerOPTIONS.startDate = toDatepickerDate

      $toDatePicker.datepicker(toDatePickerOPTIONS);

      // Datepicker start time
      var $fromDatePicker = $($fromDatePickers[index]);
      let fromDatepickerDate = datepickerStartDate($fromDatePicker);

      // Check if properties were informed before set defaults
      const fromDatePickerDEFAULTS = {
        autoClose: ($fromDatePicker.data('autoclose') === undefined)
          ? true
          : ($fromDatePicker.data('autoclose')),
        minutesStep: ($fromDatePicker.data('minutesstep') === undefined)
          ? 5
          : ($fromDatePicker.data('minutesstep')),
        startDate: fromDatepickerDate
      }

      if ($fromDatePicker.data('range') === undefined) {
        $fromDatePicker.datepicker({
          autoClose: fromDatePickerDEFAULTS.autoClose,
          minutesStep: fromDatePickerDEFAULTS.minutesStep,
          startDate: fromDatePickerDEFAULTS.startDate,
          onSelect: function onSelect(_, selectedDate, instance) {
            if (instance.visible) $(instance.el).trigger("datepicker-change");

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

        if (fromDatepickerDate) $fromDatePicker.data("datepicker").selectDate(fromDatepickerDate);
        if (toDatepickerDate) $toDatePicker.data("datepicker").selectDate(toDatepickerDate);
      } else {
        $fromDatePicker.datepicker({
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
  const $datepickerWithBehavior = $('input[data-behavior!="none"].air-datepicker')

  // Check if properties were informed before set defaults
  const datePickerDEFAULTS = {
    autoClose: ($datepickerWithBehavior.data('autoclose') === undefined) ? true : ($datepickerWithBehavior.data('autoclose')),
    startDate: ($datepickerWithBehavior.data('startdate') === undefined) ? new Date() : new Date($datepickerWithBehavior.data('startdate'))
  }

  $('input[data-behavior!="none"].air-datepicker').datepicker({
    autoClose: datePickerDEFAULTS.autoClose,
    startDate: datePickerDEFAULTS.startDate,
    onSelect: function onSelect(_, selectedDate, instance) {
      $(instance.el).trigger("datepicker-change");
    }
  });

  // If a default value was set, force datepicker parse it so the TZ offset is
  // not shown to the user
  $('input[data-behavior!="none"].air-datepicker').each(function() {
    if (this.value && !$(this).data('range')) {
      var dateAttr = $(this).data('startdate');
      setDateOnBindedDatepicker(new Date(dateAttr), $(this));
    }
  });
}

function initializeSingleDatepicker(element) {
  let datepickerDEFAULTS = {
    autoClose: (element.data('autoclose') === undefined)
      ? true
      : (element.data('autoclose')),
      minutesStep: (element.data('minutesstep') === undefined)
        ? 5
        : (element.data('minutesstep')),
        startDate: (element.data('startdate') === undefined)
          ? new Date()
          : new Date(element.data('startdate')),
  }

  if (element.data('range') === undefined) {
    element.datepicker({
      autoClose: datepickerDEFAULTS.autoClose,
      minutesStep: datepickerDEFAULTS.minutesStep,
      startDate: datepickerDEFAULTS.startDate,
      onSelect: function onSelect(_, selectedDate, instance) {
        $(instance.el).trigger("datepicker-change");

        if ($(instance.el).data('bind')) {
          selectedDate.setHours(selectedDate.getHours() + 1)
        }
      }
    });
    var dateAttr = element.data('startdate');
    setDateOnBindedDatepicker(new Date(dateAttr), element);

    if (!element.data('allowBlank')){
      let date = new Date(element.data('startdate'));

      element.data('datepicker').selectDate(date);
    }
  } else {
    element.datepicker({
      autoClose: datepickerDEFAULTS.autoClose,
      onSelect: function onSelect(_, selectedDate, instance) {
        $(instance.el).trigger("datepicker-change");
      }
    });
  }
}

function initializeDatepickersWithoutBehavior() {
  let $datepickersWithoutBehavior = $('input[data-behavior="none"].air-datepicker')
  $datepickersWithoutBehavior.each(function(index, datepicker) {
    initializeSingleDatepicker($(datepicker))
  })
}

function setDateOnBindedDatepicker(date, datepicker) {
  if ($(datepicker).length) {
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

export { addDatepickerBehaviors, initializeDatepickersWithoutBehavior }
