<template>
  <div>
    <TreeMapButtons
      v-show="visualizationsDataExcludeNoCategory.length"
      id="gobierto-visualizations-treemap-categories"
      :buttons="treemapButtons"
      :active="categoryActiveButton"
      @active-button="handleCategoryActiveButton"
    >
      <div
        ref="treemap-category"
        style="height: 400px"
      />
    </TreeMapButtons>

    <TreeMapButtons
      v-show="visualizationsDataEntity.length"
      id="gobierto-visualizations-treemap-entity"
      :buttons="treemapButtons"
      :active="entityActiveButton"
      @active-button="handleEntityActiveButton"
    >
      <div
        ref="treemap-entity"
        style="height: 400px"
      />
    </TreeMapButtons>

    <div id="gobierto-visualizations-beeswarm">
      <h3 class="mt4 graph-title">
        {{ labelBeesWarm }}
      </h3>
      <div
        v-show="visualizationsDataExcludeMinorContract.length"
        ref="beeswarm"
      />
    </div>

    <MetricBoxes id="tendersContractsSummary">
      <MetricBox
        :labels="labelsTenders"
        type="tenders"
      />
      <MetricBox
        :labels="labelsContracts"
        type="contracts"
      />
    </MetricBoxes>

    <Tips :labels="tips" />

    <div class="gobierto-visualizations-grid-dc-charts">
      <div>
        <h3 class="mt1 graph-title">
          {{ labelContractType }}
        </h3>
        <div id="contract-type-bars" />
      </div>
      <div>
        <h3 class="mt1 graph-title">
          {{ labelAmountDistribution }}
        </h3>
        <div id="amount-distribution-bars" />
      </div>
      <div>
        <h3 class="mt1 graph-title">
          {{ labelAmountProcessType }}
        </h3>
        <div id="process-type-per-amount-bars" />
      </div>
      <div>
        <h3 class="mt1 graph-title">
          {{ labelProcessType }}
        </h3>
        <div id="process-type-bars" />
      </div>
    </div>

    <div class="m_t_4">
      <h3 class="mt1 graph-title">
        {{ labelMainAssignees }}
      </h3>
      <Table
        :data="tableItems"
        :sort-column="'count'"
        :sort-direction="'desc'"
        :columns="assigneesColumns"
        :show-columns="showColumns"
        class="gobierto-table-margin-top"
        @on-href-click="goesToTableItem"
      />
    </div>
  </div>
</template>
<script>
import { Table } from '../../../../lib/vue/components';
import { BeeSwarm, TreeMap } from 'gobierto-vizzs';
import TreeMapButtons from '../../components/TreeMapButtons.vue';
import MetricBoxes from '../../components/MetricBoxes.vue';
import MetricBox from '../../components/MetricBox.vue';
import Tips from '../../components/Tips.vue';
import { SharedMixin } from '../../lib/mixins/shared';
import { assigneesColumns } from '../../lib/config/contracts.js';
import { money } from '../../../../lib/vue/filters';

export default {
  name: "Summary",
  components: {
    Table,
    TreeMapButtons,
    MetricBoxes,
    MetricBox,
    Tips
  },
  mixins: [SharedMixin],
  props: {
    activeTab: {
      type: Number,
      default: 0
    }
  },
  data(){
    return {
      visualizationsData: this.$root.$data.contractsData,
      assigneesColumns: assigneesColumns,
      items: [],
      tableItems: [],
      columns: [],
      showColumns: [],
      value: "",
      isGobiertoVizzsLoaded: false,
      labelMainAssignees: I18n.t("gobierto_visualizations.visualizations.contracts.main_assignees") || "",
      labelBeesWarm: I18n.t("gobierto_visualizations.visualizations.visualizations.title_beeswarm") || "",
      labelTooltipBeesWarm: I18n.t("gobierto_visualizations.visualizations.visualizations.tooltip_beeswarm") || "",
      labelCategories: I18n.t('gobierto_visualizations.visualizations.contracts.categories') || "",
      labelEntities: I18n.t('gobierto_visualizations.visualizations.contracts.entities') || "",
      labelContracts: I18n.t('gobierto_visualizations.visualizations.contracts.contracts') || "",
      labelContractsAmount: I18n.t("gobierto_visualizations.visualizations.contracts.contract_amount") || "",
      labelTendersAmount: I18n.t("gobierto_visualizations.visualizations.contracts.tender_amount") || "",
      labelStatus: I18n.t('gobierto_visualizations.visualizations.contracts.status') || "",
      labelContractType: I18n.t("gobierto_visualizations.visualizations.contracts.contract_type") || "",
      labelProcessType: I18n.t("gobierto_visualizations.visualizations.contracts.process_type") || "",
      labelAmountDistribution: I18n.t("gobierto_visualizations.visualizations.contracts.amount_distribution") || "",
      labelAmountProcessType: I18n.t("gobierto_visualizations.visualizations.contracts.amount_by_type_of_process") || "",
      treemapButtons: [
        ["final_amount_no_taxes", I18n.t("gobierto_visualizations.visualizations.contracts.contract_amount")],
        ["total", I18n.t('gobierto_visualizations.visualizations.visualizations.tooltip_treemap') || ""],
      ],
      categoryActiveButton: "final_amount_no_taxes",
      entityActiveButton: "final_amount_no_taxes",
      labelsTenders: [
        I18n.t("gobierto_visualizations.visualizations.contracts.summary.tenders") || "",
        I18n.t("gobierto_visualizations.visualizations.contracts.summary.tenders_for") || "",
        I18n.t("gobierto_visualizations.visualizations.contracts.summary.mean_amount") || "",
        I18n.t("gobierto_visualizations.visualizations.contracts.summary.median_amount") || ""
      ],
      labelsContracts: [
        I18n.t("gobierto_visualizations.visualizations.contracts.summary.contracts") || "",
        I18n.t("gobierto_visualizations.visualizations.contracts.summary.contracts_for") || "",
        I18n.t("gobierto_visualizations.visualizations.contracts.summary.mean_amount") || "",
        I18n.t("gobierto_visualizations.visualizations.contracts.summary.median_amount") || ""
      ],
      tips: [
        I18n.t("gobierto_visualizations.visualizations.contracts.summary.tip_1", { strong1: "<strong><span id=\"less-than-1000-pct\" /></strong>", strong2: "<strong>1.000 €</strong>" }) || "",
        I18n.t("gobierto_visualizations.visualizations.contracts.summary.tip_2", { strong: "<strong><span id=\"larger-contract-amount-pct\" /></strong>" }) || "",
        I18n.t("gobierto_visualizations.visualizations.contracts.summary.tip_3", { strong: "<strong><span id=\"half-spendings-contracts-pct\" /></strong>" }) || ""
      ]
    }
  },
  computed: {
    visualizationsDataEntity() {
      return this.visualizationsData
        .map(d => ({ ...d, href: `${location.origin}${location.pathname}${d.assignee_routing_id}` } ))
    },
    visualizationsDataExcludeNoCategory() {
      return this.visualizationsDataEntity
        .filter(({ category_id }) => !!category_id)
    },
    visualizationsDataExcludeMinorContract() {
      return this.visualizationsDataEntity
        .filter(({ minor_contract: minor, gobierto_start_date }) => minor === "f" && new Date(gobierto_start_date).toString() !== 'Invalid Date')
    }
  },
  watch: {
    visualizationsDataExcludeNoCategory(n) {
      n.length && this.treemapCategory?.setData(n)
    },
    visualizationsDataEntity(n) {
      n.length && this.treemapEntity?.setData(n)
    },
    visualizationsDataExcludeMinorContract(n) {
      n.length && this.beeswarm?.setData(n)
    },
    $route(to, from) {
      if (to.path !== from.path && !this.isGobiertoVizzsLoaded) {
        this.initGobiertoVizzs()
      }
    }
  },
  created() {
    this.columns = assigneesColumns;
    this.showColumns = ["count", "name", "sum"]
    this.tableItems = this.items.map(d => ({ ...d, href: `${location.origin}${location.pathname}${d.assignee_routing_id}` } ))
  },
  mounted() {
    this.initGobiertoVizzs()
  },
  methods: {
    initGobiertoVizzs() {
      const treemapCategory = this.$refs["treemap-category"]
      const treemapEntity = this.$refs["treemap-entity"]
      const beeswarm = this.$refs.beeswarm

      // Check if element is visible in DOM - https://stackoverflow.com/a/21696585/5020256
      if (treemapCategory && treemapCategory.offsetParent !== null) {
        this.treemapCategory = new TreeMap(treemapCategory, this.visualizationsDataExcludeNoCategory, {
          rootTitle: this.labelCategories,
          id: "title",
          group: ["category_title", "assignee"],
          value: "final_amount_no_taxes",
          itemTemplate: this.treemapItemTemplate,
          tooltip: this.tooltipTreeMap,
          onLeafClick: this.handleTreeMapLeafClick,
        })
      }

      if (treemapEntity && treemapEntity.offsetParent !== null) {
        let getContractors = [...new Set(this.visualizationsDataEntity.map(item => item.contractor))]
        this.treemapEntity = new TreeMap(treemapEntity, this.visualizationsDataEntity, {
          rootTitle: getContractors.length > 1 ? this.labelEntities : '',
          id: "title",
          group: ["contractor", "contract_type", "assignee"],
          value: "final_amount_no_taxes",
          itemTemplate: this.treemapItemTemplate,
          tooltip: this.tooltipTreeMap,
          onLeafClick: this.handleTreeMapLeafClick,
        })
      }

      if (beeswarm && beeswarm.offsetParent !== null) {
        this.beeswarm = new BeeSwarm(beeswarm, this.visualizationsDataExcludeMinorContract, {
          x: "gobierto_start_date",
          y: "contract_type",
          value: "final_amount_no_taxes",
          relation: "assignee_routing_id",
          circleSize: [3, 28],
          tooltip: this.tooltipBeeSwarm,
          onClick: this.handleBeeSwarmClick,
          margin: {
            left: 120,
            right: 30,
            top: 70,
            bottom: 30
          }
        })

        this.isGobiertoVizzsLoaded = true
      }
    },
    tooltipBeeSwarm(d) {
      return `
        <span class="beeswarm-tooltip-header">
          ${d.assignee}
        </span>
        <div class="beeswarm-tooltip-table-element">
          <span class="beeswarm-tooltip-table-element-text">
            ${this.labelTooltipBeesWarm}:
          </span>
          <span class="beeswarm-tooltip-table-element-text">
              <b>${money(d.final_amount_no_taxes)}</b>
          </span>
        </div>
      `
    },
    tooltipTreeMap(d) {
      const isLeaf = d.height === 0
      return isLeaf ? [
        `<p class="treemap-tooltip-children-text">${this.labelContractsAmount}: <b>${money(d.data.final_amount_no_taxes)}</b></p>`,
        `<p class="treemap-tooltip-children-text">${this.labelTendersAmount}: <b>${money(d.data.initial_amount_no_taxes)}</b></p>`,
        `<p class="treemap-tooltip-children-text">${this.labelStatus}: <b>${d.data.status}</b></p>`,
      ].join("") : [
        `<span class="treemap-tooltip-header">${this.labelContracts}</span>`,
        d.children && d.children.map(this.tooltipTreeMapChildren).join("")
      ].join("")
    },
    tooltipTreeMapChildren(d) {
      const contracts = d.leaves().reduce((acc, x) => acc + x.data.final_amount_no_taxes, 0)
      const tenders = d.leaves().reduce((acc, x) => acc + x.data.initial_amount_no_taxes, 0)

      return `
      <div class="treemap-tooltip-children-container">
        <p class="treemap-tooltip-children-title">${d.data.title}</p>
        <p class="treemap-tooltip-children-text">${this.labelContractsAmount}: <b>${money(contracts)}</b></p>
        <p class="treemap-tooltip-children-text">${this.labelTendersAmount}: <b>${money(tenders)}</b></p>
      </div>`
    },
    treemapItemTemplate(d) {
      const isLeaf = d.height === 0
      const title = isLeaf ? d.data.assignee : d.data.title
      const text = isLeaf ? d.data.title : money(d.leaves().reduce((acc, x) => acc + x.data.final_amount_no_taxes, 0))
      const leafClass = isLeaf ? "is-leaf" : ""
      return [
        `<p class="treemap-item-title ${leafClass}">${title}</p>`,
        `<p class="treemap-item-text ${leafClass}">${text}</p>`,
        d.children && `<p class="treemap-item-text"><b>${d.leaves().length}</b> ${this.labelContracts}</b></p>`
      ].join("")
    },
    handleBeeSwarmClick(_, { id }) {
      this.$router.push(`/visualizaciones/contratos/adjudicaciones/${id}`).catch(() => {})
    },
    handleTreeMapLeafClick(_, { data }) {
      const { assignee_routing_id } = data
      this.$router.push(`/visualizaciones/contratos/adjudicatario/${assignee_routing_id}`).catch(() => {})
    },
    handleCategoryActiveButton(value) {
      this.categoryActiveButton = value
      this.treemapCategory.setValue(this.categoryActiveButton === "total" ? undefined : value)
    },
    handleEntityActiveButton(value) {
      this.entityActiveButton = value
      this.treemapEntity.setValue(this.entityActiveButton === "total" ? undefined : value)
    },
    refreshSummaryData() {
      if (!this.value) {
        this.visualizationsData = this.$root.$data.contractsData;
      } else {
        this.visualizationsData = this.$root.$data.contractsData.filter(contract => contract.assignee.toLowerCase().includes(this.value.toLowerCase()))
      }
      this.items = this.buildItems();
      this.tableItems = this.items.map(d => ({ ...d, href: `${location.origin}${location.pathname}${d.assignee_routing_id}` } ))
    },
    buildItems() {
      const groupedByAssignee = {}
      // Group contracts by assignee
      this.visualizationsData.forEach(({ assignee, assignee_routing_id, final_amount_no_taxes }) => {
        if (assignee === "" || assignee === undefined) {
          return;
        }

        if (groupedByAssignee[assignee] === undefined) {
          groupedByAssignee[assignee] = {
            name: assignee,
            assignee_routing_id: assignee_routing_id,
            sum: 0,
            count: 0
          }
        }

        groupedByAssignee[assignee].sum += parseFloat(final_amount_no_taxes)
        groupedByAssignee[assignee].count++;
      });

      // Sort grouped elements by number of contracts
      const sortedAndGrouped = Object.values(groupedByAssignee).sort((a, b) => { return a.count < b.count ? 1 : -1 });

      // The id must be unique so when data changes vue knows how to refresh the table accordingly.
      sortedAndGrouped.forEach(contract => contract.id = `${contract.name}-${contract.count}`)

      return sortedAndGrouped.slice(0, 30);
    },
    goesToTableItem(item) {
      const { assignee_routing_id: routingId } = item
      this.$router.push({ name: "assignees_show", params: { id: routingId } })
    }
  }
}
</script>
