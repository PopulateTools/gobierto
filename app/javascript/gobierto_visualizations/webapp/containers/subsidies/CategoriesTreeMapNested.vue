<template>
  <div>
    <TreeMapNested
      :data="data"
      :root-data="rootData"
      :label-root-key="labelRootKey"
      :first-depth-for-tree-map="firstDepthString"
      :second-depth-for-tree-map="secondDepthString"
      :scale-color-key="'contract_type'"
      :treemap-id="'categories'"
      :amount="'amount'"
      :scale-color="false"
      :first-button-value="'amount'"
      :second-button-value="'number_of_contract'"
      :first-button-label="labelSubsidies"
      :second-button-label="labelSubsidiesTotal"
      :label-total-plural="labelContractsPlural"
      :label-total-unique="labelContractsUnique"
      :key-for-third-depth="'call'"
      @transformData="nestedData"
      @showTooltip="showTooltipTreemap"
      @on-treemap-click="goesToTreemapItem"
    />
  </div>
</template>
<script>
import { nest } from "d3-collection";
import { select, mouse } from 'd3-selection';
import TreeMapNested from "../../components/TreeMapNested.vue";
import { money } from "lib/vue/filters";

const d3 = { nest, select, mouse }

export default {
  name: 'CategoriesTreeMapNested',
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
      labelRootKey: I18n.t('gobierto_visualizations.visualizations.contracts.categories'),
      labelSubsidies: I18n.t('gobierto_visualizations.visualizations.subsidies.subsidies_amount'),
      labelSubsidiesTotal: I18n.t('gobierto_visualizations.visualizations.subsidies.subsidies_total'),
      labelContractTotal: I18n.t('gobierto_visualizations.visualizations.visualizations.tooltip_treemap'),
      labelContractsPlural: I18n.t('gobierto_visualizations.visualizations.subsidies.subsidies'),
      labelContractsUnique: I18n.t('gobierto_visualizations.visualizations.subsidies.subsidie'),
      rootData: {},
      firstDepthString: '',
      secondDepthString: '',
      deepLevel: 3
    }
  },
  methods: {
    nestedData(data, sizeForTreemap) {
      const dataFilter = data.filter(contract => contract.amount !== 0)
      dataFilter.forEach(d => {
        d.number_of_contract = 1
        if (d.beneficiary_type === 'persona') {
          d.beneficiary_type = 'persona física'
        }
      })
      // d3v6
      //
      // const dataGroupTreeMap = Array.from(
      //   d3.group(data, d =>  d.contract_type, d.assignee),
      // );

      const hasCategory = data.some(({ category }) => category !== '')
      let nested_data
      if (!hasCategory) {
        nested_data = d3.nest()
          .key(d => d['beneficiary_type'])
          .entries(dataFilter);
          this.firstDepthString = 'beneficiary_type';
          this.deepLevel = 2
      } else {
        nested_data = d3.nest()
          .key(d => d['category'])
          .key(d => d['beneficiary'])
          .entries(dataFilter);
          this.firstDepthString = 'category';
          this.secondDepthString = 'beneficiary';
      }
      let rootData = {};

      rootData.key = hasCategory ? this.labelRootKey : this.labelContractsPlural
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
      const { depth } = d
      if (depth === 1) return;
      const [x, y] = d3.mouse(event[0]);

      //Elements to determinate the position of tooltip
      const tooltipFirstDepth = d3.select('#treemap-nested-tooltip-first-depth-categories')
      const tooltipSecondDepth = d3.select('#treemap-nested-tooltip-second-depth-categories')
      const container = document.querySelector('.treemap-nested-container-categories');
      const containerWidth = container.offsetWidth
      const tooltipWidth = depth === 2 ? tooltipFirstDepth.node().offsetWidth : tooltipSecondDepth.node().offsetWidth
      const tooltipHeight = depth === 2 ? tooltipFirstDepth.node().offsetHeight : tooltipSecondDepth.node().offsetHeight
      const positionWidthTooltip = x + tooltipWidth
      const positionRight = `${x - tooltipWidth - 20}px`
      const positionTop = tooltipHeight + y > window.innerHeight ? `${y - (tooltipHeight / 2)}px` : `${y}px`
      const positionLeft = `${x + 20}px`

      if (depth === 2 && this.deepLevel > 2) {
        let totalContracts = d.children === undefined ? '' : d.children
        let contractsString = totalContracts
          .reduce((acc, contract) => {
            if (typeof contract.data !== "function") {
              acc.push(this.createDepthHTML(contract.data, selected_size))
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
                ${I18n.t('gobierto_visualizations.visualizations.subsidies.subsidies')}
              </span>
              ${contractsString.join('')}
            `
          })
          .style('top', positionTop)
          .style('left', positionWidthTooltip > containerWidth ? positionRight : positionLeft)

      } else if (depth === 3 && typeof d.data !== "function" || this.deepLevel === 2 && typeof d.data !== "function") {
        const { data: { amount, value } } = d
        let contractAmount = selected_size === 'amount' ? `${value}` : `${amount}`

        tooltipSecondDepth
          .style('display', 'block')
          .transition()
          .duration(200)
          .style("opacity", 1)

        tooltipSecondDepth
          .html(() => {
            return `
              <p class="text-depth-third">${I18n.t('gobierto_visualizations.visualizations.subsidies.subsidies_amount')}: <b>${money(contractAmount)}</b></p>
            `
          })
          .style('top', positionTop)
          .style('left', positionWidthTooltip > containerWidth ? positionRight : positionLeft)
      }
    },
    createDepthHTML(data, selected_size) {
      const { beneficiary, value, amount } = data
      let contractAmount = selected_size === 'amount' ? value : amount
      return `
      <div class="depth-second-container">
        <p class="depth-second-title">${beneficiary}</p>
        <p class="text-depth-third">${I18n.t('gobierto_visualizations.visualizations.contracts.contract_amount')}: <b>${money(contractAmount)}</b></p>
      </div>`
    },
    goesToTreemapItem(data) {
      const { id } = data
      // eslint-disable-next-line no-unused-vars
      this.$router.push(`/visualizaciones/subvenciones/subvenciones/${id}`).catch(err => {})
    }
  }
}
</script>
