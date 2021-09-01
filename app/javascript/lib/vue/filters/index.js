export const translate = (value = {}) => {
  const lang = I18n.locale || "es";
  // Look for the language key, fallback to the first found key
  return Object.prototype.hasOwnProperty.call(value, lang) && value[lang]
    ? value[lang]
    : value[Object.keys(value)[0]];
};

export const money = (value, opts = {}) => {
  const lang = I18n.locale || "es";
  const options = { style: "currency", currency: "EUR", ...opts };
  return value !== undefined && value !== null
    ? parseFloat(value).toLocaleString(lang, options)
    : undefined;
};

export const date = (value, opts = {}) => {
  if (!value) return null
  const lang = I18n.locale || "es";
  return value instanceof Date
    ? value.toLocaleDateString(lang, opts)
    : new Date(value).toLocaleDateString(lang, opts);
};

export const truncate = (value = "", opts = {}) => {
  const { length = 30, omission = "…" } = opts
  return value.length <= length
    ? value
    : `${value.substring(0, length)}${omission}`
};

export const percent = value => {
  if (typeof value !== "number") return;
  return (value / 100).toLocaleString(I18n.locale, {
    style: "percent",
    maximumFractionDigits: 1
  });
};

export const VueFiltersMixin = {
  methods: {
    translate,
    money,
    date,
    truncate,
    percent
  },
  filters: {
    translate,
    money,
    date,
    truncate,
    percent
  }
};
