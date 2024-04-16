import "../stylesheets/gobierto-people.scss"
import './modules/init.js'
import './modules/application.js'
import './modules/person_events_controller.js'
import { checkAndReportAccessibility, appsignal } from 'lib/shared'

appsignal.wrap(() => {
  document.addEventListener('DOMContentLoaded', () => {

    if (process.env.NODE_ENV === 'development') {
      checkAndReportAccessibility()
    }

  });
})
