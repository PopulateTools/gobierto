<template>
  <div v-if="items.length">
    <table class="dashboards-home-main--table">
      <thead>
        <th
          v-for="{ field, translation, cssClass } in columns"
          :key="field"
          class="dashboards-home-main--th"
          :class="cssClass"
        >
          <div>{{ translation }}</div>
        </th>
      </thead>
      <TableRow
        v-for="item in items"
        :key="item.id"
        :item="item"
        :routing-member="routingMember"
        :routing-attribute="routingAttribute"
        :columns="columns"
      />
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
    },
    routingAttribute: {
      type: String,
      default: 'id'
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
