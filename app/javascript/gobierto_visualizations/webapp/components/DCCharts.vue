<template>
  <div>
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
          {{ labelLargerContractAmount_1 }}<strong><span id="larger-contract-amount-pct" /></strong>{{ labelLargerContractAmount_2 }}
        </p>
      </div>

      <div class="pure-u-1 pure-u-lg-1-3 p_h_r_3 header_block_inline">
        <p class="decorator">
          {{ labelHalfSpendingsContracts_1 }}<strong><span id="half-spendings-contracts-pct" /></strong>{{ labelHalfSpendingsContracts_2 }}
        </p>
      </div>
    </div>

    <div class="pure-g block">
      <div class="pure-u-1 pure-u-lg-1-2 p_h_r_3">
        <div class="m_b_3">
          <h3 class="mt1 graph-title">
            {{ labelContractType }}
          </h3>
          <div id="contract-type-bars" />
        </div>

        <div>
          <h3 class="mt1 graph-title">
            {{ labelProcessType }}
          </h3>
          <div id="process-type-bars" />
        </div>
      </div>

      <div class="pure-u-1 pure-u-lg-1-2 header_block_inline">
        <div>
          <h3 class="mt1 graph-title">
            {{ labelAmountDistribution }}
          </h3>
          <div id="amount-distribution-bars" />
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: "DCCharts",
  data() {
    return {
      labelLessThan1000_1: I18n.t("gobierto_visualizations.visualizations.contracts.summary.label_less_than_1000_1") || "",
      labelLessThan1000_2: I18n.t("gobierto_visualizations.visualizations.contracts.summary.label_less_than_1000_2") || "",
      labelLargerContractAmount_1: I18n.t("gobierto_visualizations.visualizations.contracts.summary.label_larger_contract_amount_1") || "",
      labelLargerContractAmount_2: I18n.t("gobierto_visualizations.visualizations.contracts.summary.label_larger_contract_amount_2") || "",
      labelHalfSpendingsContracts_1: I18n.t("gobierto_visualizations.visualizations.contracts.summary.label_half_spendings_contracts_1") || "",
      labelHalfSpendingsContracts_2: I18n.t("gobierto_visualizations.visualizations.contracts.summary.label_half_spendings_contracts_2") || "",
      labelContractType: I18n.t("gobierto_visualizations.visualizations.contracts.contract_type") || "",
      labelProcessType: I18n.t("gobierto_visualizations.visualizations.contracts.process_type") || "",
      labelAmountDistribution: I18n.t("gobierto_visualizations.visualizations.contracts.amount_distribution") || "",
    }
  }
}
</script>
