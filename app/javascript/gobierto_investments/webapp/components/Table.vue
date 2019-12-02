<template>
  <div v-if="items.length">
    <table class="investments-home-main--table">
      <thead>
        <th
          v-for="column in columns"
          :key="column.id"
          class="investments-home-main--th"
        >
          <div>{{ column.name }}</div>
        </th>
      </thead>
      <transition-group
        name="fade"
        tag="tbody"
        mode="out-in"
      >
        <TableRow
          v-for="item in visibleItems"
          :key="item.id"
          :item="item"
        />
      </transition-group>
    </table>

    <ShowAll @show-all="showAll" />
  </div>
  <div v-else>
    {{ labelEmpty }}
  </div>
</template>

<script>
import TableRow from "./TableRow.vue";
import ShowAll from "./ShowAll.vue";
import { CommonsMixin } from "../mixins/common.js";

export default {
  name: "Table",
  components: {
    TableRow,
    ShowAll
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
      labelEmpty: "",
      visibleItems: [],
      maxItems: 24
    };
  },
  created() {
    this.labelEmpty = I18n.t("gobierto_investments.projects.empty");
    this.visibleItems = this.items.slice(0, this.maxItems);

    const { availableTableFields = [] } = this.items.length
      ? this.items[0]
      : {};
    this.columns = availableTableFields;
  },
  methods: {
    showAll(isAllVisible) {
      this.visibleItems = isAllVisible
        ? this.items
        : this.items.slice(0, this.maxItems);
    }
  }
};
</script>
