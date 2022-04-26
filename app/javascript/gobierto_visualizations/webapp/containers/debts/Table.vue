<template>
  <div>
    <table class="gobierto-visualizations-table-debts">
      <tbody>
        <tr
          v-for="{ endeutament, entitat } in data"
          :key="entitat"
          class="gobierto-visualizations-table-debts-tr"
        >
          <td class="gobierto-visualizations-table-debts-td">
            {{ entitat }}
          </td>
          <td class="gobierto-visualizations-table-debts-td">
            {{ endeutament }}
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
<script>
export default {
  name: "Table",
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
  }
}
</script>
