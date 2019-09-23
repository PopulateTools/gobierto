import $ from 'jquery'
import 'jquery-ujs'
import * as I18n from 'i18n-js'
import algoliasearch from 'algoliasearch'
import Turbolinks from 'turbolinks'
import cssVars from "css-vars-ponyfill"

// NOTE: jQuery exposed to global (window for node environment) due to script directly in the view
global.$ = global.jQuery = $
global.I18n = I18n
global.algoliasearch = algoliasearch

document.addEventListener("DOMContentLoaded", () => {
  const disableTurbolinks = document.querySelector("body[data-turbolinks='false']")

  // If we don't found at body level this tag, we enable Turbolinks by default
  if (!disableTurbolinks) {
    Turbolinks.start()
  }
})

// Allow IE use CSS custom variables. Initialization
cssVars({
  silent: true
})

// IE Polyfill, FIXME: delete this when babel >= 7.4.0 (https://stackoverflow.com/a/53332776/5020256)
if (window.NodeList && !NodeList.prototype.forEach) {
  NodeList.prototype.forEach = Array.prototype.forEach;
}

// TODO: Esto podría ser dividido en pequeños módulos para inyectar solo las cosas necesarias
import 'lib/shared'
