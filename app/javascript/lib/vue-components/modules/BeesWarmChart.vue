<template>
  <div class="beeswarm-container">
    <p>Contratos por tipo, volumen, tamaño y fecha</p>
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
    scaleYProperty: {
      default: '',
      type: String,
    },
    scaleXProperty: {
      default: '',
      type: String,
    },
    marginLeft: {
      type: Number,
      default: 100
    },
    marginRight: {
      type: Number,
      default: 30
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
      margin: {
        left: this.marginLeft,
        right: this.marginRight,
        top: this.marginTop,
        bottom: this.marginBottom
      },
      padding: 1.5
    }
  },
  mounted() {
    const containerChart = document.getElementsByClassName('beeswarm-container')[0];
    this.svgWidth = containerChart.offsetWidth
    this.setupElements()
    this.buildBeesWarm(this.data)
  },
  methods: {
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
        .domain(filterData.map((d) => d[this.scaleYProperty]))
        .range([this.height + this.margin.bottom, this.margin.top])

      const scaleX = d3.scaleTime()
        .domain(d3.extent(filterData, d => d.date))
        .nice()
        .range([this.margin.left, this.svgWidth])

      const axisX = d3
        .axisBottom(scaleX)
        .tickPadding(20)
        .tickFormat(d3.timeFormat("%Y"))
        .tickSize(-this.height)
        .ticks(5)

      g.select('.axis-x')
        .attr('transform', `translate(${-this.margin.left},${this.height - this.margin.top})`)
        .call(axisX)

      const axisY = d3
        .axisLeft(scaleY)
        .tickFormat(d => d)
        .tickSize(-this.svgWidth)
        .ticks(6)

      g.select('.axis-y')
        .attr('transform', `translate(0,${-(this.margin.bottom + this.margin.top)})`)
        .call(axisY)
      .selectAll(".tick text")
            .call(this.wrapTextLabel, 150);

      const simulation = d3.forceSimulation(filterData)
        .force('x', d3.forceX((d) => scaleX(d.date)).strength(0.5))
        .force('y', d3.forceY((d) => scaleY(d[this.scaleYProperty])))
        .force('collide', d3.forceCollide().strength(0.3).radius(d => d.radius + this.padding))

      svg.selectAll('circle')
        .data(filterData)
        .join('circle')
        .attr('class', 'beeswarm-circle')
        .attr('cx', (d) => scaleX(d.date))
        .attr('cy', (d) => scaleY(d[this.scaleYProperty]))
        .attr('r', (d) => d.radius)
        .attr('stroke', '#111')
        .attr('fill-opacity', 0.9)
        .style('fill', d => d.color = color(d[this.scaleYProperty]))
        .on("mouseover", (event, d) => {
          this.$emit("showTooltip", event, d)
        })
        .on("mouseout", () => {
          d3.select('.beeswarm-tooltip')
            .style('display', 'none')
        })
        .on("click", (event, d) => {
          this.$emit("goesToItem", d)
        })

      for (let i = 0; i < 120; i++) {
        simulation.tick();

        svg.selectAll('circle')
          .data(filterData)
          .attr('cx', (d) => d.x - this.margin.right)
          .attr('cy', (d) => d.y);

      }
    },
    transformData(data) {
      let dataScaleRadius = data.map((d) => +d[this.radiusProperty])
      const arrayScaleRadius = chroma.limits(dataScaleRadius, 'q', 4);

      const parseTime = d3.timeParse('%Y-%m-%d');

      data.forEach(d => {
        d[this.radiusProperty] = +d[this.radiusProperty]
        d.date = parseTime(d[this.scaleXProperty])
        if (d[this.radiusProperty] > arrayScaleRadius[0] && d[this.radiusProperty] <= arrayScaleRadius[1]) {
          d.radius = 4
        } else if (d[this.radiusProperty] >= arrayScaleRadius[1] && d[this.radiusProperty] <= arrayScaleRadius[2]) {
          d.radius = 6
        } else if (d[this.radiusProperty] >= arrayScaleRadius[2] && d[this.radiusProperty] <= arrayScaleRadius[3]) {
          d.radius = 8
        } else if (d[this.radiusProperty] >= arrayScaleRadius[4] ) {
          d.radius = 10
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
            lineHeight = 0.75, // ems
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
    }
  }
}
</script>
