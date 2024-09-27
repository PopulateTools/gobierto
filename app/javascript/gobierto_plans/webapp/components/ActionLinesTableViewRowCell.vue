<template>
  <td :data-custom-field-slug="attributes.uid">
    <template v-if="column === 'progress'">
      {{ value | percent }}
    </template>
    <template v-else-if="column === 'starts_at' || column === 'ends_at'">
      {{ value | date }}
    </template>
    <template v-else-if="vocabularyType">
      <span :data-vocabulary-term-slug="vocabularySlug">{{ vocabularyValue }}</span>
    </template>
    <template v-else>
      {{ value }}
    </template>
  </td>
</template>

<script>
import { date, percent } from '../../../lib/vue/filters';
import { FieldTypeMixin } from '../lib/mixins/field-type';
import { NamesMixin } from '../lib/mixins/names';

export default {
  name: "ActionLinesTableViewRowCell",
  filters: {
    percent,
    date
  },
  mixins: [NamesMixin, FieldTypeMixin],
  props: {
    column: {
      type: String,
      default: ""
    },
    value: {
      type: [Number, String],
      default: ""
    },
    attributes: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      status: this.getStatus(this.value)
    }
  },
  computed: {
    vocabulary() {
      const { attributes: { name: value, slug } = {} } = this.attributes.vocabulary_terms.find(x => x.id === this.value.toString())
      return { value, slug }
    },
    vocabularyValue() {
      return this.vocabulary.value
    },
    vocabularySlug() {
      return this.vocabulary.slug
    },
  }
};
</script>
