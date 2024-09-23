<template>
  <td>
    <template v-if="column === 'progress'">
      {{ value | percent }}
    </template>
    <template v-else-if="column === 'starts_at' || column === 'ends_at'">
      {{ value | date }}
    </template>
    <template v-else-if="column === 'status_id'">
      {{ status }}
    </template>
    <template v-else-if="vocabularyType">
      {{ vocabularyValue }}
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
    vocabularyValue() {
      const { attributes: { name } = {} } = this.attributes.vocabulary_terms.find(x => x.id === this.value)
      return name
    }
  }
};
</script>
