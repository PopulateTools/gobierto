window.GobiertoPeople.PersonEventsController = (function() {

  function PersonEventsController() {}

  PersonEventsController.prototype.index = function(){
    if ($('#calendar').length) {
      _initializeFullCalendar(_reorganizeHTML);
    }
  };

  function _initializeFullCalendar(nextStep) {

    var onlyCalendar = window.location.search.indexOf("only_calendar") > -1;
    var currentPath = window.location.pathname.split('/');
    var eventsEndpoint = '/agendas/'+ currentPath[currentPath.length - 1] + '.json';

    $('#calendar').fullCalendar({
      locale: I18n.locale,
      events: function(start, end, timezone, callback) {
        var params = {
          start: start.format(),
          end: end.format()
        }
        if (onlyCalendar) {
          params.only_calendar = true;
        }

        $.ajax({
          url: eventsEndpoint,
          dataType: 'json',
          accepts: {
            text: 'application/json'
          },
          data: params,
          success: function(doc) {
            callback(doc.events);
          }
        });
      },
      header: {
        left: 'prev,next today',
        center: 'title',
        right: 'month,agendaWeek,agendaDay'
      },
      eventLimit: true,
      navLinks: true,
      buttonText: {
          today: I18n.t('gobierto_calendars.fullcalendar.today'),
          month: I18n.t('gobierto_calendars.fullcalendar.month'),
          week:  I18n.t('gobierto_calendars.fullcalendar.week'),
          day:   I18n.t('gobierto_calendars.fullcalendar.day')
      },
      defaultView: 'agendaWeek',
      height: 600,
      contentHeight: 600,
      firstDay: 1,
      scrollTime: '7:00:00',
      timeFormat: 'H:mm',
      views: {
        week: { columnFormat: 'ddd D/M' }
      },
      eventAfterRender: function() {
        /* What is this? It is a function created for when the calendar
        is inside a div with display none. We wait until the calendar
        is visible to be able to indicate the start time.*/
        setInterval(timeScrollToTime, 1000);
        function timeScrollToTime() {
          if ($('#calendar').is(':visible')) {
            setTimeout(function() {
              window.dispatchEvent(new Event('resize'));
              $(".fc-scroller").animate({
                  scrollTop: $('[data-time="07:00:00"]').position().top
              });
            })
            clearInterval(timeScrollToTime);
          }
        }
      }
    });
    nextStep();
  }

  function _reorganizeHTML() {
    // move list view inside calendar component
    $('#calendar').append($('.person_event-list'));

    // create a button to toggle the list view
    var $lastButton = $('.fc-right').find('.fc-corner-right');
    $lastButton.after("<button type='button' class='fc-state-default' data-behavior='show_list_view'>" + I18n.t('gobierto_calendars.fullcalendar.list') + "</button>");

    _addSwitchViewBehaviors();

    if ($('.person_event-list').is(':visible')) {
      hideFullcalendarViewItems();
    }
  }

  function _addSwitchViewBehaviors() {
    $('.fc-right > .fc-button-group > .fc-state-default').not('[data-behavior="show_list_view"]').click(function() {
      $('.person_event-list').hide();
      showFullCalendarViewItems();
    });

    $('[data-behavior="show_list_view"]').click(function() {
      $('.person_event-list').show();
      hideFullcalendarViewItems();
    });
  }

  function hideFullcalendarViewItems() {
    $('.fc-view-container').hide();
    $('.fc-left').hide();
    $('.fc-center').hide();
    $('.fc-button').removeClass('fc-state-active');
    $('[data-behavior="show_list_view"]').addClass('fc-state-active');
  }

  function showFullCalendarViewItems() {
    $('.fc-view-container').show();
    $('.fc-left').show();
    $('.fc-center').show();
    $('[data-behavior="show_list_view"]').removeClass('fc-state-active');
  }

  return PersonEventsController;
})();

window.GobiertoPeople.person_events_controller = new GobiertoPeople.PersonEventsController;
