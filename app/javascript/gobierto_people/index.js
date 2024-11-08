import '../../assets/stylesheets/people.scss'
import './modules/application.js'
import { PersonEventsController } from './modules/person_events_controller';
import { checkAndReportAccessibility } from '../lib/shared'

function init() {
  new PersonEventsController()

  if (process.env.NODE_ENV === 'development') {
    checkAndReportAccessibility()
  }
}

// since turbolinks still activated in gobierto_people for links,
// we cannot use DOMContentLoaded, as the init function would it run twice
document.addEventListener('turbolinks:load', () => init());
