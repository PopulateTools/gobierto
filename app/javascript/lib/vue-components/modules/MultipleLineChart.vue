<template>
  <div class="multiple-line-chart-container">
    <svg
      class="multiple-line-chart"
      :width="svgWidth"
      :height="svgHeight"
    >
    </svg>
  </div>
</template>
<script>
import { select, selectAll } from 'd3-selection';
import { nest } from 'd3-collection';
import { min, max, extent } from 'd3-array';
import { line, curveCardinal } from 'd3-shape';
import { scaleTime, scaleLinear, scaleOrdinal } from 'd3-scale';
import { axisBottom, axisLeft } from 'd3-axis';
import { timeFormat, timeParse } from 'd3-time-format';
import { format, formatDefaultLocale } from 'd3-format';
import { d3locale } from "lib/shared";

const d3 = { select, selectAll, nest, min, max, line, scaleOrdinal, scaleTime, scaleLinear, axisBottom, axisLeft, timeFormat, timeParse, extent, curveCardinal, format, formatDefaultLocale }

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
    arrayLineValues: {
      type: Array,
      default: () => []
    },
    arrayCircleValues: {
      type: Array,
      default: () => []
    },
    showRightLabels: {
      type: Boolean,
      default: false
    },
    valuesLegend: {
      type: Array,
      default: () => []
    },
    marginLeft: {
      type: Number,
      default: 30
    },
    marginRight: {
      type: Number,
      default: 250
    },
    marginTop: {
      type: Number,
      default: 50
    },
    marginBottom: {
      type: Number,
      default: 30
    }
  },
  data() {
    return {
      svgWidth: 0,
      svgHeight: 0,
      margin: {
        left: this.marginLeft,
        right: this.marginRight,
        top: this.marginTop,
        bottom: this.marginBottom
      }
    }
  },
  mounted() {
    const containerChart = document.getElementsByClassName('multiple-line-chart-container')[0];
    this.svgWidth = containerChart.offsetWidth
    this.svgHeight = this.height + this.margin.top + this.margin.bottom
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

      const svg = d3.select('.multiple-line-chart')

      const translate = `translate(${this.margin.left},${this.margin.top})`

      const g = svg.select('.multiple-line-chart-container')

      g.attr('transform', translate)

      const scaleY = d3.scaleLinear()
        .domain([0, d3.max(data, d => Math.max(d[this.arrayLineValues[0]], d[this.arrayLineValues[1]], d[this.arrayLineValues[2]]))])
        .range([this.height, 0]);

      const scaleX = d3.scaleTime()
        .domain(d3.extent(data, d => d.year))
        .range([0, this.svgWidth - (this.margin.left + this.margin.right)]);

      const axisX = d3
        .axisBottom(scaleX)
        .tickPadding(10)
        .ticks(5)

      g.select('.axis-x')
        .attr('transform', `translate(0,${this.height})`)
        .call(axisX)

      const axisY = d3
        .axisLeft(scaleY)
        .tickFormat(d => d)
        .tickSize(-(this.svgWidth - (this.margin.left + this.margin.right)))
        .ticks(10)

      g.select('.axis-y')
        .call(axisY)

      for (let index = 0; index < this.arrayLineValues.length; index++) {

        let value = this.arrayLineValues[index]
        let valueline = d3.line()
          .x(d => scaleX(d.year))
          .y(d => scaleY(d[value]))
          .curve(d3.curveCardinal);

        g.append("path")
          .data([data])
          .attr("class", `lines-multiple-lines line-${value}`)
          .attr("d", valueline)

        d3.select('.multiple-line-chart-container')
          .append('div')
          .data(data)
          .attr('class', `tooltip-multiple-line tooltip-${value}`)
          .style('left', `${this.svgWidth - this.margin.right + 18}px`)
          .style('top', d => `${scaleY(d[value]) + this.margin.bottom}px`)
          .html(d => {
            return this.buildLenged(d, value)
          })
      }

      for (let index = 0; index < this.arrayCircleValues.length; index++) {

        g.selectAll(`circle-${this.arrayCircleValues[index]}`)
          .data(data)
          .enter()
          .append('circle')
          .attr("class", `circle-${this.arrayCircleValues[index]}`)
          .attr('cx', d => scaleX(d.year))
          .attr('cy', d => scaleY(d[this.arrayCircleValues[index]]))
          .attr('r', 6)
      }

    },
    buildLenged(d, value) {
      const locale = d3.formatDefaultLocale(d3locale[I18n.locale]);
      const localeFormat = locale.format(',.0f')
      const filterData = this.valuesLegend.filter(d => d.key === value)

      let tooltipText = eval('`'+filterData[0].legend+'`');
      return tooltipText
    }
  }
}

</script>
