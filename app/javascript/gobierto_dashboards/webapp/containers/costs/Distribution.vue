<template>
  <div class="pure-u-1 gutters m_b_1">
    <p>Distribución de costes por área</p>
    <div
      v-if="data"
      class="vis-costs">
    </div>
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
