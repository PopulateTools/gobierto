/**
 * This Vue utils are widely used throughout the application.
 * They're could be reused importing this module:
 *
 * import { VueUtilsMixin } from "lib/shared";
 *
 * and then, in a Vue App, like so:
 *
 * mixins: [VueUtilsMixin],
 *
 */
const translate = (value = {}) => {
  const lang = I18n.locale || "es";
  // Look for the language key, fallback to the first found key
  return (Object.prototype.hasOwnProperty.call(value, lang) && value[lang]) ? value[lang] : value[Object.keys(value)[0]];
}

const money = (value, opts = {}) => {
  const lang = I18n.locale || "es";
  const options = { style: "currency", currency: "EUR", ...opts }
  return value !== undefined && value !== null ? value.toLocaleString(lang, options) : undefined;
}

const date = (value, opts = {}) => {
  const lang = I18n.locale || "es";
  return value instanceof Date ? value.toLocaleDateString(lang, opts) : new Date(value).toLocaleDateString(lang, opts);
}

export const VueUtilsMixin = {
  methods: {
    translate,
    money,
    date
  },
  filters: {
    translate,
    money,
    date
  }
};
