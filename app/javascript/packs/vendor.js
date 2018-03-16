// Common
import $ from 'jquery'
import 'jquery-ujs'
import * as I18n from 'i18n-js'
import 'magnific-popup'
import 'jquery-visible'
import 'webpack-jquery-ui'
import 'jquery.tipsy'
import 'mustache'
import 'velocity-animate'
import 'velocity-ui-pack'
// Falta d3-legend
// Falta d3-locale
// Falta d3-voronoi (editado??)
import 'jquery-autocomplete'
import 'algoliasearch'
import 'moment'

// Module admin
import 'geocomplete'
import 'jqtree'
import 'select2'
import 'air-datepicker' // NOTE: translations are imported in shared module
import 'sticky-kit/dist/sticky-kit.js'

// Expose globals
global.$ = global.jQuery = $; // NOTE: jQuery exposed to global (window for node environment) due to script directly in the view
global.I18n = I18n
