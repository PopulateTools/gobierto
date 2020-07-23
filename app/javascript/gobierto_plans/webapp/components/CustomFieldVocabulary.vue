<template>
  <div v-if="isSDG">
    <!-- this vocabulary has a different layout -->
    <CustomFieldVocabularySDG :attributes="attributes" />
  </div>
  <div v-else>
    <template
      v-for="{ id, name, group, term, hasLink } in vocabularies"
    >
      <router-link
        v-if="hasLink"
        :key="id"
        :to="{ name: 'term', params: { ...params, id: group, term } }"
        class="project-description__link"
      >
        {{ name }}
      </router-link>
      <div
        v-else
        :key="id"
      >
        {{ name }}
      </div>
    </template>
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
  computed: {
    params() {
      return this.$route.params;
    }
  },
  created() {
    const { sdg_uid = "", fields_to_show_as_filters = [] } = PlansStore.state.options;
    const { value, vocabulary_terms, uid } = this.attributes;
    const elements = Array.isArray(value) ? value : [value];

    // true if the plan option sdg_uid mtches the attribute uid
    this.isSDG = sdg_uid === uid;

    // if the vocabulary belongs to the filters, make it linkable
    const vocabularyLinkable = fields_to_show_as_filters.includes(uid)

    // parse the vocabularies, sorting them by its name
    this.vocabularies = vocabulary_terms
      .reduce((acc, { id, attributes: { name = "", slug = "" } = {} }) => {
        if (elements.includes(id)) {
          acc.push({ id, name, group: uid, term: slug, hasLink: vocabularyLinkable });
        }
        return acc;
      }, [])
      .sort((a, b) => a.name > b.name ? 1 : -1);
  }
};
</script>
