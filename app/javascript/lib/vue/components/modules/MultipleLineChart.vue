<template>
  <div class="multiple-line-chart-container">
    <div class="multiple-line-tooltip-bars" />
    <svg
      class="multiple-line-chart"
      :width="svgWidth"
      :height="svgHeight"
    />
  </div>
</template>
<script>
import * as d3 from 'd3';
import { d3locale } from '../../../../lib/shared';

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
      },
      dataMultipleLineWithoutCoordinates: undefined,
      containerChart: undefined
    }
  },
  mounted() {
    this.containerChart = document.querySelector('.multiple-line-chart-container');
    this.svgWidth = this.containerChart.offsetWidth;
    this.svgHeight = this.height + this.margin.top + this.margin.bottom
    this.setupElements()
    this.buildMultipleLine(this.data)
    this.resizeListener()
  },
  methods: {
    setupElements() {
      const svg = d3.select('.multiple-line-chart')

      const g = svg.append('g')
        .attr('class', 'multiple-line-chart-container-g')

      g.append('g')
        .attr('class', 'axis axis-x')

      g.append('g')
        .attr('class', 'axis axis-y')
    },
    buildMultipleLine(data) {
      //Check if showLabels is true, if it's false reduce the size of the margin right
      this.marginRight = !this.showRightLabels ? 30 : this.marginRight

      data.sort(function(a,b){
        return new Date(b.year) - new Date(a.year);
      });

      this.dataMultipleLineWithoutCoordinates = JSON.parse(JSON.stringify(this.data));

      const svg = d3.select('.multiple-line-chart')

      const translate = `translate(${this.margin.left},${this.margin.top})`

      const g = svg.select('.multiple-line-chart-container-g')

      g.attr('transform', translate)

      const scaleY = d3.scaleLinear()
        .domain([0, d3.max(data, d => Math.max(d[this.arrayLineValues[0]], d[this.arrayLineValues[1]], d[this.arrayLineValues[2]]))])
        .range([this.height, 0]);

      const scaleX = d3.scaleTime()
        .domain(d3.extent(data, d => d.year))
        .range([0, this.svgWidth - (this.margin.left + this.margin.right)]);

      const scaleYBarCharts = d3.scaleLinear()
        .domain([0, d3.max(data, d => d.final_amount_no_taxes)])
        .range([this.height, 0]);

      const axisX = d3
        .axisBottom(scaleX)
        .tickPadding(10)
        .ticks(5)

      g.select('.axis-x')
        .attr('transform', `translate(0,${this.height})`)
        .call(axisX)

      const axisY = d3
        .axisLeft(scaleY)
        .tickPadding(10)
        .tickFormat(d => d)
        .tickSize(-(this.svgWidth - (this.margin.right)))
        .ticks(10)

      g.select('.axis-y')
        .call(axisY)

      g.selectAll(".bar")
        .data(data)
        .enter()
        .append("rect")
        .attr('class', 'multiple-line-chart-bars')
        .attr("x", d => scaleX(d.year))
        .attr("width", 20)
        .attr("y", d => scaleYBarCharts(d.final_amount_no_taxes))
        .attr('class', 'multiple-line-chart-bars')
        .attr('height', (d) => this.height - scaleYBarCharts(d.final_amount_no_taxes))
        .on('mouseover', (d, e, event) => {
          this.$emit('showTooltip', d, e, event);
        })
        .on('mouseout', () => {
          d3.select('.multiple-line-tooltip-bars')
            .style("opacity", 1)
            .transition()
            .duration(400)
            .style("opacity", 0)
        })

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
          .style('left', `${this.svgWidth - this.margin.right + 36}px`)
          .style('top', d => `${scaleY(d[value]) + this.margin.bottom}px`)
          .html(d => {
            if (this.showRightLabels) {
              return this.buildLenged(d, value)
            }
          })
      }

      for (let index = 0; index < this.arrayCircleValues.length; index++) {

        g.selectAll(`.circle-${this.arrayCircleValues[index]}`)
          .data(data)
          .join('circle')
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

      let tooltipText = new Function('d', 'value', 'localeFormat', 'return `' + filterData[0].legend + '`;')(d, value, localeFormat);
      return tooltipText
    },
    resizeListener() {
      window.addEventListener("resize", () => {
        d3.select('.multiple-line-chart-container-g')
          .remove()
          .exit()
        d3.selectAll('.tooltip-multiple-line')
          .remove()
          .exit()
        this.containerChart = document.querySelector('.multiple-line-chart-container');
        this.svgWidth = this.containerChart.offsetWidth;
        this.setupElements()
        this.buildMultipleLine(this.data)
      })
    }
  }
}

</script>
