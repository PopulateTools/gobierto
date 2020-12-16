<template>
  <div v-if="items.length">
    <table class="visualizations-home-main--table">
      <thead>
        <th
          v-for="{ field, translation, cssClass } in columns"
          :key="field"
          class="visualizations-home-main--th"
          :class="cssClass"
        >
          <span class="visualizations-home-main--th-text">{{ translation }}</span>
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
      :container-pagination="containerPagination"
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
      labelEmpty: I18n.t("gobierto_visualizations.visualizations.contracts.empty_table"),
      displayedData: [],
      containerPagination: '.visualizations-home-main--table'
    };
  },
  watch: {
    $route(to) {
      if (to.name === "summary") {
        this.containerPagination = '.visualizations-home-main--table'
      } else if (to.name === "contracts_index") {
        this.containerPagination = 'main.visualizations-home-main'
      }
    }
  },
  methods: {
    updateData(values) {
      this.displayedData = values
    }
  }
};
</script>
