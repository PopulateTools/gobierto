<template>
  <div class="gobierto-visualizations-table--header gobierto-visualizations-table--header--thead">
    <div class="gobierto-visualizations-table-header--nav">
      <slot />
    </div>
    <div
      v-for="{ item, classItem, tooltipText } in theadData"
      :key="item"
      :class="`gobierto-visualizations-table-color-${classItem}`"
      class="gobierto-visualizations-table-header--elements"
      @mouseover="showTooltipItem = item"
      @mouseleave="showTooltipItem = null"
    >
      <i
        class="far fa-question-circle"
        style="color: var(--color-base)"
      />
      <span class="gobierto-visualizations-header--elements-text">
        {{ item }}
      </span>
      <transition
        name="fade"
        mode="out-in"
      >
        <div
          v-show="showTooltipItem === item"
          class="gobierto-visualizations-header--tooltip"
        >
          {{ tooltipText }}
        </div>
      </transition>
    </div>
  </div>
</template>

<script>
import { VueFiltersMixin } from '../../../../../lib/vue/filters'

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
        item: I18n.t("gobierto_visualizations.visualizations.costs.cost_direct") || "",
        classItem: 'direct',
        tooltipText: I18n.t("gobierto_visualizations.visualizations.costs.tooltips.cost_direct") || ""
      },
      {
        item: I18n.t("gobierto_visualizations.visualizations.costs.cost_indirect") || "",
        classItem: 'indirect',
        tooltipText: I18n.t("gobierto_visualizations.visualizations.costs.tooltips.cost_indirect") || ""
      },
      {
        item: I18n.t("gobierto_visualizations.visualizations.costs.total") || "",
        classItem: 'total',
        tooltipText: I18n.t("gobierto_visualizations.visualizations.costs.tooltips.cost_total") || ""
      },
      {
        item: I18n.t("gobierto_visualizations.visualizations.costs.cost_inhabitant") || "",
        classItem: 'inhabitant',
        tooltipText: I18n.t("gobierto_visualizations.visualizations.costs.tooltips.cost_per_habitant") || ""
      },
      {
        item: I18n.t("gobierto_visualizations.visualizations.costs.income") || "",
        classItem: 'income',
        tooltipText: I18n.t("gobierto_visualizations.visualizations.costs.tooltips.income") || ""
      },
      {
        item: I18n.t("gobierto_visualizations.visualizations.costs.coverage") || "",
        classItem: 'coverage',
        tooltipText: I18n.t("gobierto_visualizations.visualizations.costs.tooltips.coverage") || ""
      }
    ]
  }
}
</script>
