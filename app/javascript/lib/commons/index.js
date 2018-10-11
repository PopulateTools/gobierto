import $ from 'jquery'
import 'jquery-ujs'
import * as I18n from 'i18n-js'
import algoliasearch from 'algoliasearch'
import Turbolinks from 'turbolinks'

// NOTE: jQuery exposed to global (window for node environment) due to script directly in the view
global.$ = global.jQuery = $
global.I18n = I18n
global.algoliasearch = algoliasearch
Turbolinks.start()

// TODO: Esto podría ser dividido en pequeños módulos para inyectar solo las cosas necesarias
import 'lib/shared'

// OLD VERSIONS
//
//
//
// // Common
// import $ from 'jquery'
// import 'jquery-ujs'
// import * as I18n from 'i18n-js'
// import 'babel-polyfill' // NOTE: REQUIRED to use ES6 syntax (https://github.com/rails/webpacker/issues/523)
// import 'magnific-popup'
// import 'jquery-visible'
// import 'webpack-jquery-ui'
// import 'tipsy-1a'
// import 'velocity-animate'
// // Falta d3-voronoi (editado??)
// import 'devbridge-autocomplete'
// import algoliasearch from 'algoliasearch'
// import 'geocomplete'
// import 'jqtree'
// import 'select2'
// import 'fullcalendar'
// import 'mailcheck'
// import 'jsgrid'
//
// // Expose globals
// global.$ = global.jQuery = $; // NOTE: jQuery exposed to global (window for node environment) due to script directly in the view
// global.I18n = I18n
// global.algoliasearch = algoliasearch
