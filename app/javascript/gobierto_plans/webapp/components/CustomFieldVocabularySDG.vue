<template>
  <div class="ods-goal__container">
    <div
      v-for="{ id, attributes: { slug } = {} } in sdgs"
      :key="id"
      class="ods-goal__content"
    >
      <a
        :href="`${baseUrl}/ods/${+slug}`"
        :class="`ods-goal ods-goal__${slug.padStart(2, 0)}__${locale}`"
      />
    </div>
  </div>
</template>

<script>
export default {
  name: "CustomFieldVocabularySDG",
  props: {
    attributes: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      baseUrl: this.$root.$data.baseurl,
      locale: I18n.locale,
      sdgs: []
    };
  },
  created() {
    const { value, vocabulary_terms } = this.attributes;
    const elements = Array.isArray(value) ? value : [value]

    this.sdgs = vocabulary_terms.filter(({ id, attributes: { level } = {} }) => elements.includes(id) && level === 0)
  }
};
</script>
