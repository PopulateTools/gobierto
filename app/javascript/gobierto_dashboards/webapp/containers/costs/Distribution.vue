<template>
  <div class="pure-u-1 gutters m_b_1">
    <p>{{ labelDistribution }}</p>
    <div
      v-if="data"
      class="vis-costs"
    />
  </div>
</template>

<script>
import { VisBubbles } from "lib/visualizations";
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
    }
  },
  created() {
    this.getDataForBubbles()
  },
  methods: {
    getDataForBubbles() {

    },
    createBubbleViz() {
      const visBubblesCosts = new VisBubbles('.vis-costs', 'costs', this.data);
      visBubblesCosts.render();
    }
  }
}
</script>
