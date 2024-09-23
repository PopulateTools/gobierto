<template>
  <tr>
    <ActionLinesTableViewRowCell
      v-for="[column, value] in columns"
      :key="column"
      :column="column"
      :value="value"
      :attributes="getAttrs(column)"
    />
  </tr>
</template>

<script>
import ActionLinesTableViewRowCell from './ActionLinesTableViewRowCell.vue';
import { PlansStore } from '../lib/store';

export default {
  name: "ActionLinesTableViewRow",
  components: {
    ActionLinesTableViewRowCell
  },
  props: {
    model: {
      type: Object,
      default: () => {}
    },
    options: {
      type: Object,
      default: () => {}
    },
    defaultTableFields: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      columns: [],
    };
  },
  created() {
    const {
      show_table_extra_fields = this.defaultTableFields
    } = this.options;

    // name is always shown
    this.columns = [
      ["name", this.model.attributes.name],
      ...Object.entries(this.model.attributes)
        // NOTE: "status" field comes from the API as an attribute called "status_id"
        // however, the api endpoint /meta still saying the field name is "status"
        // hence, remove that suffix to match the value of that field
        .filter(x => show_table_extra_fields.includes(x[0].replace(/_id$/, "")))
        .sort((a, b) => show_table_extra_fields.indexOf(a[0]) - show_table_extra_fields.indexOf(b[0]))
    ]
  },
  methods: {
    getAttrs(column) {
      return PlansStore.state.meta.find(x => x.attributes.uid === column)?.attributes || {}
    }
  }
};
</script>
