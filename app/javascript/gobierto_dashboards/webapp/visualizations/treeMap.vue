<template>
  <div class="container-tree-map">
    <div class="treemap-tooltip"></div>
    <svg
      id="treemap-contracts"
      :width="svgWidth"
      :height="svgHeight"
    >
    </svg>
  </div>
</template>
<script>

import { select, selectAll, mouse } from 'd3-selection'
import { treemap, stratify } from 'd3-hierarchy'
import { scaleOrdinal } from 'd3-scale'
import { getQueryData, sumDataByGroupKey } from "../lib/utils";
import { money } from "lib/shared";

const d3 = { select, selectAll, treemap, stratify, scaleOrdinal, mouse }

export default {
  name: 'TreeMap',
  props: {
    data: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      svgWidth: 0,
      svgHeight: 400
    }
  },
  watch: {
    data(newValue, oldValue) {
      if (newValue !== oldValue) {
        this.deepCloneData(newValue)
      }
    }
  },
  mounted() {
    this.svgWidth = document.getElementsByClassName("dashboards-home-main")[0].offsetWidth;
    this.transformDataTreemap(this.data)
  },
  methods: {
    deepCloneData(data) {
      const dataTreeMap = JSON.parse(JSON.stringify(data));
      this.transformDataTreemap(dataTreeMap)
    },
    transformDataTreemap(data) {
      data.forEach(d => {
        d.final_amount_no_taxes = +d.final_amount_no_taxes
        d.value = 1
      })

      const finalAmountTotal = sumDataByGroupKey(data, 'contract_type', 'final_amount_no_taxes')
      const countTotalContractsByType = sumDataByGroupKey(data, 'contract_type', 'value')

      let dataContractsLine = finalAmountTotal.map((item, i) => Object.assign({}, item, countTotalContractsByType[i]));

      this.buildTreeMap(dataContractsLine)

    },
    buildTreeMap(typeOfContracts) {
      typeOfContracts.forEach(d => {
        d.parent = 'contract'
      })

      typeOfContracts.unshift({
        contract_type: 'contract',
        parent: '',
        total: ''
      });

      const arrayGobiertoColors = ['#12365B', '#008E9C', '#FF776D', '#F8B205']
      const color = d3.scaleOrdinal(arrayGobiertoColors);

      const tooltip = d3.select('.treemap-tooltip')

      const svg = d3.select('#treemap-contracts')

      const rootTreeMap = d3.stratify()
        .id(d => d.contract_type)
        .parentId(d => d.parent)(typeOfContracts)
        .sum(d => +d.value)

      d3.treemap()
        .size([this.svgWidth, this.svgHeight])
        .padding(4)(rootTreeMap)

      const rectsTreeMap = svg
        .selectAll(".rect-treemap")

      rectsTreeMap
        .remove().exit()
        .data(rootTreeMap.leaves())
        .enter()
        .append("rect")
        .attr('class', 'rect-treemap')
          .attr('x', d => d.x0)
          .attr('y', d => d.y0)
          .attr('width', d => d.x1 - d.x0)
          .attr('height', d => d.y1 - d.y0)
          .style('fill', d => d.color = color(d.id))
        .on("mousemove", function(d) {
          const coordinates = d3.mouse(this);
          const x = coordinates[0];
          const y = coordinates[1];

          const container = document.getElementsByClassName('container-tree-map')[0];
          const containerWidth = container.offsetWidth
          const tooltipWidth = tooltip.node().offsetWidth
          const positionWidthTooltip = x + tooltipWidth
          const positionTop = `${y - 20}px`
          const positionLeft = `${x + 10}px`
          const positionRight = `${x - tooltipWidth - 30}px`

          const { data: { contract_type, value } } = d
          tooltip
            .style("display", "block")
            .html(`
              <span class="beeswarm-tooltip-header-title">
                ${contract_type}
              </span>
              <div class="beeswarm-tooltip-table-element">
                <span class="beeswarm-tooltip-table-element-text">
                  ${I18n.t('gobierto_dashboards.dashboards.visualizations.tooltip_treemap')}:
                </span>
                <span class="beeswarm-tooltip-table-element-text">
                   <b>${value}</b>
                </span>
              </div>
            `)
            .style('top', positionTop)
            .style('left', positionWidthTooltip > containerWidth ? positionRight : positionLeft)
        })
        .on('mouseout', function() {
          tooltip.style('display', 'none')
        })

      const legendsName = svg
        .selectAll(".name")
        .remove().exit()

      legendsName
        .data(rootTreeMap.leaves())
        .enter()
        .append("text")
          .attr('class', (d) => {
            if (d.data.value > 30) {
              return 'name name-max'
            } else {
              return 'name name-min'
            }
          })
          .attr("x", d => d.x0 + 6)
          .attr('y', (d) => {
            if (d.data.value < 30) {
              return d.y0 + 17
            } else {
              return d.y0 + 20
            }
          })
          .text(d => d.id)
          .attr("fill", "white")

      const legendsValue = svg
        .selectAll(".value")
        .remove().exit()

      legendsValue
        .data(rootTreeMap.leaves())
        .enter()
        .append("text")
          .attr('class', (d) => {
            if (d.data.value > 30) {
              return 'value value-max'
            } else {
              return 'value value-min'
            }
          })
          .attr("x", d => d.x0 + 6)
          .attr('y', (d) => {
            if (d.data.value < 30) {
              return d.y0 + 30
            } else {
              return d.y0 + 40
            }
          })
          .text(d => `${money(d.data.final_amount_no_taxes, { minimumFractionDigits: 0, maximumFractionDigits: 0 })}`)
          .attr("fill", "white")

    }
  }
}
</script>
