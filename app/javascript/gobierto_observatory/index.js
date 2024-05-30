import { checkAndReportAccessibility } from '../lib/shared';
import '../../assets/stylesheets/observatory.scss';
import './modules/application.js';

document.addEventListener('DOMContentLoaded', () => {
  if (process.env.NODE_ENV === 'development') {
    checkAndReportAccessibility()
  }
});
