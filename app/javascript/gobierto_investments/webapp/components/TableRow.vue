<template>
  <tr
    class="investments-home-main--tr"
    @click="nav(item.id)"
  >
    <td
      v-for="column in columns"
      :key="column.id"
      class="investments-home-main--td"
    >
      <div v-if="column.filter === 'money'">
        {{ column.value | money }}
      </div>
      <div v-else-if="column.filter === 'translate'">
        {{ column.value | translate }}
      </div>
      <div v-else>
        {{ column.value }}
      </div>
    </td>
  </tr>
</template>

<script>
import { CommonsMixin } from "../mixins/common.js";

export default {
  name: "TableRow",
  mixins: [CommonsMixin],
  props: {
    item: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      columns: [],
    }
  },
  created() {
    const { availableTableFields = [] } = this.item
    this.columns = availableTableFields
  },
  methods: {
    nav(id) {
      this.$router.push({ name: "project", params: { id } });
    }
  }
};
</script>