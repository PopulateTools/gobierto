export const FieldTypeMixin = {
  data() {
    return {
      fieldType: null,
      termDecorator: null
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
      return this.fieldType === "vocabulary_options";
    },
    imageType() {
      return this.fieldType === "image";
    },
    selectionType() {
      return ["single_option", "multiple_options"].includes(this.fieldType);
    },
    rawIndicatorsType() {
      return this.termDecorator === "raw_indicators";
    }
  },
  created() {
    const {
      field_type,
      options: {
        configuration: {
          plugin_configuration: { category_term_decorator } = {}
        } = {}
      } = {}
    } = this.attributes;
    this.fieldType = field_type;
    this.termDecorator = category_term_decorator;
  }
};
