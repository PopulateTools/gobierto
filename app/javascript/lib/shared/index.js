// legacy
import { AUTOCOMPLETE_DEFAULTS } from "./modules/autocomplete_settings.js";
import { URLParams } from "./modules/URLParams.js";
import d3locale from "./modules/d3-locale.js";
import { createScaleColors } from "./modules/createScaleColors.js";
import { slugString } from "./modules/slugString.js";
import accounting from "accounting";
import { SETTINGS } from "./modules/accounting_settings.js";
accounting.settings = SETTINGS;

// new modules
import { Datepicker } from "./modules/air-datepicker.js";
import { readMore } from "./modules/read-more.js";
import { HorizontalCarousel } from "./modules/horizontal-carousel.js";
import { ImageLightbox } from "./modules/image-lightbox.js";
import { RangeSlider } from "./modules/range-slider.js";
import { Middleware } from "./modules/middleware.js";
import { debounce } from "./modules/debounce.js";
import { checkAndReportAccessibility } from "./modules/accessibility.js";
import { groupBy } from "./modules/groupBy.js";
import { formatNumbers } from "./modules/d3-format-numbers.js";

export {
  AUTOCOMPLETE_DEFAULTS,
  accounting,
  createScaleColors,
  d3locale,
  URLParams,
  RangeSlider,
  Datepicker,
  readMore,
  HorizontalCarousel,
  ImageLightbox,
  Middleware,
  slugString,
  debounce,
  checkAndReportAccessibility,
  groupBy,
  formatNumbers
};
