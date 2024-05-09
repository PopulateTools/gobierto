import 'regenerator-runtime';

// https://rossta.net/blog/importing-images-with-webpacker.html#images-in-rails-views
require.context('../../images', true)

// LEGACY DEPENDENCIES
import $ from 'jquery'
import 'jquery-ujs'
import * as I18n from 'i18n-js'

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

// NOTE: jQuery exposed to global (window for node environment) due to script directly in the view
global.$ = global.jQuery = $
global.I18n = I18n
