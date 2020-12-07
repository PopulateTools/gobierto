// legacy
import { AUTOCOMPLETE_DEFAULTS } from "./modules/autocomplete_settings.js";
import { URLParams } from "./modules/URLParams.js";
import "./modules/module-search.js";
import "./modules/module-sessions.js";
import "./modules/module-site_header.js";
import "./modules/globals.js";
import d3locale from "./modules/d3-locale.js";
import { isDesktop, isMobile } from "./modules/globals.js";
import "./modules/tabs.js";
import "./modules/velocity_settings.js";
import "./modules/shareContent.js";
import "./modules/separate-tabs.js";
import accounting from "accounting";
import { SETTINGS } from "./modules/accounting_settings.js";
accounting.settings = SETTINGS;

// new modules
import { Datepicker } from "./modules/air-datepicker.js";
import { readMore } from "./modules/read-more.js";
import { HorizontalCarousel } from "./modules/horizontal-carousel.js";
import { ImageLightbox } from "./modules/image-lightbox.js";
import { RangeSlider } from "./modules/range-slider.js";
import {
  VueFiltersMixin,
  translate,
  money,
  date,
  truncate,
  percent
} from "./modules/vue-filters.js";
import {
  VueDirectivesMixin,
  clickoutside
} from "./modules/vue-directives.js";
import { Middleware } from "./modules/middleware.js";

export {
  AUTOCOMPLETE_DEFAULTS,
  accounting,
  d3locale,
  isDesktop,
  isMobile,
  URLParams,
  RangeSlider,
  Datepicker,
  readMore,
  HorizontalCarousel,
  ImageLightbox,
  VueFiltersMixin,
  Middleware,
  translate,
  money,
  date,
  truncate,
  percent,
  VueDirectivesMixin,
  clickoutside
};
