export const FieldTypeMixin = {
  data() {
    return {
      fieldType: null,
      termDecorator: null,
      unitType: null,
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
    },
    currencyType() {
      return this.fieldType === "numeric" && this.unitType === "currency";
    },
  },
  created() {
    const {
      field_type,
      options: {
        configuration: {
          plugin_configuration: { category_term_decorator } = {},
          unit_type
        } = {}
      } = {}
    } = this.attributes;
    this.fieldType = field_type;
    this.termDecorator = category_term_decorator;
    this.unitType = unit_type;
  }
};
