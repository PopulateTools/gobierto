import "../stylesheets/gobierto-budgets.scss"
import "./modules/init.js";
// init.js must be first
import "./modules/application.js";
import "./modules/execution.js";
import "./modules/indicators_controller.js";
import "./modules/invoices_controller.js";
import "./modules/receipt_controller.js";
import setDropdowns from "./modules/dropdown.js";
import { checkAndReportAccessibility, appsignal } from 'lib/shared'

appsignal.wrap(() => {
  document.addEventListener('DOMContentLoaded', () => {

    if (process.env.NODE_ENV === 'development') {
      checkAndReportAccessibility()
    }

  });

  document.addEventListener("turbolinks:load", () => setDropdowns())
})
