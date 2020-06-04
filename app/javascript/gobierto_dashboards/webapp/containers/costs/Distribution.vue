<template>
  <div class="pure-u-1 m_b_1">
    <div class="pure-g gutters">
      <h2 class="pure-u-1 gobierto-dashboards-title">{{ labelDistribution }}</h2>
      <div class="pure-u-1 pure-u-lg-1-4 metric_boxes">
        <div class="pure-u-1-1 metric_box tipsit">
          <div class="inner">
            <h3>{{ labelTotalCost }}</h3>
            <div class="metric">
              {{ totalCost }}
            </div>
          </div>
        </div>
        <div class="pure-u-1-1 metric_box tipsit">
          <div class="inner">
            <h3>{{ labelCostPerInhabitant }}</h3>
            <div class="metric">
              {{ totalCostPerHabitant | money }}
            </div>
          </div>
        </div>
        <div class="pure-u-1-1 metric_box tipsit">
          <div class="inner">
            <h3>{{ labelInhabitant }}</h3>
            <div class="metric">
              {{ population2018 }}
            </div>
          </div>
        </div>
      </div>
      <div id="gobierto-dashboards-bubble-container" class="pure-u-1 pure-u-lg-3-4">
        <div class="vis-costs vis-bubbles" />
      </div>
    </div>
  </div>
</template>
<script>
import { VisBubble } from "lib/visualizations";
import { VueFiltersMixin } from "lib/shared"

export default {
  name: 'Distribution',
  mixins: [VueFiltersMixin],
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
      population2018: 126988,
      population2019: 128265,
      totalAmount: ''
    }
  },
  computed: {
    totalCost() {
      const total = this.data.reduce((accum,element) => accum + element.cost_total_2018, 0)
      return (total / 1000000).toFixed(1).replace(/\./, ',') + ' M€';
    },
    totalCostPerHabitant() {
      return this.data.reduce((accum,element) => accum + element.cost_total_2018, 0) / this.population2018
    }
  },
  mounted() {
    this.createBubbleViz()
  },
  methods: {
    createBubbleViz() {
      const visBubblesCosts = new VisBubble('.vis-costs', this.data);
      visBubblesCosts.render();

      window.addEventListener('resize', function() {
        visBubblesCosts.resize()
      });
    }
  }
}
</script>
