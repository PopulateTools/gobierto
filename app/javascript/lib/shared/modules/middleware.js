import { translate } from '../../../lib/vue/filters'

export class Middleware {
  constructor({ dictionary, filters }) {
    this.dictionary = dictionary || []
    this.filters = filters || []
  }

  getFilters(stats) {
    const filters = [];

    for (let index = 0; index < this.filters.length; index++) {
      const { id: key, allowedValues, hideDropdown, ...rest } = this.filters[index];
      const element = stats[key];
      const { field_type: type, vocabulary_terms: options = [], name_translations: title = {} } = this.getAttributesByKey(key);

      filters.push({
        ...element,
        ...rest,
        title: translate(title),
        options: Array.isArray(options) ? options.map(opt => ({ ...opt, title: translate(opt.name_translations) })) : [],
        type: type ? type : key,
        key,
        allowedValues,
        hideDropdown
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
