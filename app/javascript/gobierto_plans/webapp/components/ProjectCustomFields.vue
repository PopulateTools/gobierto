<template>
  <div class="project-description">
    <template v-if="pluginType">
      <template v-if="rawIndicatorsType">
        <div class="project-description__title">
          {{ attributes.name_translations | translate }}
        </div>

        <CustomFieldPluginRawIndicators :attributes="attributes" />
      </template>
      <template v-else>
        <!-- incomplete markups: plugin types progress & budgets -->
      </template>
    </template>

    <template v-else>
      <div class="project-description__list mb1">
        <div class="project-description__title">
          {{ attributes.name_translations | translate }}
        </div>

        <div class="project-description__desc">
          <template v-if="paragraphType">
            <CustomFieldParagraph :attributes="attributes" />
          </template>

          <template v-else-if="vocabularyType">
            <CustomFieldVocabulary :attributes="attributes" />
          </template>

          <template v-else-if="selectionType">
            <CustomFieldSelection :attributes="attributes" />
          </template>

          <template v-else-if="imageType">
            <CustomFieldImage :attributes="attributes" />
          </template>

          <template v-else-if="currencyType">
            <div
              v-for="value in values"
              :key="value"
            >
              {{ value | money }}
            </div>
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
import { translate, money } from "lib/vue/filters";
import { FieldTypeMixin } from "../lib/mixins/field-type";
import CustomFieldParagraph from "./CustomFieldParagraph.vue";
import CustomFieldPluginRawIndicators from "./CustomFieldPluginRawIndicators.vue";
import CustomFieldVocabulary from "./CustomFieldVocabulary.vue";
import CustomFieldSelection from "./CustomFieldSelection.vue";
import CustomFieldImage from "./CustomFieldImage.vue";

export default {
  name: "ProjectCustomFields",
  components: {
    CustomFieldParagraph,
    CustomFieldPluginRawIndicators,
    CustomFieldVocabulary,
    CustomFieldSelection,
    CustomFieldImage
  },
  filters: {
    translate,
    money
  },
  mixins: [FieldTypeMixin],
  props: {
    attributes: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      values: []
    };
  },
  created() {
    const { value } = this.attributes;

    if (value) {
      this.values = Array.isArray(value) ? value : [value];
    }
  }
};
</script>
