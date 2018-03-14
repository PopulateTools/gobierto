import { settings } from './modules/accounting_settings.js'
import { AUTOCOMPLETE_DEFAULTS } from './modules/autocomplete_settings.js'
import { Class } from './modules/klass.js'
import './modules/globals.js'
import './modules/tabs.js'
import './modules/velocity_settings.js'
import '../i18n/translations.js'
import SimpleMDE from 'simplemde'
import Turbolinks from 'turbolinks'
import Cropper from 'cropperjs'
import accounting from 'accounting'

// Initializations
accounting.settings = settings
Turbolinks.start()

export { AUTOCOMPLETE_DEFAULTS, Class, accounting, SimpleMDE, Cropper }