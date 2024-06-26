// Run this files BEFORE everything to avoid JS "imports" hoisting
import './modules/jquery';
import './modules/i18n';

import Rails from "@rails/ujs";
Rails.start()

// NOTE: these modules are required for the legacy views
import './modules/module-search';
import './modules/module-sessions';
import './modules/module-site_header';
import './modules/magnific-popup';
import './modules/globals.js';
import './modules/tabs';
import './modules/velocity_settings';
import './modules/shareContent';
import './modules/separate-tabs';
import './modules/check-start-turbolinks';
import './modules/iframe_handler';
