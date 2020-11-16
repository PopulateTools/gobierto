<template>
  <div class="beeswarm-container">
    <div class="beeswarm-tooltip"></div>
    <svg
      class="beeswarm-plot"
      :width="svgWidth"
      :height="height"
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
import { timeParse, timeFormat } from 'd3-time-format'
import { min, max } from 'd3-array'
import * as chroma from 'chroma-js';

const d3 = { select, selectAll, scaleBand, scaleOrdinal, scaleTime, forceSimulation, forceX, forceY, forceCollide, axisBottom, axisLeft, extent, timeParse, timeFormat, min, max }

export default {
  name: 'BeesWarmChart',
  props: {
    data: {
      type: Array,
      default: () => []
    },
    height: {
      default: 400,
      type: Number,
    },
    radiusProperty: {
      default: '',
      type: String,
    },
    xAxisProp: {
      default: '',
      type: String,
    },
    yAxisProp: {
      default: '',
      type: String,
    },
    marginLeft: {
      type: Number,
      default: 120
    },
    marginRight: {
      type: Number,
      default: 30
    },
    marginTop: {
      type: Number,
      default: 70
    },
    marginBottom: {
      type: Number,
      default: 30
    }
  },
  data() {
    return {
      svgWidth: 0,
      margin: {
        left: this.marginLeft,
        right: this.marginRight,
        top: this.marginTop,
        bottom: this.marginBottom
      },
      padding: 1.5,
      updateCircles: false
    }
  },
  watch: {
    data(newValue, oldValue) {
      if (newValue !== oldValue) {
        this.deepCloneData(newValue)
        this.updateCircles = true
      }
    }
  },
  mounted() {
    const containerChart = document.getElementsByClassName('beeswarm-container')[0];
    this.svgWidth = containerChart.offsetWidth
    this.setupElements()
    this.buildBeesWarm(this.data)
    /*this.resizeListener()*/
  },
  methods: {
    deepCloneData(data) {
      const dataBeesWarm = JSON.parse(JSON.stringify(data));
      this.buildBeesWarm(dataBeesWarm)
    },
    setupElements() {
      const svg = d3.select('.beeswarm-plot')

      const g = svg.append('g')
        .attr('class', 'beeswarm-plot-container')

      g.append('g')
        .attr('class', 'axis axis-x')

      g.append('g')
        .attr('class', 'axis axis-y')
    },
   buildBeesWarm(data) {
      let filterData = this.transformData(data)

      const arrayGobiertoColors = ['#12365B', '#008E9C', '#FF776D', '#F8B205']
      const color = d3.scaleOrdinal(arrayGobiertoColors);

      const svg = d3.select('.beeswarm-plot')

      const translate = `translate(${this.margin.left},0)`

      const g = svg.select('.beeswarm-plot-container')

      g.attr('transform', translate)

      const scaleY = d3.scaleBand()
        .domain(Array.from(new Set(filterData.map((d) => d[this.yAxisProp]))))
        .range([this.height + this.margin.bottom, this.margin.top])

      const scaleX = d3.scaleTime()
        .domain(d3.extent(filterData, d => d[this.xAxisProp]))
        .nice()
        .range([this.margin.left, this.svgWidth])

      svg.selectAll('.label-y')
        .data(Array.from(new Set(filterData.map((d) => d[this.yAxisProp]))))
        .join('text')
        .attr('class', 'label-y')
        .attr('x', 0)
        .attr('y', d => scaleY(d))
        .attr('alignment-baseline', 'middle')
        .text(d => d);

      svg.selectAll('.line-y')
          .data(Array.from(new Set(filterData.map((d) => d[this.yAxisProp]))))
          .join('line')
          .attr('class', 'line-y')
          .attr('x1', this.margin.left)
          .attr('x2', this.svgWidth + this.margin.left + this.margin.right)
          .attr('y1', d => scaleY(d))
          .attr('y2', d => scaleY(d))

      svg.selectAll('.label-y')
        .call(this.wrapTextLabel, 120);

      const axisX = d3
        .axisBottom(scaleX)
        .tickPadding(20)
        .tickFormat(d3.timeFormat("%Y"))
        .tickSize(-this.height)
        .ticks(5)

      g.select('.axis-x')
        .attr('transform', `translate(${-this.margin.left},${this.height - this.margin.top})`)
        .transition()
        .duration(200)
        .call(axisX)

      const axisY = d3
        .axisLeft(scaleY)

      g.select('.axis-y')
        .attr('transform', `translate(0,${-(this.margin.bottom + this.margin.top)})`)
        .call(axisY)

      const circlesBees = svg
        .selectAll('.beeswarm-circle')
        .remove()
        .exit()
        .data(filterData)
        .enter()
        .append('circle')
        .attr('class', 'beeswarm-circle')
        .style('fill', d => d.color = color(d[this.yAxisProp]))
        .attr('r', d => d.radius)
        .on("mouseover", (event, d) => {
          this.$emit("showTooltip", event, d)
        })
        .on("mouseout", () => {
          d3.select('.beeswarm-tooltip')
            .style('display', 'none')
        })
        .on("click", (event, d) => {
          this.$emit("goesToItem", event)
        })

      const simulation = d3
        .forceSimulation()
        .force('x', d3.forceX((d) => scaleX(d[this.xAxisProp])).strength(0.5))
        .force('y', d3.forceY((d) => scaleY(d[this.yAxisProp])))
        .force('collide', d3.forceCollide().strength(0.3).radius(d => d.radius))

      simulation
        .nodes(filterData)
        .on("tick", () =>
            circlesBees
              .attr('cx', (d) => d.x - (this.margin.right / 2))
              .attr('cy', (d) => d.y)
        )
    },
    transformData(data) {
      let dataScaleRadius = data.map((d) => +d[this.radiusProperty])
      const arrayScaleRadius = chroma.limits(dataScaleRadius, 'q', 10);

      const parseTime = d3.timeParse('%Y-%m-%d');

      data.forEach(d => {
        d[this.radiusProperty] = +d[this.radiusProperty]
        d[this.xAxisProp] = parseTime(d[this.xAxisProp])
        if (d[this.radiusProperty] > arrayScaleRadius[0] && d[this.radiusProperty] <= arrayScaleRadius[1]) {
          d.radius = 2
        } else if (d[this.radiusProperty] >= arrayScaleRadius[1] && d[this.radiusProperty] <= arrayScaleRadius[2]) {
          d.radius = 3.25
        } else if (d[this.radiusProperty] >= arrayScaleRadius[2] && d[this.radiusProperty] <= arrayScaleRadius[3]) {
          d.radius = 4.5
        } else if (d[this.radiusProperty] >= arrayScaleRadius[3] && d[this.radiusProperty] <= arrayScaleRadius[4]) {
          d.radius = 5.75
        } else if (d[this.radiusProperty] >= arrayScaleRadius[4] && d[this.radiusProperty] <= arrayScaleRadius[5]) {
          d.radius = 7
        } else if (d[this.radiusProperty] >= arrayScaleRadius[5] && d[this.radiusProperty] <= arrayScaleRadius[6]) {
          d.radius = 8.25
        } else if (d[this.radiusProperty] >= arrayScaleRadius[6] && d[this.radiusProperty] <= arrayScaleRadius[7]) {
          d.radius = 9.5
        } else if (d[this.radiusProperty] >= arrayScaleRadius[7] && d[this.radiusProperty] <= arrayScaleRadius[8]) {
          d.radius = 10.75
        } else if (d[this.radiusProperty] >= arrayScaleRadius[8] && d[this.radiusProperty] <= arrayScaleRadius[9]) {
          d.radius = 12
        } else if (d[this.radiusProperty] >= arrayScaleRadius[9] && d[this.radiusProperty] <= arrayScaleRadius[10]) {
          d.radius = 13.25
        } else if (d[this.radiusProperty] >= arrayScaleRadius[10]) {
          d.radius = 14.5
        }
      })

      return data
    },
    wrapTextLabel(text, width) {
      text.each(function() {
        var text = d3.select(this),
            words = text.text().split(/\s+/).reverse(),
            word,
            line = [],
            lineNumber = 0,
            lineHeight = 1,
            y = text.attr("y"),
            dy = 0.2,
            tspan = text.text(null).append("tspan").attr("x", 0).attr("y", y).attr("dy", dy + "em");
        while (word = words.pop()) {
          line.push(word);
          tspan.text(line.join(" "));
          if (tspan.node().getComputedTextLength() > width) {
            line.pop();
            tspan.text(line.join(" "));
            line = [word];
            tspan = text.append("tspan").attr("x", 0).attr("y", y).attr("dy", ++lineNumber * lineHeight + dy + "em").text(word);
          }
        }
      });
    },
    resizeListener() {
      window.addEventListener("resize", () => {
        const containerChart = document.getElementsByClassName('beeswarm-container')[0];
        this.svgWidth = containerChart.offsetWidth
        this.setupElements()
        this.buildBeesWarm(this.data)
      })
    }
  }
}
</script>
