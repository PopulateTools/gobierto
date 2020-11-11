<template>
  <div class="multiple-line-chart-container">
    <p>Contratos por tipo, volumen, tamaño y fecha</p>
    <svg
      class="multiple-line-chart"
      :width="svgWidth"
      :height="height"
    >
    </svg>
  </div>
</template>
<script>
import { select, selectAll } from 'd3-selection';
import { nest } from 'd3-collection';
import { min, max, extent } from 'd3-array';
import { line } from 'd3-shape';
import { scaleTime, scaleLinear, scaleOrdinal } from 'd3-scale';
import { axisBottom, axisLeft } from 'd3-axis';
import { timeFormat, timeParse } from 'd3-time-format';

const d3 = { select, selectAll, nest, min, max, line, scaleOrdinal, scaleTime, scaleLinear, axisBottom, axisLeft, timeFormat, timeParse, extent }

export default {
  name: 'MultipleLineChart',
  props: {
    data: {
      type: Array,
      default: () => []
    },
    height: {
      default: 400,
      type: Number,
    },
    arrayValues: {
      type: Array,
      default: () => []
    },
  },
  data() {
    return {
      svgWidth: 0,
      margin: {
        left: 30,
        right: 30,
        top: 50,
        bottom: 30
      }
    }
  },
  mounted() {
    const containerChart = document.getElementsByClassName('multiple-line-chart-container')[0];
    this.svgWidth = containerChart.offsetWidth
    this.setupElements()
    this.buildMultipleLine(this.data)
  },
  methods: {
    setupElements() {
      const svg = d3.select('.multiple-line-chart')

      const g = svg.append('g')
        .attr('class', 'multiple-line-chart-container')

      g.append('g')
        .attr('class', 'axis axis-x')

      g.append('g')
        .attr('class', 'axis axis-y')
    },
    buildMultipleLine(data) {

      const parseTime = d3.timeParse('%Y');

      data.forEach(d => {
        d.year = parseTime(d.year)
      })

      data.sort(function(a,b){
        return new Date(b.year) - new Date(a.year);
      });
      console.log("data", data);

      const arrayGobiertoColors = ['#12365B', '#008E9C', '#FF776D', '#F8B205']
      const color = d3.scaleOrdinal(arrayGobiertoColors);

      const svg = d3.select('.multiple-line-chart')

      const translate = `translate(${this.margin.left},${this.margin.top})`

      const g = svg.select('.multiple-line-chart-container')

      g.attr('transform', translate)

      const scaleY = d3.scaleLinear()
        .domain([0, d3.max(data, d => Math.max(d[this.arrayValues[0]], d[this.arrayValues[1]], d[this.arrayValues[2]]))])
        .range([this.height, 0]);

      const scaleX = d3.scaleTime()
        .domain(d3.extent(data, d => d.year))
        .range([0, this.svgWidth]);

      const axisX = d3
        .axisBottom(scaleX)
        .tickPadding(20)
        .tickSize(-this.height)
        .ticks(5)

      g.select('.axis-x')
        .attr('transform', `translate(0,${this.height})`)
        .call(axisX)

      const axisY = d3
        .axisLeft(scaleY)
        .tickFormat(d => d)
        .tickSize(-this.svgWidth)
        .ticks(6)

      g.select('.axis-y')
        .call(axisY)

      for (let index = 0; index < this.arrayValues.length; index++) {

       let valueline = d3.line()
         .x(d => scaleX(d.year))
         .y(d => scaleY(d[this.arrayValues[index]]));

        svg.append("path")
          .data([data])
          .attr("class", "lines-multiple-lines")
          .attr("d", valueline);
      }
    }
  }
}

</script>
