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
const translate = (value = {}) => {
  const lang = I18n.locale || "es";
  // Look for the language key, fallback to the first found key
  return (Object.prototype.hasOwnProperty.call(value, lang) && value[lang]) ? value[lang] : value[Object.keys(value)[0]];
}

export const VueFiltersMixin = {
  methods: {
    translate
  },
  filters: {
    translate,
    money(value, opts = {}) {
      const lang = I18n.locale || "es";
      const options = { style: "currency", currency: "EUR", ...opts }
      return value !== undefined && value !== null ? value.toLocaleString(lang, options) : undefined;
    },
    date(value, opts = {}) {
      const lang = I18n.locale || "es";
      return value instanceof Date ? value.toLocaleDateString(lang, opts) : new Date(value).toLocaleDateString(lang, opts);
    },
    tableList(value, opts = {}) {
      const options = { values: [], ...opts }
      return value.map(el => (`${el[options.header] || el[Object.keys(el)[0]]}: ${options.values.map(val => (el[val]))}`));
    }
  }
};
