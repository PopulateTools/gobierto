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
import { datepicker } from "./modules/air-datepicker.js";
import "./modules/shareContent.js";
import { readMore } from "./modules/read-more.js";
import { HorizontalCarousel } from "./modules/horizontal-carousel.js";
import { ImageLightbox } from "./modules/image-lightbox.js";
import "./modules/separate-tabs.js";
import { rangeSlider } from "./modules/range-slider.js";
import { VueFiltersMixin } from "./modules/vue-filters.js";

import accounting from "accounting";
import { SETTINGS } from "./modules/accounting_settings.js";
accounting.settings = SETTINGS;

export {
  AUTOCOMPLETE_DEFAULTS,
  accounting,
  d3locale,
  isDesktop,
  isMobile,
  URLParams,
  rangeSlider,
  datepicker,
  readMore,
  HorizontalCarousel,
  ImageLightbox,
  VueFiltersMixin
};
