<template>
  <div class="container">
    <p>Contratos por tipo, volumen, tamaño y fecha</p>
    <svg
      id="beswarm-contracts"
      :width="svgWidth"
      :height="svgHeight"
    >
    </svg>
  </div>
</template>
<script>

import { select, selectAll } from 'd3-selection'
import { treemap, stratify } from 'd3-hierarchy'
import { scaleOrdinal } from 'd3-scale'

const d3 = { select, selectAll, treemap, stratify, scaleOrdinal }

import { getDataMixin } from "../lib/getData";
export default {
  name: 'Beeswarm',
  mixins: [getDataMixin],
  data() {
    return {
      query: '?sql=SELECT EXTRACT(YEAR FROM start_date), initial_amount, contract_type FROM contratos',
      svgWidth: 0,
      svgHeight: 400
    }
  },
  mounted() {
    this.svgWidth = document.getElementsByClassName("dashboards-home-main")[0].offsetWidth;
  },
  async created() {
    const { data: { data } } = await this.getData(this.query)
    this.buildBeesWarm(data)
  },
  methods: {
    buildBeesWarm(contracts) {

    }
  }
}
</script>
