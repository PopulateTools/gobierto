<template>
  <div class="gobierto-dashboards-table--header gobierto-dashboards-table--header--thead">
    <div class="gobierto-dashboards-table-header--nav">
      <slot />
    </div>
    <div
      v-for="{ item, classItem } in theadData"
      :key="item"
      :class="`gobierto-dashboards-table-color-${classItem}`"
      class="gobierto-dashboards-table-header--elements"
    >
      <i
        class="far fa-question-circle"
        style="color: var(--color-base)"
      />
      <span class="gobierto-dashboards-header--elements-text">
        {{ item }}
      </span>
    </div>
  </div>
</template>

<script>
export default {
  name: 'TableHeader',
  data() {
    return {
      theadData: []
    }
  },
  created() {
    this.theadData = [
      {
        item: I18n.t("gobierto_dashboards.dashboards.costs.cost_direct") || "",
        classItem: 'direct'
      },
      {
        item: I18n.t("gobierto_dashboards.dashboards.costs.cost_indirect") || "",
        classItem: 'indirect'
      },
      {
        item: I18n.t("gobierto_dashboards.dashboards.costs.total") || "",
        classItem: 'total'
      },
      {
        item: I18n.t("gobierto_dashboards.dashboards.costs.cost_inhabitant") || "",
        classItem: 'inhabitant'
      },
      {
        item: I18n.t("gobierto_dashboards.dashboards.costs.income") || "",
        classItem: 'income'
      },
      {
        item: I18n.t("gobierto_dashboards.dashboards.costs.coverage") || "",
        classItem: 'coverage'
      }
    ]
  }
}
</script>
