<template>
  <TreeMapNested
    :data="data"
    :root-data="rootData"
    :label-root-key="labelRootKey"
    :first-depth-for-tree-map="firstDepthForTreemap"
    :second-depth-for-tree-map="secondDepthForTreemap"
    :third-depth-for-tree-map="thirdDepthForTreemap"
    :scale-color-key="scaleColorKey"
    :treemap-id="'entity'"
    :amount="'final_amount_no_taxes'"
    :scale-color="true"
    :first-button-value="'final_amount_no_taxes'"
    :second-button-value="'number_of_contract'"
    :first-button-label="labelContractAmount"
    :second-button-label="labelContractTotal"
    :label-total-plural="labelContractsPlural"
    :label-total-unique="labelContractsUnique"
    :depth-entity="true"
    :key-for-third-depth="'title'"
    @transformData="nestedData"
    @showTooltip="showTooltipTreemap"
    @on-treemap-click="goesToTreemapItem"
  />
</template>
<script>
import { nest } from "d3-collection";
import { select, mouse } from 'd3-selection';
import TreeMapNested from "../../visualizations/treeMapNested.vue";
import { sumDataByGroupKey } from "../../lib/utils";
import { money } from "lib/vue/filters";

const d3 = { nest, select, mouse }

export default {
  name: 'EntityTreeMapNested',
  components: {
    TreeMapNested
  },
  props: {
    data: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      labelRootKey: '',
      labelRootKeyEntities: I18n.t('gobierto_visualizations.visualizations.contracts.entities') || '',
      labelRootKeyContractType: I18n.t('gobierto_visualizations.visualizations.contracts.contract_type') || '',
      labelContractAmount: I18n.t('gobierto_visualizations.visualizations.contracts.contract_amount') || '',
      labelContractTotal: I18n.t('gobierto_visualizations.visualizations.visualizations.tooltip_treemap') || '',
      labelContractsPlural: I18n.t('gobierto_visualizations.visualizations.contracts.contracts') || '',
      labelContractsUnique: I18n.t('gobierto_visualizations.visualizations.contracts.contract') || '',
      rootData: {},
      deepLevel: 3,
      firstDepthForTreemap: '',
      secondDepthForTreemap: '',
      thirdDepthForTreemap: '',
      scaleColorKey: 'contractor',
      contractorArray: [...new Set(this.data.map(item => item.contractor))]
    }
  },
  methods: {
    nestedData(data, sizeForTreemap) {
      const dataFilter = data.filter(contract => contract.final_amount_no_taxes !== 0)
      dataFilter.forEach(d => {
        d.number_of_contract = 1
      })
      // d3v6
      //
      // const dataGroupTreeMap = Array.from(
      //   d3.group(data, d =>  d.contract_type, d.assignee),
      // );
      this.deepLevel = this.contractorArray.length === 1 ? 3 : 4
      let nested_data
      if (this.contractorArray.length === 1) {
        this.labelRootKey = this.labelRootKeyContractType
        this.scaleColorKey = 'contract_type'
        this.firstDepthForTreemap = 'contract_type'
        this.secondDepthForTreemap = 'assignee'
        this.thirdDepthForTreemap = ''
        nested_data = d3.nest()
          .key(d => d[this.firstDepthForTreemap])
          .key(d => d[this.secondDepthForTreemap])
          .entries(dataFilter);
      } else {
        this.labelRootKey = this.labelRootKeyEntities
        this.scaleColorKey = 'contractor'
        this.firstDepthForTreemap = 'contractor'
        this.secondDepthForTreemap = 'contract_type'
        this.thirdDepthForTreemap = 'assignee'
        nested_data = d3.nest()
          .key(d => d[this.firstDepthForTreemap])
          .key(d => d[this.secondDepthForTreemap])
          .key(d => d[this.thirdDepthForTreemap])
          .entries(dataFilter);
      }

      let rootData = {};

      rootData.key = this.labelRootKey
      rootData.values = nested_data;

      rootData = replaceDeepKeys(rootData, sizeForTreemap);
      //d3 Nest add names to the keys that are not valid to build a treemap, we need to replace them
      function replaceDeepKeys(root, value_key) {
        for (var key in root) {
          if (key === "key") {
            root.name = root.key;
            delete root.key;
          }
          if (key === "values") {
            root.children = [];
            for (key in root.values) {
              root.children.push(replaceDeepKeys(root.values[key], value_key));
            }
            delete root.values;
          }
          if (key === value_key) {
            root.value = parseFloat(root[value_key]);
          }
        }
        return root;
      }
      this.rootData = rootData
    },
    showTooltipTreemap(d, i, selected_size, event) {
      const dataTreeMapSumFinalAmount = JSON.parse(JSON.stringify(this.data));
      const { depth } = d
      const [x, y] = d3.mouse(event[0]);

      //Elements to determinate the position of tooltip
      const tooltipFirstDepth = d3.select('#treemap-nested-tooltip-first-depth-entity')
      const tooltipSecondDepth = d3.select('#treemap-nested-tooltip-second-depth-entity')
      const container = document.querySelector('.treemap-nested-container-entity');
      const containerWidth = container.offsetWidth
      const tooltipWidth = depth !== 4 ? tooltipFirstDepth.node().offsetWidth : tooltipSecondDepth.node().offsetWidth
      const tooltipHeight = depth !== 4 ? tooltipFirstDepth.node().offsetHeight : tooltipSecondDepth.node().offsetHeight
      const positionWidthTooltip = x + tooltipWidth
      const positionRight = `${x - tooltipWidth - 20}px`
      const positionTop = tooltipHeight + y > window.innerHeight ? `${y - (tooltipHeight / 2)}px` : `${y}px`
      const positionLeft = `${x + 20}px`

      const childrenElement = event[0].children[0].className
      if (this.deepLevel === 4) {
        if (depth === 1 && childrenElement.includes('hide')) {
          let valueTotalAmount
          if (typeof d.data !== "function") {
            let contractType = d.data.name !== undefined ? d.data.name : ''
            const finalAmountTotal = sumDataByGroupKey(dataTreeMapSumFinalAmount, 'contractor', 'final_amount_no_taxes')
            let totalAmount = finalAmountTotal.filter(contract => contract['contractor'] === contractType)
            totalAmount = totalAmount.filter(contract => typeof contract.data !== "function")
            valueTotalAmount = totalAmount[0]['final_amount_no_taxes']
          }
          tooltipFirstDepth
            .style("display", "block")
            .transition()
            .duration(200)
            .style("opacity", 1)

          tooltipFirstDepth
            .html(() => {
              let labelTotalContracts = `${I18n.t('gobierto_visualizations.visualizations.contracts.contracts')}`
              let contractAmount = selected_size === 'final_amount_no_taxes' ? `${d.value}` : valueTotalAmount
              labelTotalContracts = d.children.length > 1 ? labelTotalContracts : `${I18n.t('gobierto_visualizations.visualizations.contracts.contract')}`
              return `
                <span class="treemap-nested-tooltip-header-title">
                  ${d.data.name}
                </span>
                <div class="depth-first-container">
                  <p class="text-depth-first">${money(contractAmount)}</b></p>
                  <p class="text-depth-first"><b>${d.children.length}</b> ${labelTotalContracts}</b></p>
                </div>
              `
            })
            .style('top', positionTop)
            .style('left', positionWidthTooltip > containerWidth ? positionRight : positionLeft)

        } else if (depth === 2) {
          let totalContracts = d.children === undefined ? '' : d.children
          let contractsString = totalContracts
            /*When we transform our dataset with d3.nest(), it adds to each dataset element a function.
            We need to filter it so that it does not give errors when building the tooltip's text.*/
            .filter(contract => typeof contract.data !== "function")
            .map(contract => createDepthHTML(contract.children?.[0]?.data))

          tooltipFirstDepth
            .style("display", "block")
            .transition()
            .duration(200)
            .style("opacity", 1)

          tooltipFirstDepth
            .html(() => {
              return `
                <span class="treemap-nested-tooltip-header-title">
                  ${I18n.t('gobierto_visualizations.visualizations.contracts.contracts')}
                </span>
                ${contractsString.join('')}
              `
            })
            .style('top', positionTop)
            .style('left', positionWidthTooltip > containerWidth ? positionRight : positionLeft)

        } else if (depth === 3 && typeof d.data !== "function") {
         let totalContracts = d.children === undefined ? '' : d.children
         let contractsString = totalContracts
           .reduce((acc, contract) => {
             if (typeof contract.data !== "function") {
               acc.push(createDepthHTML(contract.data))
             }
             return acc
           }, [])

         tooltipFirstDepth
           .style("display", "block")
           .transition()
           .duration(200)
           .style("opacity", 1)

         tooltipFirstDepth
           .html(() => {
             return `
               <span class="treemap-nested-tooltip-header-title">
                 ${I18n.t('gobierto_visualizations.visualizations.contracts.contracts')}
               </span>
               ${contractsString.join('')}
             `
           })
           .style('top', positionTop)
           .style('left', positionWidthTooltip > containerWidth ? positionRight : positionLeft)

        } else if (depth === 4 && typeof d.data !== "function") {
          const { data: { initial_amount_no_taxes, status } } = d
          let valueTotalAmount
          if (typeof d.data !== "function") {
            let contractId = d.data.id !== undefined ? d.data.id : ''
            const finalAmountTotal = sumDataByGroupKey(dataTreeMapSumFinalAmount, 'id', 'final_amount_no_taxes')
            let totalAmount = finalAmountTotal.filter(contract => contract.id === contractId)
            valueTotalAmount = totalAmount[0].final_amount_no_taxes
          }

          valueTotalAmount = selected_size === 'final_amount_no_taxes' ? d.value : valueTotalAmount

          tooltipSecondDepth
            .style('display', 'block')
            .transition()
            .duration(200)
            .style("opacity", 1)

          tooltipSecondDepth
            .html(() => {
              return `
                <p class="text-depth-third">${I18n.t('gobierto_visualizations.visualizations.contracts.contract_amount')}: <b>${money(valueTotalAmount)}</b></p>
                <p class="text-depth-third">${I18n.t('gobierto_visualizations.visualizations.contracts.tender_amount')}: <b>${money(initial_amount_no_taxes)}</b></p>
                <p class="text-depth-third">${I18n.t('gobierto_visualizations.visualizations.contracts.status')}: <b>${status}</b></p>
              `
            })
            .style('top', positionTop)
            .style('left', positionWidthTooltip > containerWidth ? positionRight : positionLeft)
        }
      } else if (this.deepLevel === 3) {
        if (depth === 1 && childrenElement.includes('hide')) {
          let valueTotalAmount
          if (typeof d.data !== "function") {
            let contractType = d.data.name !== undefined ? d.data.name : ''
            const finalAmountTotal = sumDataByGroupKey(dataTreeMapSumFinalAmount, 'category_title', 'final_amount_no_taxes')
            let totalAmount = finalAmountTotal.filter(contract => contract['category_title'] === contractType)
            totalAmount = totalAmount.filter(contract => typeof contract.data !== "function")
            valueTotalAmount = totalAmount[0]['final_amount_no_taxes']
          }
          tooltipFirstDepth
            .style("display", "block")
            .transition()
            .duration(200)
            .style("opacity", 1)

          tooltipFirstDepth
            .html(() => {
              let labelTotalContracts = `${I18n.t('gobierto_visualizations.visualizations.contracts.contracts')}`
              let contractAmount = selected_size === 'final_amount_no_taxes' ? `${d.value}` : valueTotalAmount
              labelTotalContracts = d.children.length > 1 ? labelTotalContracts : `${I18n.t('gobierto_visualizations.visualizations.contracts.contract')}`
              return `
                <span class="treemap-nested-tooltip-header-title">
                  ${d.data.name}
                </span>
                <div class="depth-first-container">
                  <p class="text-depth-first">${money(contractAmount)}</b></p>
                  <p class="text-depth-first"><b>${d.children.length}</b> ${labelTotalContracts}</b></p>
                </div>
              `
            })
            .style('top', positionTop)
            .style('left', positionWidthTooltip > containerWidth ? positionRight : positionLeft)

        } else if (depth === 2) {
          let totalContracts = d.children === undefined ? '' : d.children
          let contractsString = ''
          if (totalContracts) {
            totalContracts = totalContracts.filter(contract => typeof contract.data !== "function")
            while (i < totalContracts.length) {
              let contractAmount = selected_size === 'final_amount_no_taxes' ? `${totalContracts[i].data.value}` : `${totalContracts[i].data.final_amount_no_taxes}`
              contractsString = `${contractsString}
              <div class="depth-second-container">
                <p class="depth-second-title">${totalContracts[i].data.title}</p>
                <p class="text-depth-third">${I18n.t('gobierto_visualizations.visualizations.contracts.contract_amount')}: <b>${money(contractAmount)}</b></p>
                <p class="text-depth-third">${I18n.t('gobierto_visualizations.visualizations.contracts.tender_amount')}: <b>${money(totalContracts[i].data.initial_amount_no_taxes)}</b></p>
              </div>`
              i++
            }
          }

          tooltipFirstDepth
            .style("display", "block")
            .transition()
            .duration(200)
            .style("opacity", 1)

          tooltipFirstDepth
            .html(() => {
              return `
                <span class="treemap-nested-tooltip-header-title">
                  ${I18n.t('gobierto_visualizations.visualizations.contracts.contracts')}
                </span>
                ${contractsString}
              `
            })
            .style('top', positionTop)
            .style('left', positionWidthTooltip > containerWidth ? positionRight : positionLeft)

        } else if (depth === 3 && typeof d.data !== "function") {
          const { data: { initial_amount_no_taxes, status } } = d
          let valueTotalAmount
          if (typeof d.data !== "function") {
            let contractId = d.data.id !== undefined ? d.data.id : ''
            const finalAmountTotal = sumDataByGroupKey(dataTreeMapSumFinalAmount, 'id', 'final_amount_no_taxes')
            let totalAmount = finalAmountTotal.filter(contract => contract.id === contractId)
            valueTotalAmount = totalAmount[0].final_amount_no_taxes
          }

          valueTotalAmount = selected_size === 'final_amount_no_taxes' ? d.value : valueTotalAmount

          tooltipSecondDepth
            .style('display', 'block')
            .transition()
            .duration(200)
            .style("opacity", 1)

          tooltipSecondDepth
            .html(() => {
              return `
                <p class="text-depth-third">${I18n.t('gobierto_visualizations.visualizations.contracts.contract_amount')}: <b>${money(valueTotalAmount)}</b></p>
                <p class="text-depth-third">${I18n.t('gobierto_visualizations.visualizations.contracts.tender_amount')}: <b>${money(initial_amount_no_taxes)}</b></p>
                <p class="text-depth-third">${I18n.t('gobierto_visualizations.visualizations.contracts.status')}: <b>${status}</b></p>
              `
            })
            .style('top', positionTop)
            .style('left', positionWidthTooltip > containerWidth ? positionRight : positionLeft)
        }
      }

      function createDepthHTML(data) {
        const { value, final_amount_no_taxes, title, initial_amount_no_taxes } = data
        const contractAmount = selected_size === 'final_amount_no_taxes' ? value : final_amount_no_taxes
        return `
        <div class="depth-second-container">
          <p class="depth-second-title">${title}</p>
          <p class="text-depth-third">${I18n.t('gobierto_visualizations.visualizations.contracts.contract_amount')}: <b>${money(contractAmount)}</b></p>
          <p class="text-depth-third">${I18n.t('gobierto_visualizations.visualizations.contracts.tender_amount')}: <b>${money(initial_amount_no_taxes)}</b></p>
        </div>`
      }

    },
    goesToTreemapItem(data) {
      const { assignee_routing_id } = data
      // eslint-disable-next-line no-unused-vars
      this.$router.push(`/visualizaciones/contratos/adjudicatario/${assignee_routing_id}`).catch(err => {})
    }
  }
}
</script>
