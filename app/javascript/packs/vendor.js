// Common
import $ from 'jquery'
import 'jquery-ujs'
import * as I18n from 'i18n-js'
import 'babel-polyfill' // NOTE: REQUIRED to use ES6 syntax (https://github.com/rails/webpacker/issues/523)
import 'magnific-popup'
import 'jquery-visible'
import 'webpack-jquery-ui'
import 'tipsy-1a'
import 'velocity-animate'
import 'velocity-ui-pack'
// Falta d3-voronoi (editado??)
import 'jquery-autocomplete'
import algoliasearch from 'algoliasearch'
import 'geocomplete'
import 'jqtree'
import 'select2'
import 'air-datepicker' // NOTE: translations are imported in shared module
import 'sticky-kit/dist/sticky-kit.js'
import 'fullcalendar'
import 'mailcheck'
import 'jsgrid'

// Expose globals
global.$ = global.jQuery = $; // NOTE: jQuery exposed to global (window for node environment) due to script directly in the view
global.I18n = I18n
global.algoliasearch = algoliasearch
