export const FieldTypeMixin = {
  data() {
    return {
      fieldType: null
    };
  },
  computed: {
    paragraphType() {
      return [
        "paragraph",
        "localized_paragraph",
        "string",
        "localized_string"
      ].includes(this.fieldType);
    },
    pluginType() {
      return this.fieldType === "plugin";
    },
    vocabularyType() {
      return this.fieldType === 'vocabulary_options'
    },
    imageType() {
      return this.fieldType === 'image'
    },
    selectionType() {
      return [
        "single_option",
        "multiple_options"
      ].includes(this.fieldType);
    },
    rawIndicatorsType() {
      // TODO: repasar
      return this.attributes.options.configuration.plugin_configuration.category_term_decorator === 'raw_indicators'
    }
  },
  created() {
    const { field_type } = this.attributes
    this.fieldType = field_type
  }
};
