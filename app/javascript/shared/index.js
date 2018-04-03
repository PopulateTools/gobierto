import { settings } from './modules/accounting_settings.js'
import { AUTOCOMPLETE_DEFAULTS } from './modules/autocomplete_settings.js'
import { Class } from './modules/klass.js'
import './modules/module-search.js'
import './modules/module-sessions.js'
import './modules/module-site_header.js'
import './modules/globals.js'
import d3locale from './modules/d3-locale.js'
import { isDesktop, isMobile } from './modules/globals.js'
import './modules/tabs.js'
import './modules/velocity_settings.js'
import './modules/air-datepicker.js'
import '../i18n/translations.js'
import moment from 'moment'
import SimpleMDE from 'simplemde'
import Turbolinks from 'turbolinks'
import Cropper from 'cropperjs'
import accounting from 'accounting'
import CodeMirror from 'codemirror' // NOTE: Addons not included
import Cleave from 'cleave.js'
import Vue from 'vue'
// https://www.giacomodebidda.com/how-to-import-d3-plugins-with-webpack/
import * as d3v4Base from 'd3v4'
import * as d3v3Base from 'd3' // required to run dc.js
import d3Legend from 'd3-svg-legend'
import { wordwrap, parseAttributes, f, ascendingKey, descendingKey, conventions, drawAxis, attachTooltip, loadData, nestBy, round, clamp, polygonClip } from 'd3-jetpack' // NOTE: some methods returned conflict with d3v4, so must select
import * as flight from 'flightjs'
import Mustache from 'mustache'
import crossfilter from 'crossfilter2'
import * as dc from 'dc'

// Initializations
accounting.settings = settings
Turbolinks.start()
const d3 = Object.assign(d3v4Base, d3Legend, { wordwrap, parseAttributes, f, ascendingKey, descendingKey, conventions, drawAxis, attachTooltip, loadData, nestBy, round, clamp, polygonClip });
const d3v3 = Object.assign(d3v3Base, d3Legend, { wordwrap, parseAttributes, f, ascendingKey, descendingKey, conventions, drawAxis, attachTooltip, loadData, nestBy, round, clamp, polygonClip });

export {
  AUTOCOMPLETE_DEFAULTS,
  Class,
  d3,
  d3v3,
  d3locale,
  accounting,
  moment,
  SimpleMDE,
  Cropper,
  CodeMirror,
  Cleave,
  Turbolinks,
  isDesktop,
  isMobile,
  Vue,
  Mustache,
  flight,
  crossfilter,
  dc
}
