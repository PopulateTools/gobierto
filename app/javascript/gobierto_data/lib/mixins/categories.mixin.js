export const CategoriesMixin = {
  methods: {
    getItem(element, attributes) {
      const attr = this.middleware.getAttributesByKey(element.id);

      let value = attributes[element.id];

      if (element.multiple) {
        value = this.translate(attributes[element.id][0].name_translations);
      }

      return {
        ...attr,
        ...element,
        name: this.translate(attr.name_translations),
        value: value
      };
    }
  }
}