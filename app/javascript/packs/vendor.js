// Common
// import 'jquery' (defined in webpack.config as global)
import 'jquery-ujs'
import * as Turbolinks from 'turbolinks'
import * as I18n from 'i18n-js'
import 'magnific-popup'
import 'jquery-visible'
import 'webpack-jquery-ui'
import 'jquery.tipsy'
import 'mustache'
import 'velocity-animate'
import 'velocity-ui-pack'
// import 'lodash' (defined in webpack.config as global)
import * as d3 from 'd3'
// Falta d3-legend
// Falta d3-locale
// Falta d3-voronoi (editado??)
import * as accounting from 'accounting'
import 'jquery-autocomplete'
import 'algoliasearch'
import 'moment'

// Module admin
import 'geocomplete'
import 'cleave.js'
import 'jquery.tipsy'
import 'jqtree'
import 'codemirror'
import 'select2'
import 'cropperjs'
import 'air-datepicker'
import 'sticky-kit/dist/sticky-kit.js'
import 'simplemde'

// Initializations
window.d3 = d3
window.accounting = accounting
window.I18n = I18n
// import '../i18n/translations.js' TODO

Turbolinks.start()