<template>
  <div>
    <!-- <CategoriesTreeMapNested
      :data="visualizationsData"
    /> -->
    <TreeMapButtons
      id="gobierto-visualizations-treemap-categories"
      :buttons="treemapButtons"
      :active="activeButton"
      @active-button="handleActiveButton"
    >
      <div
        ref="treemap"
        style="height: 400px"
      />
    </TreeMapButtons>

    <MetricBoxes
      id="subsidiesSummary"
      :style="{ marginTop: '4em' }"
    >
      <MetricBox
        :labels="labelsSubsidies"
        type="subsidies"
      />
      <MetricBox
        :labels="labelsCollectivesSubsidies"
        type="collectives-subsidies"
      />
      <MetricBox
        :labels="labelsIndividualsSubsidies"
        type="individuals-subsidies"
      />
    </MetricBoxes>

    <Tips :labels="tips" />

    <div class="pure-g block">
      <div
        v-if="checkFilterCategoryLength"
        class="pure-u-1 pure-u-lg-1-2 p_h_r_3"
      >
        <div class="m_b_3">
          <h3 class="mt1 graph-title">
            {{ labelCategory }}
          </h3>
          <div id="category-bars" />
        </div>
      </div>

      <div class="pure-u-1 pure-u-lg-1-2 header_block_inline">
        <div>
          <h3 class="mt1 graph-title">
            {{ labelAmountDistribution }}
          </h3>
          <div id="amount-distribution-bars" />
        </div>
        <div>
          <div
            id="date-bars"
            class="hidden"
          />
        </div>
      </div>
    </div>

    <div class="m_t_4">
      <h3 class="mt1 graph-title">
        {{ labelMainBeneficiaries }}
      </h3>
      <Table
        :data="items"
        :sort-column="'name'"
        :columns="grantedColumns"
        :show-columns="showColumns"
        class="gobierto-table-margin-top"
      />
    </div>
  </div>
</template>

<script>
import { Table } from "lib/vue/components";
import { SharedMixin } from "../../lib/mixins/shared";
import { grantedColumns, subsidiesFiltersConfig } from "../../lib/config/subsidies.js";
import MetricBoxes from "../../components/MetricBoxes.vue";
import MetricBox from "../../components/MetricBox.vue";
import Tips from "../../components/Tips.vue";
import TreeMapButtons from "../../components/TreeMapButtons.vue";
import { TreeMap } from "gobierto-vizzs";
import { money } from "lib/vue/filters";

export default {
  name: 'Summary',
  components: {
    Table,
    MetricBoxes,
    MetricBox,
    Tips,
    TreeMapButtons
  },
  mixins: [SharedMixin],
  data() {
    return {
      visualizationsData: this.$root.$data.subsidiesData,
      items: [],
      grantedColumns: grantedColumns,
      showColumns: [],
      value: "",
      labelSubsidies: I18n.t("gobierto_visualizations.visualizations.subsidies.subsidies") || "",
      labelCategory: I18n.t("gobierto_visualizations.visualizations.subsidies.category") || "",
      labelAmountDistribution: I18n.t("gobierto_visualizations.visualizations.subsidies.amount_distribution") || "",
      labelMainBeneficiaries: I18n.t("gobierto_visualizations.visualizations.subsidies.main_beneficiaries") || "",
      labelSubsidiesAmount: I18n.t("gobierto_visualizations.visualizations.subsidies.subsidies_amount") || "",
      filters: subsidiesFiltersConfig,
      treemapButtons: [
        ["amount", I18n.t("gobierto_visualizations.visualizations.subsidies.subsidies_amount") || ""],
        ["total", I18n.t("gobierto_visualizations.visualizations.subsidies.subsidies_total") || ""],
      ],
      activeButton: "amount",
      labelsSubsidies: [
        I18n.t("gobierto_visualizations.visualizations.subsidies.summary.subsidies") || "",
        I18n.t("gobierto_visualizations.visualizations.subsidies.summary.subsidies_for") || "",
        I18n.t("gobierto_visualizations.visualizations.subsidies.summary.mean_amount") || "",
        I18n.t("gobierto_visualizations.visualizations.subsidies.summary.median_amount") || "",
      ],
      labelsCollectivesSubsidies: [
        "",
        I18n.t("gobierto_visualizations.visualizations.subsidies.summary.collective_subsidies_for") || "",
        I18n.t("gobierto_visualizations.visualizations.subsidies.summary.mean_amount") || "",
        I18n.t("gobierto_visualizations.visualizations.subsidies.summary.median_amount") || "",
      ],
      labelsIndividualsSubsidies: [
        "",
        I18n.t("gobierto_visualizations.visualizations.subsidies.summary.individual_subsidies_for") || "",
        I18n.t("gobierto_visualizations.visualizations.subsidies.summary.mean_amount") || "",
        I18n.t("gobierto_visualizations.visualizations.subsidies.summary.median_amount") || "",
      ],
      tips: [
        ["less-than-1000-pct",I18n.t("gobierto_visualizations.visualizations.subsidies.summary.label_less_than_1000_1") || "", I18n.t("gobierto_visualizations.visualizations.subsidies.summary.label_less_than_1000_2") || ""],
        ["larger-subsidy-amount-pct", I18n.t("gobierto_visualizations.visualizations.subsidies.summary.label_larger_subsidy_amount_1") || "", I18n.t("gobierto_visualizations.visualizations.subsidies.summary.label_larger_subsidy_amount_2") || ""],
        ["half-spendings-subsidies-pct", I18n.t("gobierto_visualizations.visualizations.subsidies.summary.label_half_spendings_subsidies_1") || "", I18n.t("gobierto_visualizations.visualizations.subsidies.summary.label_half_spendings_subsidies_2") || ""],
      ]
    }
  },
  computed: {
    checkFilterCategoryLength() {
      const filterCategories = this.filters.filter(({ id }) => id === 'categories')
      return filterCategories[0].options.length > 0 ? true : false
    },
  },
  watch: {
    visualizationsData(n) {
      this.treemap?.setData(n)
    },
  },
  created() {
    this.columns = grantedColumns;
    this.showColumns = ['name', 'count', 'sum']
  },
  mounted() {
    const treemap = this.$refs.treemap

    // Check if element is visible in DOM - https://stackoverflow.com/a/21696585/5020256
    if (treemap && treemap.offsetParent !== null) {
      this.treemap = new TreeMap(treemap, this.visualizationsData, {
        rootTitle: this.labelSubsidies,
        id: "categories",
        group: ["beneficiary_type"],
        value: "amount",
        itemTemplate: this.treemapItemTemplate,
        tooltip: this.tooltipTreeMap,
        onLeafClick: this.handleTreeMapLeafClick,
      })
    }
  },
  methods: {
    handleActiveButton(value) {
      this.activeButton = value
      this.treemap.setValue(this.activeButton === "total" ? undefined : value)
    },
    treemapItemTemplate(d) {
      const isLeaf = d.height === 0
      const title = isLeaf ? d.data.beneficiary_type : d.data.categories
      const text = isLeaf ? d.data.beneficiary : money(d.leaves().reduce((acc, x) => acc + x.data.amount, 0))
      const leafClass = isLeaf && "is-leaf"
      return [
        `<p class="treemap-item-title ${leafClass}">${title}</p>`,
        `<p class="treemap-item-text ${leafClass}">${text}</p>`,
        d.children && `<p class="treemap-item-text"><b>${d.leaves().length}</b> ${this.labelSubsidies}</b></p>`
      ].join("")
    },
    handleTreeMapLeafClick(_, { data }) {
      const { id } = data
      this.$router.push(`/visualizaciones/subvenciones/subvenciones/${id}`).catch(() => {})
    },
    tooltipTreeMap(d) {
      const isLeaf = d.height === 0
      return isLeaf ? `<p class="treemap-tooltip-children-text">${this.labelSubsidiesAmount}: <b>${money(d.data.amount)}</b></p>`
      : [
        `<span class="treemap-tooltip-header">${this.labelSubsidies}</span>`,
        d.children && d.children.map(this.tooltipTreeMapChildren).join("")
      ].join("")
    },
    tooltipTreeMapChildren(d) {
      return `
      <div class="treemap-tooltip-children-container">
        <p class="treemap-tooltip-children-title">${d.data.beneficiary}</p>
        <p class="treemap-tooltip-children-text">${this.labelSubsidiesAmount}: <b>${money(d.data.amount)}</b></p>
      </div>`
    },
    refreshSummaryData() {
      if (!this.value) {
        this.visualizationsData = this.$root.$data.subsidiesData;
      } else {
        this.subsivisualizationsDatadiesData = this.$root.$data.subsidiesData.filter(contract => contract.beneficiary_name.toLowerCase().includes(this.value.toLowerCase()))
      }
      this.items = this.buildItems();
    },
    buildItems() {
      const groupedByBeneficiary = {}
      // Group subsidies by beneficiary
      this.visualizationsData.forEach(({ beneficiary_name, amount }) => {
        if (beneficiary_name === '' || beneficiary_name === undefined) {
          return;
        }

        if (beneficiary_name === 'física') {
          beneficiary_name = 'PERSONA FÍSICA'
        }

        if (groupedByBeneficiary[beneficiary_name] === undefined) {
          groupedByBeneficiary[beneficiary_name] = {
            name: beneficiary_name,
            sum: 0,
            count: 0
          }
        }

        groupedByBeneficiary[beneficiary_name].sum += parseFloat(amount)
        groupedByBeneficiary[beneficiary_name].count++;
      });


      // Sort grouped elements by number of subsidies
      const sortedAndGrouped = Object.values(groupedByBeneficiary).sort((a, b) => { return a.count < b.count ? 1 : -1 });

      // The id must be unique so when data changes vue knows how to refresh the table accordingly.
      sortedAndGrouped.forEach(subsidy => subsidy.id = `${subsidy.name}-${subsidy.count}`)

      return sortedAndGrouped.slice(0, 30);
    }
  }
}
</script>
