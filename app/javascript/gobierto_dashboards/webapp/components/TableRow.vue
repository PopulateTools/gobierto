<template>
  <tr class="dashboards-home-main--tr" @click="navigateTo(item)" >
    <td
      v-for="column in columns"
      class="dashboards-home-main--td"
    >
      <div>{{ item[column.field] }}</div>
    </td>
  </tr>
</template>

<script>
export default {
  name: "TableRow",
  props: {
    item: {
      type: Object,
      default: () => {}
    },
    columns: {
      type: Array,
      default: () => []
    },
    routingMember: {
      type: String,
      default: ''
    }
  },
  methods: {
    navigateTo(item) {
      this.$router.push({ name: this.routingMember, params: { id: item.id, item } });
    },
  }
};
</script>
