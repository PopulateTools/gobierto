import '../../assets/stylesheets/budgets.scss';
import './modules/init.js';
// init.js must be first
import { checkAndReportAccessibility } from '../lib/shared';
import './modules/application.js';
import setDropdowns from './modules/dropdown.js';
import './modules/execution.js';
import './modules/indicators_controller.js';
import './modules/invoices_controller.js';
import './modules/receipt_controller.js';

document.addEventListener('DOMContentLoaded', () => {

  if (process.env.NODE_ENV === 'development') {
    checkAndReportAccessibility()
  }

});

document.addEventListener("turbolinks:load", () => setDropdowns())
