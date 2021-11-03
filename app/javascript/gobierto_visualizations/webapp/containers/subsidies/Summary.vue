<template>
  <div>
    <!-- <CategoriesTreeMapNested
      :data="visualizationsData"
    /> -->
    <!-- <TreeMapButtons
      id="gobierto-visualizations-treemap-categories"
      :buttons="treemapButtons"
      :active="categoryActiveButton"
      @active-button="handleCategoryActiveButton"
    >
      <div
        ref="treemap-category"
        style="height: 400px"
      />
    </TreeMapButtons> -->

    <MetricBoxes id="subsidiesSummary">
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

    <div
      id="dccharts"
      class="pure-g block m_b_3"
    >
      <div class="pure-u-1 pure-u-lg-1-3 p_h_r_3 header_block_inline">
        <p class="decorator">
          {{ labelLessThan1000_1 }}<strong><span id="less-than-1000-pct" /></strong>{{ labelLessThan1000_2 }}<strong>1.000 €</strong>
        </p>
      </div>

      <div class="pure-u-1 pure-u-lg-1-3 p_h_r_3 header_block_inline">
        <p class="decorator">
          {{ labelLargerSubsidyAmount_1 }}<strong><span id="larger-subsidy-amount-pct" /></strong>{{ labelLargerSubsidyAmount_2 }}
        </p>
      </div>

      <div class="pure-u-1 pure-u-lg-1-3 p_h_r_3 header_block_inline">
        <p class="decorator">
          {{ labelHalfSpendingsSubsidies_1 }}<strong><span id="half-spendings-subsidies-pct" /></strong>{{ labelHalfSpendingsSubsidies_2 }}
        </p>
      </div>
    </div>

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
// import CategoriesTreeMapNested from "./CategoriesTreeMapNested.vue";
import { SharedMixin } from "../../lib/mixins/shared";
import { grantedColumns, subsidiesFiltersConfig } from "../../lib/config/subsidies.js";
import MetricBoxes from "../../components/MetricBoxes.vue";
import MetricBox from "../../components/MetricBox.vue";

export default {
  name: 'Summary',
  components: {
    Table,
    MetricBoxes,
    MetricBox,
    // CategoriesTreeMapNested
  },
  mixins: [SharedMixin],
  data(){
    return {
      visualizationsData: this.$root.$data.subsidiesData,
      items: [],
      grantedColumns: grantedColumns,
      showColumns: [],
      value: '',
      labelLessThan1000_1: I18n.t('gobierto_visualizations.visualizations.subsidies.summary.label_less_than_1000_1'),
      labelLessThan1000_2: I18n.t('gobierto_visualizations.visualizations.subsidies.summary.label_less_than_1000_2'),
      labelLargerSubsidyAmount_1: I18n.t('gobierto_visualizations.visualizations.subsidies.summary.label_larger_subsidy_amount_1'),
      labelLargerSubsidyAmount_2: I18n.t('gobierto_visualizations.visualizations.subsidies.summary.label_larger_subsidy_amount_2'),
      labelHalfSpendingsSubsidies_1: I18n.t('gobierto_visualizations.visualizations.subsidies.summary.label_half_spendings_subsidies_1'),
      labelHalfSpendingsSubsidies_2: I18n.t('gobierto_visualizations.visualizations.subsidies.summary.label_half_spendings_subsidies_2'),
      labelCategory: I18n.t('gobierto_visualizations.visualizations.subsidies.category'),
      labelAmountDistribution: I18n.t('gobierto_visualizations.visualizations.subsidies.amount_distribution'),
      labelMainBeneficiaries: I18n.t('gobierto_visualizations.visualizations.subsidies.main_beneficiaries'),
      filters: subsidiesFiltersConfig,
      labelsSubsidies: [
        I18n.t('gobierto_visualizations.visualizations.subsidies.summary.subsidies') || "",
        I18n.t('gobierto_visualizations.visualizations.subsidies.summary.subsidies_for') || "",
        I18n.t('gobierto_visualizations.visualizations.subsidies.summary.mean_amount') || "",
        I18n.t('gobierto_visualizations.visualizations.subsidies.summary.median_amount') || "",
      ],
      labelsCollectivesSubsidies: [
        "",
        I18n.t('gobierto_visualizations.visualizations.subsidies.summary.collective_subsidies_for') || "",
        I18n.t('gobierto_visualizations.visualizations.subsidies.summary.mean_amount') || "",
        I18n.t('gobierto_visualizations.visualizations.subsidies.summary.median_amount') || "",
      ],
      labelsIndividualsSubsidies: [
        "",
        I18n.t('gobierto_visualizations.visualizations.subsidies.summary.individual_subsidies_for') || "",
        I18n.t('gobierto_visualizations.visualizations.subsidies.summary.mean_amount') || "",
        I18n.t('gobierto_visualizations.visualizations.subsidies.summary.median_amount') || "",
      ],
    }
  },
  computed: {
    checkFilterCategoryLength() {
      const filterCategories = this.filters.filter(({ id }) => id === 'categories')
      return filterCategories[0].options.length > 0 ? true : false
    }
  },
  created() {
    this.columns = grantedColumns;
    this.showColumns = ['name', 'count', 'sum']
    this.visualizationsData = this.visualizationsData
      .map(d => ({ ...d, href: `${location.origin}${location.pathname}${d.assignee_routing_id}` } ))
  },
  methods: {
    refreshSummaryData(){
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
