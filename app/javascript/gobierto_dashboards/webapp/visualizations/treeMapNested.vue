<template>
  <div class="container-tree-map-nested">
    <svg
      id="treemap-nested"
      :width="svgWidth"
      :height="svgHeight"
    />
  </div>
</template>
<script>

import { select, selectAll, mouse } from 'd3-selection'
import { treemap, stratify, hierarchy, treemapBinary } from 'd3-hierarchy'
import { scaleLinear } from 'd3-scale'
import { easeLinear } from 'd3-ease'
import { mean, median } from "d3-array";
import { nest } from "d3-collection";
import { money } from "lib/shared";

const d3 = { select, selectAll, treemap, stratify, scaleLinear, mouse, easeLinear, mean, median, nest, hierarchy }

export default {
  name: 'TreeMapNested',
  props: {
    data: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      svgWidth: 0,
      svgHeight: 400,
      dataTreeMapWithoutCoordinates: undefined,
      updateData: false,
      dataForTableTooltip: undefined,
      dataNewValues: undefined,
      sizeForTreemap: 'value',
      selected_size: 'value',
      labelContractAmount: I18n.t('gobierto_dashboards.dashboards.contracts.contract_amount'),
      labelContractTotal: I18n.t('gobierto_dashboards.dashboards.visualizations.tooltip_treemap')
    }
  },
  watch: {
    data(newValue, oldValue) {
      if (newValue !== oldValue) {
        /*this.dataNewValues = newValue
        this.deepCloneData(newValue)
        this.updateData = true*/
      }
    }
  },
  mounted() {
    this.svgWidth = document.getElementsByClassName("dashboards-home-main")[0].offsetWidth;
    this.dataTreeMapWithoutCoordinates = JSON.parse(JSON.stringify(this.data));

    this.transformDataTreemap(this.data)
    /*this.resizeListener()*/
  },
  methods: {
    transformDataTreemap(data) {
      data.forEach(d => {
        d.final_amount_no_taxes = +d.final_amount_no_taxes
        d.value = 1
      })

      // d3v5
      //
      const dataGroupTreeMap = d3.nest().key(d => d.contract_type).key(d => d.assignee)
      .entries(data);
      this.buildTreeMap(dataGroupTreeMap)
      // d3v6
      //
      // const dataGroupTreeMap = Array.from(
      //   d3.group(data, d =>  d.contract_type, d.assignee),
      // );
    },
    deepCloneData(data) {
      const dataTreeMap = JSON.parse(JSON.stringify(data));
      this.dataForTooltips(dataTreeMap)
      this.transformDataTreemap(dataTreeMap)
    },
    buildTreeMap(data) {
      const x = d3.scaleLinear().rangeRound([0, this.svgWidth]);
      const y = d3.scaleLinear().rangeRound([0, this.height]);
      function treemap(data) {
        return d3.treemap()
          .tile(tile)
        (d3.hierarchy(data)
          .sum(d => d.value)
          .sort((a, b) => b.value - a.value))
      }

      function tile(node, x0, y0, x1, y1) {
        d3.treemapBinary(node, 0, 0, this.svgWidth, this.height);
        for (const child of node.children) {
          child.x0 = x0 + child.x0 / this.svgWidth * (x1 - x0);
          child.x1 = x0 + child.x1 / this.svgWidth * (x1 - x0);
          child.y0 = y0 + child.y0 / this.height * (y1 - y0);
          child.y1 = y0 + child.y1 / this.height * (y1 - y0);
        }
      }

      const svg = d3.select("#treemap-nested")

      let group = svg.append("g")
          .call(render, treemap(data));

      function render(group, root) {
          const node = group
            .selectAll("g")
            .data(root.children.concat(root))
            .join("g");

          node.filter(d => d === root ? d.parent : d.children)
              .attr("cursor", "pointer")
              .on("click", (event, d) => d === root ? zoomout(root) : zoomin(d));

          node.append("title")
              .text(d => `${name(d)}\n${format(d.value)}`);

          node.append("rect")
              .attr("id", d => (d.leafUid = DOM.uid("leaf")).id)
              .attr("fill", d => d === root ? "#fff" : d.children ? "#ccc" : "#ddd")
              .attr("stroke", "#fff");

          node.append("clipPath")
              .attr("id", d => (d.clipUid = DOM.uid("clip")).id)
            .append("use")
              .attr("xlink:href", d => d.leafUid.href);

          node.append("text")
              .attr("clip-path", d => d.clipUid)
              .attr("font-weight", d => d === root ? "bold" : null)
            .selectAll("tspan")
            .data(d => (d === root ? name(d) : d.data.name).split(/(?=[A-Z][^A-Z])/g).concat(format(d.value)))
            .join("tspan")
              .attr("x", 3)
              .attr("y", (d, i, nodes) => `${(i === nodes.length - 1) * 0.3 + 1.1 + i * 0.9}em`)
              .attr("fill-opacity", (d, i, nodes) => i === nodes.length - 1 ? 0.7 : null)
              .attr("font-weight", (d, i, nodes) => i === nodes.length - 1 ? "normal" : null)
              .text(d => d);

          group.call(position, root);
      }

      function position(group, root) {
          group.selectAll("g")
              .attr("transform", d => d === root ? `translate(0,-30)` : `translate(${x(d.x0)},${y(d.y0)})`)
            .select("rect")
              .attr("width", d => d === root ? width : x(d.x1) - x(d.x0))
              .attr("height", d => d === root ? 30 : y(d.y1) - y(d.y0));
        }

        // When zooming in, draw the new nodes on top, and fade them in.
        function zoomin(d) {
          const group0 = group.attr("pointer-events", "none");
          const group1 = group = svg.append("g").call(render, d);

          x.domain([d.x0, d.x1]);
          y.domain([d.y0, d.y1]);

          svg.transition()
              .duration(750)
              .call(t => group0.transition(t).remove()
                .call(position, d.parent))
              .call(t => group1.transition(t)
                .attrTween("opacity", () => d3.interpolate(0, 1))
                .call(position, d));
        }

        // When zooming out, draw the old nodes on top, and fade them out.
        function zoomout(d) {
          const group0 = group.attr("pointer-events", "none");
          const group1 = group = svg.insert("g", "*").call(render, d.parent);

          x.domain([d.parent.x0, d.parent.x1]);
          y.domain([d.parent.y0, d.parent.y1]);

          svg.transition()
              .duration(750)
              .call(t => group0.transition(t).remove()
                .attrTween("opacity", () => d3.interpolate(1, 0))
                .call(position, d))
              .call(t => group1.transition(t)
                .call(position, d.parent));
        }

        return svg.node();
    },
    resizeListener() {
      window.addEventListener("resize", () => {
        let dataResponsive = this.updateData ? this.deepCloneData(this.dataNewValues) : this.transformDataTreemap(this.data);
        const containerChart = document.getElementsByClassName('container-tree-map')[0];
        this.svgWidth = containerChart.offsetWidth
        this.deepCloneData(dataResponsive)
      })
    }
  }
}
</script>
