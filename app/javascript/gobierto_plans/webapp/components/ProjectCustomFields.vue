<template>
  <div class="project-description">
    <template v-if="paragraphType">
      <CustomFieldParagraph :attributes="attributes" />
    </template>

    <template v-else-if="pluginType">
      <template v-if="attributes.options.configuration.plugin_type === 'table'">
        <CustomFieldTable :attributes="attributes" />
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
          <template v-if="attributes.uid === 'sdgs'">
            <CustomFieldSDG :attributes="attributes" />
          </template>

          <template v-else-if="fieldType === 'vocabulary_options'">
            <div
              v-for="{ id: idx, name_translations } in attributes.value"
              :key="idx"
            >
              {{ name_translations | translate }}
            </div>
          </template>

          <template v-else-if="Array.isArray(attributes.value)">
            <div
              v-for="value in attributes.value"
              :key="value"
            >
              {{ value }}
            </div>
          </template>

          <template v-else>
            {{ attributes.value }}
          </template>
        </div>
      </div>
    </template>
  </div>
</template>

<script>
import { translate } from "lib/shared";
import CustomFieldParagraph from "./CustomFieldParagraph.vue";
import CustomFieldTable from "./CustomFieldTable.vue";
import CustomFieldSDG from "./CustomFieldSDG.vue";

export default {
  name: "ProjectCustomFields",
  components: {
    CustomFieldParagraph,
    CustomFieldTable,
    CustomFieldSDG
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
      fieldType: null
    };
  },
  computed: {
    paragraphType() {
      return ['paragraph', 'localized_paragraph', 'string', 'localized_string'].includes(this.fieldType)
    },
    pluginType() {
      return this.fieldType === 'plugin'
    }
  },
  created() {
    const { field_type } = this.attributes;
    this.fieldType = field_type
  }
};
</script>
