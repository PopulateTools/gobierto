<template>
  <div class="pure-g gutters m_b_1">
    <h2 class="pure-u-1 gobierto-dashboards-title">{{ labelDistribution }}</h2>
    <div class="pure-u-1 pure-u-lg-1-4 metric_boxes">
      <div class="pure-u-1-1 metric_box tipsit">
        <div class="inner">
          <h3>{{ labelTotalCost }}</h3>
          <div class="metric">
            172,1 M€
          </div>
        </div>
      </div>
      <div class="pure-u-1-1 metric_box tipsit">
        <div class="inner">
          <h3>{{ labelCostPerInhabitant }}</h3>
          <div class="metric">
            172,1 M€
          </div>
        </div>
      </div>
      <div class="pure-u-1-1 metric_box tipsit">
        <div class="inner">
          <h3>{{ labelInhabitant }}</h3>
          <div class="metric">
            172,1 M€
          </div>
        </div>
      </div>
    </div>
    <div class="pure-u-1 pure-u-lg-3-4">
      <div class="graph vis-costs" />
    </div>
  </div>
</template>

<script>
import { VisBubble } from "lib/visualizations";
export default {
  name: 'Distribution',
  props: {
    data: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      labelDistribution: I18n.t("gobierto_dashboards.dashboards.costs.distribution") || "",
      labelTotalCost: I18n.t("gobierto_dashboards.dashboards.costs.total_cost") || "",
      labelInhabitant: I18n.t("gobierto_dashboards.dashboards.costs.inhabitant") || "",
      labelCostPerInhabitant: I18n.t("gobierto_dashboards.dashboards.costs.cost_per_inhabitant") || "",
    }
  },
  mounted() {
    this.createBubbleViz()
  },
  methods: {
    createBubbleViz() {
      const visBubblesCosts = new VisBubble('.vis-costs', this.data);
      visBubblesCosts.render();
    }
  }
}
</script>
