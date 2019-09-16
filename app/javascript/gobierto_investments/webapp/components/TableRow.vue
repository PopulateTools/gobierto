<template>
  <tr class="investments-home-main--tr" @click="nav(item.id)">
    <td class="investments-home-main--td">
      <div>{{ item.title }}</div>
    </td>
    <td class="investments-home-main--td">
      <div>{{ item.status }}</div>
    </td>
    <td class="investments-home-main--td">
      <div>{{ item.import.toLocaleString(undefined, { style: "currency", currency: "EUR" }) }}</div>
    </td>
  </tr>
</template>

<script>
export default {
  name: "Table-Row",
  props: {
    item: Object
  },
  methods: {
    nav(id) {
      this.$router.push({ name: "project", params: { id } });
    }
  }
};
</script>