<template>
  <div>
    <table class="gobierto-visualizations-table-debts">
      <tbody>
        <tr
          v-for="(item, index) in data"
          :key="index"
          class="gobierto-visualizations-table-debts-tr"
        >
          <template v-for="(value, key) in item">
            <td
              :key="key"
              class="gobierto-visualizations-table-debts-td"
            >
              {{ parseAmount(value) }}
            </td>
          </template>
        </tr>
      </tbody>
    </table>
  </div>
</template>
<script>
import { VueFiltersMixin } from "lib/vue/filters"
export default {
  name: "Table",
  mixins: [VueFiltersMixin],
  props: {
    data: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      labelCostDirect: I18n.t("gobierto_visualizations.visualizations.costs.cost_direct") || ""
    }
  },
  methods: {
    parseAmount(value) {
      return !isNaN(value) ? this.$options.filters.money(value) : this.$options.filters.truncate(value)
    },
  }
}

</script>
