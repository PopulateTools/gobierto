// external dependencies
import $ from 'jquery'
import 'jquery-ujs'
import * as I18n from 'i18n-js'
import 'babel-polyfill' // NOTE: REQUIRED to use ES6 syntax (https://github.com/rails/webpacker/issues/523)
import algoliasearch from 'algoliasearch'
import Turbolinks from 'turbolinks'

global.$ = global.jQuery = $; // NOTE: jQuery exposed to global (window for node environment) due to script directly in the view
global.I18n = I18n
global.algoliasearch = algoliasearch
Turbolinks.start()

// local dependencies
import './modules/init.js'
import './modules/application.js'
import './modules/plan_types_controller.js'
