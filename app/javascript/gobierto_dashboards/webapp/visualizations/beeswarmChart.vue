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
import { scaleOrdinal, scaleBand, scaleTime } from 'd3-scale'
import { forceSimulation, forceX, forceY, forceCollide } from 'd3-force'
import { axisBottom, axisLeft } from 'd3-axis'
import { extent } from 'd3-array';
import { timeParse } from 'd3-time-format'

const d3 = { select, selectAll, scaleBand, scaleOrdinal, scaleTime, forceSimulation, forceX, forceY, forceCollide, axisBottom, axisLeft, extent, timeParse }

import { getDataMixin } from "../lib/getData";
export default {
  name: 'Beeswarm',
  mixins: [getDataMixin],
  data() {
    return {
      query: '?sql=SELECT EXTRACT(YEAR FROM start_date), initial_amount, contract_type, start_date FROM contratos',
      svgWidth: 0,
      svgHeight: 600,
      margin:{
        left: 50,
        right: 30,
        top: 50,
        bottom: 30
      },
      padding: 1.5
    }
  },
  mounted() {
    this.svgWidth = document.getElementsByClassName("dashboards-home-main")[0].offsetWidth;
  },
  async created() {
    const { data: { data } } = await this.getData(this.query)
    this.setupElements()
    this.buildBeesWarm(data)
  },
  methods: {
    setupElements() {
      const svg = d3.select('#beswarm-contracts')

      const g = svg.append('g')
        .attr('class', 'beswarm-contracts-container')

      g.append('g')
        .attr('class', 'axis axis-x')

      g.append('g')
        .attr('class', 'axis axis-y')
    },
    buildBeesWarm(contracts) {
      const parseTime = d3.timeParse('%Y-%m-%d');
      let filterContractsYear = contracts.filter(({ date_part }) => date_part !== null)
      let typesOfContract = filterContractsYear.map(({ contract_type }) => contract_type)
      typesOfContract = [...new Set(typesOfContract)];

      filterContractsYear.forEach(d => {
        d.date = parseTime(d.start_date)
        if (d.initial_amount <= 50000) {
          d.radius = 2
        } else if (d.initial_amount > 50000 && d.initial_amount <= 100000) {
          d.radius = 4
        } else if (d.initial_amount > 100000 && d.initial_amount <= 250000) {
          d.radius = 6
        } else if (d.initial_amount > 250000 ) {
          d.radius = 8
        }
      })

      const arrayGobiertoColors = ['#12365B', '#008E9C', '#FF776D', '#F8B205']
      const color = d3.scaleOrdinal(arrayGobiertoColors);

      const svg = d3.select('#beswarm-contracts')

      const translate = `translate(${this.margin.left},${this.margin.top})`

      const g = svg.select('.beswarm-contracts-container')

      g.attr('transform', translate)

      const scaleY = d3.scaleBand()
        .domain(typesOfContract)
        .range([this.svgHeight + this.margin.bottom, this.margin.top])

      const scaleX = d3.scaleTime()
        .domain(d3.extent(filterContractsYear, d => d.date))
        .nice()
        .range([this.margin.left, this.svgWidth - this.margin.right])

      const axisX = d3
        .axisBottom(scaleX)
        .tickPadding(10)
        .ticks(10)

      g.select('.axis-x')
        .attr('transform', `translate(0,${this.svgHeight - (this.margin.top + this.margin.bottom)})`)
        .call(axisX)

      const axisY = d3
        .axisLeft(scaleY)
        .tickFormat(d => d)
        .tickSize(-this.svgWidth)
        .ticks(6)

      g.select('.axis-y')
        .call(axisY)

      const simulation = d3.forceSimulation(filterContractsYear)
        .force('x', d3.forceX((d) => scaleX(d.date)).strength(0.5))
        .force('y', d3.forceY((d) => scaleY(d.contract_type)))
        .force('collide', d3.forceCollide().strength(0.3).radius(d => d.radius + this.padding))

      svg.selectAll('circle')
        .data(filterContractsYear)
        .join('circle')
        .attr('cx', (d) => scaleX(d.date))
        .attr('cy', (d) => scaleY(d.contract_type))
        .attr('r', (d) => d.radius)
        .style('fill', d => d.color = color(d.date_part));

      for (let i = 0; i < 120; i++) {
        simulation.tick();

        svg.selectAll('circle')
          .data(filterContractsYear)
          .attr('cx', (d) => d.x)
          .attr('cy', (d) => d.y);

      }
    }
  }
}
</script>
