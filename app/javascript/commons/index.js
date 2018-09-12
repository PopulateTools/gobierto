import $ from 'jquery'
import * as I18n from 'i18n-js'
import algoliasearch from 'algoliasearch'
import Turbolinks from 'turbolinks'

// NOTE: jQuery exposed to global (window for node environment) due to script directly in the view
global.$ = global.jQuery = $
global.I18n = I18n
global.algoliasearch = algoliasearch
Turbolinks.start()
