import "../stylesheets/module-people.scss"
import './modules/init.js'
import './modules/application.js'
import './modules/person_events_controller.js'
import { checkAndReportAccessibility } from 'lib/shared'

document.addEventListener('DOMContentLoaded', () => {

  if (process.env.NODE_ENV === 'development') {
    checkAndReportAccessibility()
  }

});
