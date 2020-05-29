<template>
  <div>
    <tr
      v-for="item in items"
      :key="item"
    >
      <td class="dashboards-table-costs--td">
        <div>{{ item.key }}</div>
      </td>
    </tr>
  </div>
</template>
<script>

export default {
  name: "TableRow",
  props: {
    items: {
      type: Array,
      default: () => []
    }
  }
};
</script>
