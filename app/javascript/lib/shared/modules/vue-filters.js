export const VueFiltersMixin = {
  filters: {
    translate(value) {
      const lang = I18n.locale || "es";
      return value[lang];
    },
    money(value) {
      const lang = I18n.locale || "es";
      if (value) {
        return value.toLocaleString(lang, { style: "currency", currency: "EUR" });
      }
    }
  }
};
