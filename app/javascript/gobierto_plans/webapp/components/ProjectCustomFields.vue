<template>
  <div class="project-description">
    <template v-if="paragraphType">
      <CustomFieldParagraph :attributes="attributes" />
    </template>

    <template v-else-if="pluginType">
      <template v-if="attributes.options.configuration.plugin_configuration.category_term_decorator === 'raw_indicators'">
        <CustomFieldPluginRawIndicators :attributes="attributes" />
      </template>
      <template v-else>
        <!-- incomplete markups: plugin types progress & budgets -->
      </template>
    </template>

    <template v-else>
      <div class="description-list mb1">
        <div class="description-title">
          {{ attributes.name_translations | translate }}
        </div>

        <div class="description-desc">
          <template v-if="fieldType === 'vocabulary_options'">
            <CustomFieldVocabulary :attributes="attributes" />
          </template>

          <template v-else>
            <div
              v-for="value in values"
              :key="value"
            >
              {{ value }}
            </div>
          </template>
        </div>
      </div>
    </template>
  </div>
</template>

<script>
import { translate } from "lib/shared";
import CustomFieldParagraph from "./CustomFieldParagraph.vue";
import CustomFieldPluginRawIndicators from "./CustomFieldPluginRawIndicators.vue";
import CustomFieldVocabulary from "./CustomFieldVocabulary.vue";

export default {
  name: "ProjectCustomFields",
  components: {
    CustomFieldParagraph,
    CustomFieldPluginRawIndicators,
    CustomFieldVocabulary
  },
  filters: {
    translate
  },
  props: {
    attributes: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      fieldType: null,
      values: []
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
    }
  },
  created() {
    const { field_type, value } = this.attributes;
    this.fieldType = field_type;
    this.values = Array.isArray(value) ? value : [value];
  }
};
</script>
