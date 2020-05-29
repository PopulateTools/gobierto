<template>
  <div class="pure-g gutters m_b_4">
    <p>Distribución de costes por área</p>
  </div>
</template>

<script>

import { VisBubble } from "lib/visualizations";

export default {
  name: 'Distribution',
  created() {
    this.createBubbleViz()
  },
  methods: {
    createBubbleViz() {
      const visBubblesCosts = new VisBubble('.vis-bubbles-expense', 'expense', window.budgetLevels);
    }
  }
}
</script>
