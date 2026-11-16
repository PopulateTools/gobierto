export const FieldTypeMixin = {
  data() {
    return {
      fieldType: null,
      pluginTypeName: null,
      tableColumns: [],
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
    // Plain tables only: tables with a term decorator have their own layout, and
    // vocabulary cells hold term ids that can't be shown as they are
    pluginTableType() {
      return (
        this.pluginType &&
        this.pluginTypeName === "table" &&
        !this.termDecorator &&
        this.tableColumns.every(({ type }) => type !== "vocabulary")
      );
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
          plugin_type,
          plugin_configuration: { category_term_decorator, columns = [] } = {},
          unit_type
        } = {}
      } = {}
    } = this.attributes;
    this.fieldType = field_type;
    this.pluginTypeName = plugin_type;
    this.tableColumns = columns;
    this.termDecorator = category_term_decorator;
    this.unitType = unit_type;
  }
};
