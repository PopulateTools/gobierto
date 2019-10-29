<template>
  <table
    v-if="items.length"
    class="investments-home-main--table"
  >
    <thead>
      <th
        v-for="column in columns"
        :key="column.id"
        class="investments-home-main--th"
      >
        <div>{{ column.name }}</div>
      </th>
    </thead>
    <tbody>
      <TableRow
        v-for="item in items"
        :key="item.id"
        :item="item"
      />
    </tbody>
  </table>
  <div v-else>
    {{ labelEmpty }}
  </div>
</template>

<script>
import TableRow from "./TableRow.vue";
import { GobiertoInvestmentsSharedMixin } from "../mixins/common.js";

export default {
  name: "Table",
  components: {
    TableRow
  },
  mixins: [GobiertoInvestmentsSharedMixin],
  props: {
    items: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      columns: [],
      labelEmpty: ""
    }
  },
  created() {
    this.labelEmpty = I18n.t("gobierto_investments.projects.empty");

    const { availableTableFields = [] } = this.items.length ? this.items[0] : {}
    this.columns = availableTableFields
  },
};
</script>