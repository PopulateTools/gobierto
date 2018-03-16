import { settings } from './modules/accounting_settings.js'
import { AUTOCOMPLETE_DEFAULTS } from './modules/autocomplete_settings.js'
import { Class } from './modules/klass.js'
import './modules/globals.js'
import { isDesktop, isMobile, rebindAll } from './modules/globals.js'
import './modules/tabs.js'
import './modules/velocity_settings.js'
import '../i18n/translations.js'
import '../i18n/air-datepicker.js'
import SimpleMDE from 'simplemde'
import Turbolinks from 'turbolinks'
import Cropper from 'cropperjs'
import accounting from 'accounting'
import CodeMirror from 'codemirror'
import d3 from 'd3'
import Cleave from 'cleave.js'
import Vue from 'vue'

// Initializations
accounting.settings = settings
Turbolinks.start()

export { AUTOCOMPLETE_DEFAULTS, Class, d3, accounting, SimpleMDE, Cropper, CodeMirror, Cleave, Turbolinks, isDesktop, isMobile, rebindAll, Vue }