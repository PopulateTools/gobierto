/**
 *
 * POLYFILLS
 *
 */
import "core-js/stable";
import "regenerator-runtime/runtime";

// https://attacomsian.com/blog/javascript-dom-detect-internet-explorer-browser
if (document.documentMode) {
  import("css-vars-ponyfill").then(({ default: cssVars }) => {
    cssVars() // Allow IE use CSS custom variables. Initialization
  })
}

/**
 *
 * DEPENDENCIES
 *
 */
import $ from 'jquery'
import 'jquery-ujs'
import * as I18n from 'i18n-js'
import Turbolinks from 'turbolinks'
import { handleIFramePageLoaded } from "../shared/modules/iframe_handler.js";

//NOTE: these modules are required
import "./modules/module-search.js";
import "./modules/module-sessions.js";
import "./modules/module-site_header.js";
import "./modules/magnific-popup.js";
import "./modules/tabs.js";
import "./modules/velocity_settings.js";
import "./modules/shareContent.js";
import "./modules/separate-tabs.js";

// NOTE: jQuery exposed to global (window for node environment) due to script directly in the view
global.$ = global.jQuery = $
global.I18n = I18n

document.addEventListener("DOMContentLoaded", () => {
  const disableTurbolinks = document.querySelector("body[data-turbolinks='false']")

  // If we don't found at body level this tag, we enable Turbolinks by default
  if (!disableTurbolinks) {
    Turbolinks.start()
  }
})

$(document).on("turbolinks:load", () => {
  handleIFramePageLoaded()
})

