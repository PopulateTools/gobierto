import { AUTOCOMPLETE_DEFAULTS } from './modules/autocomplete_settings.js'
import { URLParams } from './modules/URLParams.js'
import './modules/module-search.js'
import './modules/module-sessions.js'
import './modules/module-site_header.js'
import './modules/globals.js'
import d3locale from './modules/d3-locale.js'
import { isDesktop, isMobile } from './modules/globals.js'
import './modules/tabs.js'
import './modules/velocity_settings.js'
import './modules/air-datepicker.js'
import './modules/shareContent.js'

import accounting from 'accounting'
import { SETTINGS } from './modules/accounting_settings.js'
accounting.settings = SETTINGS

export {
  AUTOCOMPLETE_DEFAULTS,
  accounting,
  d3locale,
  isDesktop,
  isMobile,
  URLParams
}
