<template>
  <div class="beeswarm-container">
    <div class="beeswarm-tooltip" />
    <svg
      :width="svgWidth"
      :height="svgHeight"
      class="beeswarm-plot"
    />
  </div>
</template>
<script>
// TODO: BE CAREFUL, THIS IS NOT A REAL COMPONENT
// There are some fields depending on the dataset:
// - contract_type
// - start_date_year
// - final_amount_no_taxes
// - assignee

import { select, selectAll } from "d3-selection";
import { scaleBand, scaleTime, scalePow } from "d3-scale";
import { forceSimulation, forceX, forceY, forceCollide } from "d3-force";
import { axisBottom, axisLeft } from "d3-axis";
import { extent } from "d3-array";
import { timeFormatLocale } from "d3-time-format";
import { max } from "d3-array";
import { d3locale, createScaleColors, slugString } from "lib/shared";
import { easeLinear } from "d3-ease";

export default {
  name: "BeesWarmChart",
  props: {
    data: {
      type: Array,
      default: () => []
    },
    height: {
      default: 600,
      type: Number
    },
    radiusProperty: {
      default: "",
      type: String
    },
    xAxisProp: {
      default: "",
      type: String
    },
    yAxisProp: {
      default: "",
      type: String
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
      svgHeight: 0,
      margin: {
        left: this.marginLeft,
        right: this.marginRight,
        top: this.marginTop,
        bottom: this.marginBottom
      },
      padding: 1.5,
      arrayValuesContractTypes: []
    };
  },
  watch: {
    data(newValue, oldValue) {
      if (newValue !== oldValue) {
        this.buildBeesWarm(newValue);
      }
    }
  },
  mounted() {
    const containerChart = document.querySelector(".beeswarm-container");
    this.svgWidth = containerChart.offsetWidth;
    this.svgHeight = this.height;

    /*To avoid add/remove colors in every update use Object.freeze(this.data)
    to create a scale/domain color persistent with the original keys*/
    const freezeObjectColors = Object.freeze(this.data);
    const arrayValuesContractTypes = Array.from(
      new Set(freezeObjectColors.map(d => slugString(d.contract_type)))
    );
    this.colors = createScaleColors(
      arrayValuesContractTypes.length,
      arrayValuesContractTypes
    );

    this.setupElements();
    this.buildBeesWarm(this.data);
    window.addEventListener("resize", this.resizeListener);
  },
  destroyed() {
    window.removeEventListener("resize", this.resizeListener);
  },
  methods: {
    setupElements() {
      const svg = select(".beeswarm-plot");
      const g = svg.append("g").attr("class", "beeswarm-plot-container");
      g.append("g").attr("class", "axis axis-x");
      g.append("g").attr("class", "axis axis-y");
    },
    buildBeesWarm(data) {
      const filterData = this.transformData(data);
      const arrayValuesScaleY = Array.from(
        new Set(filterData.map(d => d[this.yAxisProp]))
      );
      this.svgHeight = this.data.length > 400 ? 820 : this.height;

      const svg = select(".beeswarm-plot");

      const translate =
        arrayValuesScaleY.length === 1
          ? `translate(0,${this.margin.bottom})`
          : "translate(0,0)";

      const g = svg.select(".beeswarm-plot-container");

      g.attr("transform", translate);

      const scaleY = scaleBand()
        .domain(arrayValuesScaleY)
        .range([this.svgHeight, this.margin.top]);

      const scaleX = scaleTime()
        .domain(extent(filterData, d => d[this.xAxisProp]))
        .rangeRound([this.margin.left, this.svgWidth - this.margin.right]);

      const axisX = axisBottom(scaleX)
        .tickPadding(20)
        .tickFormat(d => {
          let _mf =
            Array.from(new Set(filterData.map(d => d.start_date_year)))
              .length <= 2
              ? timeFormatLocale(d3locale[I18n.locale]).format("%b-%Y")
              : timeFormatLocale(d3locale[I18n.locale]).format("%Y");
          return _mf(d);
        })
        .tickSize(-this.svgHeight)
        .ticks(5);

      g.select(".axis-x")
        .attr("transform", `translate(0,${this.svgHeight - this.margin.top})`)
        .transition()
        .duration(200)
        .call(axisX);

      const axisY = axisLeft(scaleY);

      g.select(".axis-y")
        .attr(
          "transform",
          `translate(0,${-(this.margin.bottom + this.margin.top)})`
        )
        .call(axisY);

      g.selectAll(".label-y")
        .data(arrayValuesScaleY)
        .join("text")
        .attr("class", "label-y")
        .attr("x", 0)
        .attr("y", d => scaleY(d))
        .attr("alignment-baseline", "middle")
        .text(d => d);

      g.selectAll(".line-y")
        .data(arrayValuesScaleY)
        .join("line")
        .attr("class", "line-y")
        .attr("x1", this.margin.left)
        .attr("x2", this.svgWidth + this.margin.left + this.margin.right)
        .attr("y1", d => scaleY(d))
        .attr("y2", d => scaleY(d));

      g.selectAll(".label-y").call(this.wrapTextLabel, 120);

      forceSimulation(filterData)
        .force("x", forceX(d => scaleX(d[this.xAxisProp])))
        .force("y", forceY(d => scaleY(d[this.yAxisProp])))
        .force("collide", forceCollide().radius(d => d.radius + this.padding))
        .on("tick", () => {
          g.selectAll(".beeswarm-circle")
            .attr("cx", (d) => {
              // if (k[0] === 0) console.log(d, k);
              return d.x
            })
            .attr("cy", d => d.y);
        });

      g.selectAll(".beeswarm-circle")
        .data(filterData, d => d.slug)
        .join(
          enter => enter.append("circle"),
          update => {
            return update;
          }
        )
        .on("mouseover", (event, d) => {
          this.$emit("showTooltip", event, d);
          selectAll(`.beeswarm-circle`)
            .transition()
            .duration(200)
            .style("opacity", 0.1);
          selectAll(`#${event.slug}`)
            .filter((e, d) => e.slug !== d.slug)
            .transition()
            .duration(200)
            .ease(easeLinear)
            .style("opacity", 1);
        })
        .on("mouseout", () => {
          select(".beeswarm-tooltip")
            .style("opacity", 1)
            .transition()
            .duration(400)
            .style("opacity", 0);

          selectAll(`.beeswarm-circle`)
            .transition()
            .duration(450)
            .style("opacity", 1);
        })
        .on("click", d => this.$emit("goesToItem", d))
        .attr(
          "class",
          d =>
            `beeswarm-circle beeswarm-circle-${slugString(
              d.id
            )} beeswarm-circle-${d.slug_contract_type}`
        )
        .attr("id", d => d.slug)
        .attr("r", d => d.radius)
        .attr("fill", d => this.colors(d.slug_contract_type));
    },
    transformData(data) {
      const maxFinalAmount = max(data, d => d.final_amount_no_taxes);
      const rangeMax = data.length > 600 ? 15 : 28;

      const radiusScale = scalePow()
        .exponent(0.5)
        .range([3, rangeMax])
        .domain([0, maxFinalAmount]);

      data.forEach(d => {
        d.slug_contract_type = slugString(d.contract_type);
        if (d.assignee) {
          //Normalize assignee to create a slug for select ID's on mouseover
          d.slug = slugString(d.assignee);
        }

        d.radius = radiusScale(d[this.radiusProperty]);
      });

      return data
        .filter(
          ({ final_amount_no_taxes, [this.xAxisProp]: date }) =>
            final_amount_no_taxes !== 0 && !!date.getDate()
        )
        .sort(({ contract_type: a = "" }, { contract_type: b = "" }) =>
          a.localeCompare(b)
        );
    },
    wrapTextLabel(text, width) {
      text.each(function() {
        var text = select(this),
          words = text
            .text()
            .split(/\s+/)
            .reverse(),
          word,
          line = [],
          lineNumber = 0,
          lineHeight = 1,
          y = text.attr("y"),
          dy = 0.2,
          tspan = text
            .text(null)
            .append("tspan")
            .attr("x", 0)
            .attr("y", y)
            .attr("dy", dy + "em");
        while ((word = words.pop())) {
          line.push(word);
          tspan.text(line.join(" "));
          if (tspan.node().getComputedTextLength() > width) {
            line.pop();
            tspan.text(line.join(" "));
            line = [word];
            tspan = text
              .append("tspan")
              .attr("x", 0)
              .attr("y", y)
              .attr("dy", ++lineNumber * lineHeight + dy + "em")
              .text(word);
          }
        }
      });
    },
    resizeListener() {
      const containerChart = document.querySelector(".beeswarm-container");
      this.svgWidth = containerChart.offsetWidth;
      this.buildBeesWarm(this.data);
    }
  }
};
</script>
