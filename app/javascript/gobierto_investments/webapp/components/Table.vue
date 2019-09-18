<template>
  <table class="investments-home-main--table">
    <thead>
      <th
        v-for="column in columns"
        :key="column.key"
        class="investments-home-main--th"
      >
        <div>{{ column.key }}</div>
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
</template>

<script>
import TableRow from "./TableRow.vue";
import { CommonsMixin } from "../mixins/common.js";

export default {
  name: "Table",
  components: {
    TableRow
  },
  mixins: [CommonsMixin],
  props: {
    items: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      columns: [],
    }
  },
  created() {
    const { availableTableFields = [] } = this.items[0]
    this.columns = availableTableFields
  },
};
</script>