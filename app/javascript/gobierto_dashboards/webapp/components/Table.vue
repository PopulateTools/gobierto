<template>
  <div v-if="items.length">
    <table class="dashboards-home-main--table">
      <thead>
        <th
          v-for="{ translation } in columns"
          class="dashboards-home-main--th"
        >
          <div>{{ translation }}</div>
        </th>
      </thead>
      <transition-group
        name="fade"
        tag="tbody"
        mode="out-in"
      >
        <TableRow
          v-for="item in items"
          :key="item.id"
          :item="item"
          :routing-member="routingMember"
          :columns="columns"
        />
      </transition-group>
    </table>
  </div>
  <div v-else>
    {{ labelEmpty }}
  </div>
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
  data() {
    return {
      labelEmpty: I18n.t("gobierto_dashboards.dashboards.contracts.empty_table"),
      perPage: 50
    };
  }
};
</script>
