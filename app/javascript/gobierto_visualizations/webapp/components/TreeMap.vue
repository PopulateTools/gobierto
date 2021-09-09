<template>
  <div class="tree-map-container">
    <div class="treemap-tooltip" />
    <div class="treemap-button-group button-group">
      <button
        class="button-grouped sort-G"
        :class="{ active : selected_size === 'final_amount_no_taxes' }"
        @click="handleTreeMapValue('final_amount_no_taxes')"
      >
        {{ labelContractAmount }}
      </button>
      <button
        class="button-grouped sort-G"
        :class="{ active : selected_size === 'value' }"
        @click="handleTreeMapValue('value')"
      >
        {{ labelContractTotal }}
      </button>
    </div>
    <svg
      id="treemap-contracts"
      :width="svgWidth"
      :height="svgHeight"
    />
  </div>
</template>
<script>

import { select, selectAll, mouse } from 'd3-selection'
import { treemap, stratify } from 'd3-hierarchy'
import { sumDataByGroupKey, slugString } from "../lib/utils";
import { easeLinear } from 'd3-ease'
import { mean, median } from "d3-array";
import { money } from "lib/vue/filters";
import { EventBus } from "../lib/mixins/event_bus";

const d3 = { select, selectAll, treemap, stratify, mouse, easeLinear, mean, median }

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
      svgHeight: 400,
      dataTreeMapWithoutCoordinates: undefined,
      updateData: false,
      dataForTableTooltip: undefined,
      dataNewValues: undefined,
      sizeForTreemap: 'value',
      selected_size: 'value',
      labelContractAmount: I18n.t('gobierto_visualizations.visualizations.contracts.contract_amount'),
      labelContractTotal: I18n.t('gobierto_visualizations.visualizations.visualizations.tooltip_treemap')
    }
  },
  watch: {
    data(newValue, oldValue) {
      if (newValue !== oldValue) {
        this.dataNewValues = newValue
        this.deepCloneData(newValue)
        this.updateData = true
      }
    }
  },
  mounted() {
    const containerChart = document.querySelector('.tree-map-container');
    this.svgWidth = containerChart.offsetWidth;
    this.dataTreeMapWithoutCoordinates = JSON.parse(JSON.stringify(this.data));
    this.dataTooltips = JSON.parse(JSON.stringify(this.data));

    this.dataForTooltips(this.dataTooltips)
    this.transformDataTreemap(this.data)

    window.addEventListener("resize", this.resizeListener)
  },
  destroyed() {
    window.removeEventListener("resize", this.resizeListener)
  },
  methods: {
    handleTreeMapValue(value) {
      if (this.selected_size === value) return;
      this.selected_size = value
      this.sizeForTreemap = value
      if (this.updateData) {
        this.deepCloneData(this.dataNewValues)
      } else {
        this.transformDataTreemap(this.data)
      }
    },
    deepCloneData(data) {
      const dataTreeMap = JSON.parse(JSON.stringify(data));
      this.dataForTooltips(dataTreeMap)
      this.transformDataTreemap(dataTreeMap)
    },
    transformDataTreemap(data) {
      data.forEach(d => {
        d.final_amount_no_taxes = +d.final_amount_no_taxes
        d.value = 1
      })
      const finalAmountTotal = sumDataByGroupKey(data, 'contract_type', 'final_amount_no_taxes')
      const countTotalContractsByType = sumDataByGroupKey(data, 'contract_type', 'value')

      let dataContractsTreeMap = finalAmountTotal.map((item, i) => Object.assign({}, item, countTotalContractsByType[i]));

      this.buildTreeMap(dataContractsTreeMap)

    },
    dataForTooltips(data) {
      /* To avoid mixin different values which could be interferent in the treeMap,
      it's better transform the data for tooltips in a different dataset */
      const arrayValues = Array.from(new Set(data.map((d) => d.contract_type)))

      this.dataForTableTooltip = this.operationsForTooltips(data, arrayValues)
    },
    operationsForTooltips(data, values) {
      /* Create an array of objects, create an object for every type of contract
      Inside, one key-value for mean, median, and the top five contracts by the final amount */
      let subDataTooltip = []
      for (let index = 0; index < values.length; index++) {
        let element = values[index]
        let tooltipData = {}
        let dataFilter = data.filter(contract => contract.contract_type === element)

        const amountsContractsArray = dataFilter.map(({ final_amount_no_taxes = 0 }) =>
          parseFloat(final_amount_no_taxes)
        );
        const meanContracts = d3.mean(amountsContractsArray);
        const medianContracts = d3.median(amountsContractsArray);

        let sortDataContracts = dataFilter.sort((a, b) => a.final_amount_no_taxes < b.final_amount_no_taxes);
        const getTopFiveContracts = Object.entries(sortDataContracts).slice(0,5).map(entry => entry[1]);

        tooltipData = {
          contract_type: element,
          mean: meanContracts,
          median: medianContracts,
          top_contracts: getTopFiveContracts
        };

        subDataTooltip.push(tooltipData);
      }
      return subDataTooltip
    },
    buildTreeMap(typeOfContracts) {
      let categoryID
      typeOfContracts.forEach(d => {
        d.parent = 'contract'
      })

      typeOfContracts.unshift({
        contract_type: 'contract',
        parent: '',
        total: ''
      });

      const tooltip = d3.select('.treemap-tooltip')

      const svg = d3.select('#treemap-contracts')

      const rootTreeMap = d3.stratify()
        .id(d => d.contract_type)
        .parentId(d => d.parent)(typeOfContracts)
        .sum(d => +d[this.sizeForTreemap])

      let dataForTableTooltip = this.dataForTableTooltip

      d3.treemap()
        .size([this.svgWidth, this.svgHeight])
        .padding(4)
        .round(true)(rootTreeMap)

      const t = svg.transition()
        .duration(250)
        .ease(d3.easeLinear);

      svg
        .selectAll(".rect-treemap")
        .data(rootTreeMap.leaves())
        .join(
          enter => enter.append("rect")
            .attr('x', d => d.x0)
            .attr('y', d => d.y0)
            .attr('width', d => d.x1 - d.x0)
            .attr('height', d => d.y1 - d.y0)
            .call(enter => enter.transition(t)),
          update => update
            .attr('x', d => d.x0)
            .attr('y', d => d.y0)
            .attr('width', d => d.x1 - d.x0)
            .attr('height', d => d.y1 - d.y0)
            .call(update => update.transition(t)),
          exit => exit
            .attr('width', 0)
            .attr('height', 0)
            .call(exit => exit.transition(t)
            .remove())
        )
        .attr('class', d => {
          d.id = slugString(d.id)
          return `rect-treemap treemap-${d.id}`
        })
        .on("mousemove", function(d) {
          const [x, y] = d3.mouse(this);

          //Elements to determinate the position of tooltip
          const container = document.querySelector('.tree-map-container');
          const containerWidth = container.offsetWidth
          const tooltipWidth = tooltip.node().offsetWidth
          const positionWidthTooltip = x + tooltipWidth
          const positionTop = `${y - 20}px`
          const positionLeft = `${x + 10}px`
          const positionRight = `${x - tooltipWidth - 10}px`

          const { data: { contract_type: type_of_contract, value, final_amount_no_taxes } } = d

          //Create a template string with the top five of contracts by the final amount
          let filterDataTableTooltip = dataForTableTooltip.filter(({ contract_type }) => contract_type === type_of_contract)
          filterDataTableTooltip = Object.assign({}, ...filterDataTableTooltip);
          const { mean, median, top_contracts: topFiveContracts } = filterDataTableTooltip

          let templateStringTopFiveContracts = ''
          for (let index = 0; index < topFiveContracts.length; index++) {
            let element = topFiveContracts[index]
            templateStringTopFiveContracts = `${templateStringTopFiveContracts}<div class="tooltip-table-treemap-element">
              <span class="tooltip-table-treemap-element-text tooltip-table-treemap-element-assignee">${element.assignee}</span>
              <span class="tooltip-table-treemap-element-text tooltip-table-treemap-element-amount">${money(element.final_amount_no_taxes)}</span>
            </div>`
          }

          tooltip
            .style("display", "block")
            .html(() => {
                return `
                <span class="beeswarm-tooltip-header-title">
                  ${type_of_contract}
                </span>
                <div class="beeswarm-tooltip-table-element">
                  <span class="beeswarm-tooltip-table-element-text">
                    <b>${value}</b> ${I18n.t('gobierto_visualizations.visualizations.contracts.summary.contracts_for')} <b>${money(final_amount_no_taxes)}</b>
                  </span>
                  <span class="beeswarm-tooltip-table-element-text">
                     ${I18n.t('gobierto_visualizations.visualizations.contracts.summary.mean_amount')}: <b>${money(mean)}</b>
                  </span>
                  <span class="beeswarm-tooltip-table-element-text">
                     ${I18n.t('gobierto_visualizations.visualizations.contracts.summary.median_amount')}: <b>${money(median)}</b>
                  </span>
                </div>
                <div class="tooltip-table-treemap">
                  <div class="tooltip-table-treemap-header">
                    <div class="tooltip-table-treemap-header-element">
                      <b>${I18n.t('gobierto_visualizations.visualizations.contracts.assignee')}</b>
                    </div>
                    <div class="tooltip-table-treemap-header-element">
                      <b>${I18n.t('gobierto_visualizations.visualizations.contracts.contract_amount')}</b>
                    </div>
                  </div>
                  <div class="tooltip-table-treemap-body">
                    <div class="tooltip-table-treemap-element">
                      ${templateStringTopFiveContracts}
                    </div>
                  </div>
                </div>
              `
            })
            .style('top', positionTop)
            .style('left', positionWidthTooltip > containerWidth ? positionRight : positionLeft)
        })
        .on('mouseout', function() {
          tooltip.style('display', 'none')
        })
        .on('click', function(d) {
          const { data: { contract_type } } = d
          if (contract_type === 'Servicios') {
            categoryID = 0
          } else if (contract_type === 'Suministros') {
            categoryID = 1
          } else if (contract_type === 'Obras') {
            categoryID = 2
          } else if (contract_type === 'Gestión de servicios públicos') {
            categoryID = 3
          }
          EventBus.$emit("treemap-filter", {
            category: "contract_types",
            id: categoryID
          });
        })

      svg
        .selectAll(".name")
        .data(rootTreeMap.leaves())
        .join("text")
        .attr('id', d => `name-${d.id}`)
        .attr("x", d => d.x0 + 6)
        .attr('y', d => d.y0 + 20)
        .text(d => d.id)
        .attr('class', (d) => {
          let widthRect = d.x1 - d.x0
          let widthText = document.getElementById(`name-${d.id}`).getBoundingClientRect().width
          //Compare with of the text element with the width of the rect, to hide/show the literals
          if (widthText < widthRect) {
            return 'name name-max'
          } else {
            return 'name name-hide'
          }
        })

      const legendsValue = svg
        .selectAll(".value")
        .remove().exit()

      legendsValue
        .data(rootTreeMap.leaves())
        .enter()
        .append("text")
        .transition(t)
          .attr('id', d => `value-${d.id}`)
          .attr("x", d => d.x0 + 6)
          .attr('y', d => d.y0 + 40)
          .text(d => `${money(d.data.final_amount_no_taxes, { minimumFractionDigits: 0, maximumFractionDigits: 0 })}`)
          .attr('class', (d) => {
            let widthRect = d.x1 - d.x0
            let widthText = document.getElementById(`name-${d.id}`).getBoundingClientRect().width
            //Compare with of the text element with the width of the rect, to hide/show the literals
            if (widthText < widthRect && widthText !== 0) {
              return 'value value-max'
            } else {
              return 'value value-hide'
            }
          })

      const legendsValueContracts = svg
        .selectAll(".value-contracts")
        .remove().exit()

      legendsValueContracts
        .data(rootTreeMap.leaves())
        .enter()
        .append("text")
        .transition(t)
          .attr('id', d => `value-${d.id}`)
          .attr("x", d => d.x0 + 6)
          .attr('y', d => d.y0 + 60)
          .text(d => `${d.data.value} ${I18n.t('gobierto_visualizations.visualizations.contracts.contracts')}`)
          .attr('class', (d) => {
            let widthRect = d.x1 - d.x0
            let widthText = document.getElementById(`name-${d.id}`).getBoundingClientRect().width
            //Compare with of the text element with the width of the rect, to hide/show the literals
            if (widthText < widthRect && widthText !== 0) {
              return 'value-contracts value value-max'
            } else {
              return 'value-contracts value value-hide'
            }
          })
    },
    resizeListener() {
      let dataResponsive = this.updateData ? this.deepCloneData(this.dataNewValues) : this.transformDataTreemap(this.data);
      const containerChart = document.querySelector('.tree-map-container');
      this.svgWidth = containerChart.offsetWidth
      this.deepCloneData(dataResponsive)
    }
  }
}
</script>
