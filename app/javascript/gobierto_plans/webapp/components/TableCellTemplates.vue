<template>
  <div>
    <template v-if="column === 'name'">
      <div
        class="planification-table__td-name"
        @click="setCurrentProject"
      >
        {{ value }}
      </div>
    </template>
    <template v-else-if="column === 'progress'">
      {{ value | percent }}
    </template>
    <template v-else-if="column === 'starts_at' || column === 'ends_at'">
      {{ value | date }}
    </template>
    <template v-else-if="vocabularyType">
      <CustomFieldVocabulary :attributes="attributes" />
    </template>
    <template v-else-if="imageType">
      <CustomFieldImage :attributes="attributes" />
    </template>
    <template v-else-if="selectionType">
      <CustomFieldSelection :attributes="attributes" />
    </template>
    <template v-else-if="paragraphType">
      <CustomFieldParagraph :attributes="attributes" />
    </template>
    <template v-else-if="rawIndicatorsType">
      <CustomFieldPluginRawIndicators :attributes="attributes" />
    </template>
    <template v-else>
      {{ value }}
    </template>
  </div>
</template>

<script>
import CustomFieldVocabulary from "../components/CustomFieldVocabulary.vue";
import CustomFieldImage from "../components/CustomFieldImage.vue";
import CustomFieldSelection from "../components/CustomFieldSelection.vue";
import CustomFieldParagraph from "../components/CustomFieldParagraph.vue";
import CustomFieldPluginRawIndicators from "../components/CustomFieldPluginRawIndicators.vue";
import { FieldTypeMixin } from "../lib/mixins/field-type";
import { percent, date } from "lib/vue/filters";

export default {
  name: "TableCellTemplates",
  components: {
    CustomFieldVocabulary,
    CustomFieldImage,
    CustomFieldSelection,
    CustomFieldParagraph,
    CustomFieldPluginRawIndicators
  },
  filters: {
    percent,
    date
  },
  mixins: [FieldTypeMixin],
  props: {
    attributes: {
      type: Object,
      default: () => {}
    },
    column: {
      type: String,
      default: null
    },
  },
  data() {
    return {
      id: null,
      value: null,
    }
  },
  created() {
    const { value, id } = this.attributes
    this.id = id
    this.value = value
  },
  methods: {
    setCurrentProject() {
      this.$emit('current-project', this.id)
    }
  }
};
</script>
