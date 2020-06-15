<template>
  <div class="gobierto-dashboards-table--header gobierto-dashboards-table--header--thead">
    <div class="gobierto-dashboards-table-header--nav">
      <slot />
    </div>
    <div
      v-for="{ item, classItem, tooltipText, infoLink } in theadData"
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
          <a :href="infoLink">{{ labelSeeMore }}</a>
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
      showTooltipItem: null,
      labelSeeMore: I18n.t("gobierto_dashboards.dashboards.costs.see_more") || "",
    }
  },
  created() {
    this.theadData = [
      {
        item: I18n.t("gobierto_dashboards.dashboards.costs.cost_direct") || "",
        classItem: 'direct',
        tooltipText: I18n.t("gobierto_dashboards.dashboards.costs.tooltips.cost_direct") || "",
        infoLink: 'https://mataro.gobierto.test'
      },
      {
        item: I18n.t("gobierto_dashboards.dashboards.costs.cost_indirect") || "",
        classItem: 'indirect',
        tooltipText: I18n.t("gobierto_dashboards.dashboards.costs.tooltips.cost_indirect") || "",
        infoLink: 'https://mataro.gobierto.test'
      },
      {
        item: I18n.t("gobierto_dashboards.dashboards.costs.total") || "",
        classItem: 'total',
        tooltipText: I18n.t("gobierto_dashboards.dashboards.costs.tooltips.cost_total") || "",
        infoLink: 'https://mataro.gobierto.test'
      },
      {
        item: I18n.t("gobierto_dashboards.dashboards.costs.cost_inhabitant") || "",
        classItem: 'inhabitant',
        tooltipText: I18n.t("gobierto_dashboards.dashboards.costs.tooltips.cost_per_habitant") || "",
        infoLink: 'https://mataro.gobierto.test'
      },
      {
        item: I18n.t("gobierto_dashboards.dashboards.costs.income") || "",
        classItem: 'income',
        tooltipText: I18n.t("gobierto_dashboards.dashboards.costs.tooltips.income") || "",
        infoLink: 'https://mataro.gobierto.test'
      },
      {
        item: I18n.t("gobierto_dashboards.dashboards.costs.coverage") || "",
        classItem: 'coverage',
        tooltipText: I18n.t("gobierto_dashboards.dashboards.costs.tooltips.coverage") || "",
        infoLink: 'https://mataro.gobierto.test'
      }
    ]
  }
}
</script>
