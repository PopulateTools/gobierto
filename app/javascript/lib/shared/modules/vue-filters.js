/**
 * This Vue filters are widely used throughtout the application.
 * They're could be reused importing this module:
 *
 * import { VueFiltersMixin } from "lib/shared";
 *
 * and then, in a Vue App, like so:
 *
 * mixins: [VueFiltersMixin],
 *
 */
export const translate = (value = {}) => {
  const lang = I18n.locale || "es";
  // Look for the language key, fallback to the first found key
  return (Object.prototype.hasOwnProperty.call(value, lang) && value[lang]) ? value[lang] : value[Object.keys(value)[0]];
}

export const money = (value, opts = {}) => {
  const lang = I18n.locale || "es";
  const options = { style: "currency", currency: "EUR", ...opts }
  return value !== undefined && value !== null ? parseFloat(value).toLocaleString(lang, options) : undefined;
}

export const date = (value, opts = {}) => {
  const lang = I18n.locale || "es";
  return value instanceof Date ? value.toLocaleDateString(lang, opts) : new Date(value).toLocaleDateString(lang, opts);
}

export const truncate = (value, opts = {}) => {
  debugger

  const omission = opts['omission'] || '...';
  const length = opts['length'] || 30;

  return `${value.substring(0, length)}${omission}`
}

export const VueFiltersMixin = {
  methods: {
    translate,
    money,
    date,
    truncate
  },
  filters: {
    translate,
    money,
    date,
    truncate
  }
};
