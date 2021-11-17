// POLYFILLS
import "core-js/stable";
import "regenerator-runtime/runtime";

// https://rossta.net/blog/importing-images-with-webpacker.html#images-in-rails-views
require.context('../../images', true)

// https://attacomsian.com/blog/javascript-dom-detect-internet-explorer-browser
if (document.documentMode) {
  import("css-vars-ponyfill").then(({ default: cssVars }) => {
    cssVars() // Allow IE use CSS custom variables. Initialization
  })
}

// LEGACY DEPENDENCIES
import $ from 'jquery'
import 'jquery-ujs'
import * as I18n from 'i18n-js'

// NOTE: these modules are required for the legacy views
import "./modules/module-search";
import "./modules/module-sessions";
import "./modules/module-site_header";
import "./modules/magnific-popup";
import "./modules/tabs";
import "./modules/velocity_settings";
import "./modules/shareContent";
import "./modules/separate-tabs";
import "./modules/disable-turbolinks";
import "./modules/iframe_handler";

// COMMON STYLES
import "../../stylesheets/application.scss"

// NOTE: jQuery exposed to global (window for node environment) due to script directly in the view
global.$ = global.jQuery = $
global.I18n = I18n
