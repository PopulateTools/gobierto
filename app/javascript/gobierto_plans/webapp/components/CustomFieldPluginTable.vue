<template>
  <table class="project-table">
    <thead>
      <tr>
        <th
          v-for="{ id, name_translations } in columns"
          :key="id"
        >
          {{ name_translations | translate }}
        </th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="(row, index) in rows"
        :key="index"
      >
        <td
          v-for="column in columns"
          :key="column.id"
          :class="{ 'project-table__date': column.type === 'date' }"
        >
          {{ cellValue(row, column) }}
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script>
import { translate, date } from '../../../lib/vue/filters';

export default {
  name: "CustomFieldPluginTable",
  filters: {
    translate
  },
  props: {
    attributes: {
      type: Object,
      default: () => {}
    }
  },
  computed: {
    columns() {
      const {
        options: { configuration: { plugin_configuration: { columns = [] } = {} } = {} } = {}
      } = this.attributes;

      return columns;
    },
    rows() {
      const { value } = this.attributes;

      return Array.isArray(value) ? value : [];
    }
  },
  methods: {
    cellValue(row, { id, type }) {
      // Dates are stored as yyyy-mm-dd, read them in UTC so the day doesn't shift
      return type === "date" ? date(row[id], { timeZone: "UTC" }) : row[id];
    }
  }
};
</script>
