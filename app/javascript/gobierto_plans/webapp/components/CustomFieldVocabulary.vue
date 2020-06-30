<template>
  <div v-if="isSDG">
    <!-- this vocabulary has a different layout -->
    <CustomFieldVocabularySDG :attributes="attributes" />
  </div>
  <div v-else>
    <div
      v-for="{ id, attributes: { name } = {} } in vocabularies"
      :key="id"
    >
      {{ name }}
    </div>
  </div>
</template>

<script>
import { PlansStore } from "../lib/store";
import CustomFieldVocabularySDG from "./CustomFieldVocabularySDG.vue";

export default {
  name: "CustomFieldVocabulary",
  components: {
    CustomFieldVocabularySDG
  },
  props: {
    attributes: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      isSDG: false,
      vocabularies: []
    };
  },
  created() {
    const { sdg_uid = "" } = PlansStore.state.levelKeys
    const { value, vocabulary_terms, uid } = this.attributes;
    const elements = Array.isArray(value) ? value : [value]

    this.vocabularies = vocabulary_terms.filter(({ id }) => elements.includes(id))
    // true if the plan option sdg_uid mtches the attribute uid
    this.isSDG = sdg_uid === uid
  }
};
</script>
