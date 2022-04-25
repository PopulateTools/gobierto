<template>
  <div>
    <table class="gobierto-visualizations-table-debts">
      <tbody>

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
