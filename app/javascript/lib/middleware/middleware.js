import { translate } from "lib/shared"

export default class Middleware {
  constructor({ dictionary, availableFilters }) {
    this.dictionary = dictionary || []
    this.availableFilters = availableFilters || []
  }

  getFilters(stats) {
    const filters = [];

    for (let index = 0; index < this.availableFilters.length; index++) {
      const { id: key, ...rest } = this.availableFilters[index];
      const element = stats[key];
      const { field_type: type, vocabulary_terms: options = [], name_translations: title = {} } = this.getAttributesByKey(key);

      filters.push({
        ...element,
        ...rest,
        title: translate(title),
        options: Array.isArray(options) ? options.map(opt => ({ ...opt, title: translate(opt.name_translations) })) : [],
        type: type ? type : key,
        key
      });
    }

    return filters;
  }

  getAttributesByKey(prop) {
    const { attributes = {} } =
      this.dictionary.find(entry => {
        const { attributes: { uid = "" } = {} } = entry;
        return uid === prop;
      }) || {};

    return attributes;
  }
}