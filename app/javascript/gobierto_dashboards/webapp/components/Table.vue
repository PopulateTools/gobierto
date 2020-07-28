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
        v-for="item in displayedData"
        :key="item.id"
        :item="item"
        :routing-member="routingMember"
        :routing-attribute="routingAttribute"
        :columns="columns"
      />
    </table>
    <Pagination
      :data="items"
      :items-per-page="15"
      :container-pagination="'main.dashboards-home-main'"
      @showData="updateData"
    />
  </div>
  <div v-else>
    {{ labelEmpty }}
  </div>
</template>

<script>
import TableRow from "./TableRow.vue";
import { Pagination } from "lib/vue-components";

export default {
  name: "Table",
  components: {
    TableRow,
    Pagination
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
      displayedData: [],
    };
  },
  methods: {
    updateData(values) {
      this.displayedData = values
    }
  }
};
</script>
