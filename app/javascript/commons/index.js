import $ from 'jquery'
import * as I18n from 'i18n-js'

global.$ = global.jQuery = $; // NOTE: jQuery exposed to global (window for node environment) due to script directly in the view
global.I18n = I18n
