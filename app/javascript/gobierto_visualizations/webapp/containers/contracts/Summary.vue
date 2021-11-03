<template>
  <div>
    <TreeMapButtons
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
      <div ref="beeswarm" />
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

    <DCCharts />

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
import { Table } from "lib/vue/components";
import { BeeSwarm, TreeMap } from "gobierto-vizzs";
import TreeMapButtons from "../../components/TreeMapButtons.vue";
import MetricBoxes from "../../components/MetricBoxes.vue";
import MetricBox from "../../components/MetricBox.vue";
import DCCharts from "../../components/DCCharts.vue";
import { SharedMixin } from "../../lib/mixins/shared";
import { assigneesColumns } from "../../lib/config/contracts.js";
import { money } from "lib/vue/filters";

export default {
  name: "Summary",
  components: {
    Table,
    TreeMapButtons,
    MetricBoxes,
    MetricBox,
    DCCharts
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
      labelMainAssignees: I18n.t("gobierto_visualizations.visualizations.contracts.main_assignees") || "",
      labelBeesWarm: I18n.t("gobierto_visualizations.visualizations.visualizations.title_beeswarm") || "",
      labelTooltipBeesWarm: I18n.t("gobierto_visualizations.visualizations.visualizations.tooltip_beeswarm") || "",
      labelCategories: I18n.t('gobierto_visualizations.visualizations.contracts.categories') || "",
      labelEntities: I18n.t('gobierto_visualizations.visualizations.contracts.entities') || "",
      labelContracts: I18n.t('gobierto_visualizations.visualizations.contracts.contracts') || "",
      labelContractsAmount: I18n.t("gobierto_visualizations.visualizations.contracts.contract_amount") || "",
      labelTendersAmount: I18n.t("gobierto_visualizations.visualizations.contracts.tender_amount") || "",
      labelStatus: I18n.t('gobierto_visualizations.visualizations.contracts.status') || "",
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
        .filter(({ minor_contract: minor }) => minor === "f")
    },
  },
  watch: {
    visualizationsDataExcludeNoCategory(n) {
      this.treemapCategory?.setData(n)
    },
    visualizationsDataEntity(n) {
      this.treemapEntity?.setData(n)
    },
    visualizationsDataExcludeMinorContract(n) {
      this.beeswarm?.setData(n)
    }
  },
  created() {
    this.columns = assigneesColumns;
    this.showColumns = ["count", "name", "sum"]
    this.tableItems = this.items.map(d => ({ ...d, href: `${location.origin}${location.pathname}${d.assignee_routing_id}` } ))
  },
  mounted() {
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
      this.treemapEntity = new TreeMap(treemapEntity, this.visualizationsDataEntity, {
        rootTitle: this.labelEntities,
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
    }
  },
  methods: {
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
      const leafClass = isLeaf && "is-leaf"
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
