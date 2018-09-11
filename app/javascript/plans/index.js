// external dependencies
import $ from 'jquery'
import * as I18n from 'i18n-js'
import algoliasearch from 'algoliasearch'

global.$ = global.jQuery = $; // NOTE: jQuery exposed to global (window for node environment) due to script directly in the view
global.I18n = I18n
global.algoliasearch = algoliasearch

import './modules/init.js'
// First module
import './modules/application.js'
import './modules/plan_types_controller.js'
