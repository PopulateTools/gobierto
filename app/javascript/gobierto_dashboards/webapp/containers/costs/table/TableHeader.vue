<template>
  <div class="gobierto-dashboards-table--header gobierto-dashboards-table--header--thead">
    <div class="gobierto-dashboards-table-header--nav">
      <slot />
    </div>
    <div
      v-for="{ item, classItem, tooltipText } in theadData"
      :key="item"
      :class="`gobierto-dashboards-table-color-${classItem}`"
      class="gobierto-dashboards-table-header--elements"
      @mouseover="showTooltipItem = item"
      @mouseleave="showTooltipItem = null"
    >
      <i
        class="far fa-question-circle"
        style="color: var(--color-base)"
      />
      <span class="gobierto-dashboards-header--elements-text">
        {{ item }}
      </span>
      <transition
        name="fade"
        mode="out-in"
      >
        <div
          v-show="showTooltipItem === item"
          class="gobierto-dashboards-header--tooltip"
        >
          {{ tooltipText }}
        </div>
      </transition>
    </div>
  </div>
</template>

<script>
import { VueFiltersMixin } from "lib/shared"
export default {
  name: 'TableHeader',
  mixins: [VueFiltersMixin],
  data() {
    return {
      theadData: [],
      showTooltipItem: null
    }
  },
  created() {
    this.theadData = [
      {
        item: I18n.t("gobierto_dashboards.dashboards.costs.cost_direct") || "",
        classItem: 'direct',
        tooltipText: I18n.t("gobierto_dashboards.dashboards.costs.tooltips.cost_direct") || ""
      },
      {
        item: I18n.t("gobierto_dashboards.dashboards.costs.cost_indirect") || "",
        classItem: 'indirect',
        tooltipText: I18n.t("gobierto_dashboards.dashboards.costs.tooltips.cost_indirect") || ""
      },
      {
        item: I18n.t("gobierto_dashboards.dashboards.costs.total") || "",
        classItem: 'total',
        tooltipText: I18n.t("gobierto_dashboards.dashboards.costs.tooltips.costtotal") || ""
      },
      {
        item: I18n.t("gobierto_dashboards.dashboards.costs.cost_inhabitant") || "",
        classItem: 'inhabitant',
        tooltipText: I18n.t("gobierto_dashboards.dashboards.costs.tooltips.costperhabit") || ""
      },
      {
        item: I18n.t("gobierto_dashboards.dashboards.costs.income") || "",
        classItem: 'income',
        tooltipText: I18n.t("gobierto_dashboards.dashboards.costs.tooltips.income") || ""
      },
      {
        item: I18n.t("gobierto_dashboards.dashboards.costs.coverage") || "",
        classItem: 'coverage',
        tooltipText: I18n.t("gobierto_dashboards.dashboards.costs.tooltips.coverage") || ""
      }
    ]
  }
}
</script>
