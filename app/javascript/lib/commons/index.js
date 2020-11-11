/**
 *
 * POLYFILLS
 *
 */
import "core-js/stable";
import "regenerator-runtime/runtime";
import cssVars from "css-vars-ponyfill"

cssVars() // Allow IE use CSS custom variables. Initialization

/**
 *
 * DEPENDENCIES
 *
 */
import $ from 'jquery'
import 'jquery-ujs'
import * as I18n from 'i18n-js'
import Turbolinks from 'turbolinks'

// NOTE: jQuery exposed to global (window for node environment) due to script directly in the view
global.$ = global.jQuery = $
global.I18n = I18n

document.addEventListener("DOMContentLoaded", () => {
  const disableTurbolinks = document.querySelector("body[data-turbolinks='false']")

  // If we don't found at body level this tag, we enable Turbolinks by default
  if (!disableTurbolinks) {
    Turbolinks.start()
  }
});

// TODO: Esto podría ser dividido en pequeños módulos para inyectar solo las cosas necesarias
import 'lib/shared'
