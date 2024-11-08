import { Calendar } from '@fullcalendar/core';
import dayGridPlugin from '@fullcalendar/daygrid';
import timeGridPlugin from '@fullcalendar/timegrid';

export class PersonEventsController {
  constructor() {
    const calendarEl = document.getElementById('calendar');

    if (calendarEl) {
      var onlyCalendar = window.location.search.indexOf("only_calendar") > -1;
      var currentPath = window.location.pathname.split('/');
      var eventsEndpoint = '/agendas/'+ currentPath[currentPath.length - 1] + '.json';

      const calendar = new Calendar(calendarEl, {
        plugins: [dayGridPlugin, timeGridPlugin],
        locale: I18n.locale,
        events: function ({ startStr, endStr }, successCallback) {
          var params = {
            start: startStr,
            end: endStr,
          };
          if (onlyCalendar) {
            params.only_calendar = true;
          }

          fetch(`${eventsEndpoint}?${new URLSearchParams(params).toString()}`)
            .then((r) => r.json())
            .then((doc) => successCallback(doc.events));
        },
        headerToolbar: {
          left: "prev,next today",
          center: "title",
          right: "dayGridMonth,timeGridWeek,timeGridDay",
        },
        dayMaxEventRows: true,
        navLinks: true,
        buttonText: {
          today: I18n.t("gobierto_calendars.fullcalendar.today"),
          month: I18n.t("gobierto_calendars.fullcalendar.month"),
          week: I18n.t("gobierto_calendars.fullcalendar.week"),
          day: I18n.t("gobierto_calendars.fullcalendar.day"),
        },
        initialView: "timeGridWeek",
        height: 600,
        contentHeight: 600,
        firstDay: 1,
        scrollTime: "7:00:00",
        eventTimeFormat: {
          hour: 'numeric',
          minute: '2-digit',
          meridiem: 'short'
        }
      });

      calendar.render();

      // custom modifications
      reorganizeHTML(calendar)
    }
  }
}

// replaces jquery: el.is(":visible")
function isVisible(el) {
  return !!(el.offsetWidth || el.offsetHeight || el.getClientRects().length);
}

function reorganizeHTML(calendar) {
  const listView = document.querySelector('.person_event-list')

  // move list view inside calendar component
  calendar.el.append(listView);

  // create a button to toggle the list view
  var lastButton = calendar.el.querySelector('.fc-timeGridDay-button');

  const listButton = lastButton.cloneNode(true)
  listButton.textContent = I18n.t('gobierto_calendars.fullcalendar.list')
  listButton.title = `${I18n.t('gobierto_calendars.fullcalendar.list')} view`
  listButton.dataset.behavior = "show_list_view"
  listButton.classList.add("fc-list-button")
  listButton.classList.remove("fc-timeGridDay-button")

  lastButton.after(listButton);

  // get all buttons configured in the right toolbar
  const toolbarRightOptions = calendar.getOption("headerToolbar").right.split(",")
  const originalRightButtons = calendar.el.querySelectorAll(
    toolbarRightOptions.map(
      (x) => `button[class*=${x}]:not([data-behavior='show_list_view'])`
    )
  );

  originalRightButtons.forEach((elem) =>
    elem.addEventListener("click", function () {
      listView.style.display = "none";
      showFullCalendarViewItems({ calendar, originalRightButtons, listButton });
    }, { capture: true }) // capture: true, to make sure this event precedes the original library event
  );

  listButton.addEventListener("click", function () {
    listView.style.display = "";
    hideFullcalendarViewItems({ calendar, originalRightButtons, listButton });
  });

  if (isVisible(listView)) {
    hideFullcalendarViewItems();
  }
}

function hideFullcalendarViewItems({
  calendar,
  originalRightButtons,
  listButton,
}) {
  calendar.el.querySelector(".fc-view-harness").style.display = "none";

  Array.from(calendar.el.querySelector(".fc-toolbar").children)
    .slice(0, 2)
    .forEach((elem) => (elem.style.visibility = "hidden"));

  originalRightButtons.forEach((elem) =>
    elem.classList.remove("fc-button-active")
  );

  listButton.classList.add("fc-button-active");
}

function showFullCalendarViewItems({ calendar, listButton }) {
  calendar.el.querySelector(".fc-view-harness").style.display = "";

  Array.from(calendar.el.querySelector(".fc-toolbar").children)
    .slice(0, 2)
    .forEach((elem) => (elem.style.visibility = ""));

  listButton.classList.remove("fc-button-active");
}
