<template>
  <div class="container">
    <p>Tipos de contrato</p>
    <svg 
      id="treemap-contracts"
      :width="svgWidth"
      :height="svgHeight"
    >

    </svg>
  </div>
</template>
<script>

import { select, selectAll } from 'd3-selection'
import { treemap, stratify } from 'd3-hierarchy'


const d3 = { select, selectAll, treemap, stratify }

import { getDataMixin } from "../lib/getData";
export default {
  name: 'TreeMap',
  mixins: [getDataMixin],
  data() {
    return {
      query: '?sql=SELECT contract_type, sum(initial_amount) as TOTAL FROM contratos GROUP BY contract_type',
      svgWidth: 0,
      svgHeight: 400
    }
  },
  mounted() {
    this.svgWidth = document.getElementsByClassName("dashboards-home-main")[0].offsetWidth;
  },
  async created() {
    const { data: { data } } = await this.getData(this.query)
    this.buildTreeMap(data)
  },
  methods: {
    buildTreeMap(typeOfContracts) {

      typeOfContracts.forEach(d => {
        d.parent = 'contract'
      })

      typeOfContracts.unshift({
        contract_type: 'contract',
        parent: '',
        total: ''
      });
      const svg = d3.select('#treemap-contracts')

      const rootTreeMap = d3.stratify()
        .id(d => d.contract_type)
        .parentId(d => d.parent)(typeOfContracts)

      rootTreeMap.sum(d => +d.total )

      d3.treemap()
        .size([this.svgWidth, this.svgHeight])
        .padding(4)(rootTreeMap)

      svg
        .selectAll("rect")
        .data(rootTreeMap.leaves())
        .enter()
        .append("rect")
          .attr('x', d => d.x0)
          .attr('y', d => d.y0)
          .attr('width', d => d.x1 - d.x0)
          .attr('height', d => d.y1 - d.y0)
          .style("stroke", "black")
          .style("fill", "#69b3a2");

    }
  }
}
</script>
