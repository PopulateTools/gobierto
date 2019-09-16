<template>
  <table class="investments-home-main--table">
    <thead>
      <th class="investments-home-main--th">
        <div>Proyectu</div>
      </th>
      <th class="investments-home-main--th">
        <div>Estáu</div>
      </th>
      <th class="investments-home-main--th">
        <div>Cantidá</div>
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

export default {
  name: "Table",
  components: {
    TableRow
  },
  props: {
    items: {
      type: Array,
      default: () => []
    }
  }
};
</script>