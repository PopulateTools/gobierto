<template>
  <div>
    <div class="metric_boxes" id="tendersContractsSummary">
      <div class="metric_box">
        <div class="inner nomargin ">
          <div class="pure-g p_1">

            <div class="pure-u-1 pure-u-lg-1-3">
              <h3>{{ labelTenders }}</h3>

              <div class="metric m_b_1"><span id="number-tenders"></span></div>
              <p class="m_t_0">{{ labelTendersFor }}</p>
              <div class="metric m_b_1"><small><span id="sum-tenders"></span></small></div>

              <div class="pure-g">
                <div class="pure-u-1-2 explanation explanation--relative">
                  {{ labelMeanAmount }}
                  <strong class="d_block"><span id="mean-tenders"></span></strong>
                </div>

                <div class="pure-u-1-2 explanation explanation--relative">
                  {{ labelMedianAmount }}
                  <strong class="d_block"> <span id="median-tenders"></span></strong>
                </div>
              </div>
            </div> <!-- tenders block -->

            <div class="pure-u-1 pure-u-lg-2-3">
              <h3>{{ labelContracts }}</h3>

              <div class="metric m_b_1"><span id="number-contracts"></span></div>
              <div class="pure-g">
                <div class="pure-u-1-2">
                  <p class="m_t_0">{{ labelContractsFor }}</p>
                  <div class="metric m_b_1"><small><span id="sum-contracts"></span></small></div>

                  <div class="pure-g">
                    <div class="pure-u-1-2 explanation explanation--relative">
                      {{ labelMeanAmount }}
                      <strong class="d_block"><span id="mean-contracts"></span></strong>
                    </div>

                    <div class="pure-u-1-2 explanation explanation--relative">
                      {{ labelMedianAmount }}
                      <strong class="d_block"><span id="median-contracts"></span></strong>
                    </div>
                  </div>
                </div>

                <div class="pure-u-1-2">
                  <p class="m_t_0">{{ labelMeanSavings }}</p>
                  <div class="metric m_b_1"><small><span id="mean-savings"></span></small></div>
                </div>
              </div>
            </div> <!-- contracts -->

          </div>
        </div>
      </div> <!-- metric_box -->
    </div> <!-- metrix_boxes -->

    <div class="pure-g block m_b_3">
      <div class="pure-u-1 pure-u-lg-1-3 p_h_r_3 header_block_inline">
        <p class="decorator" v-html="labelLessThan1000"></p>
      </div>

      <div class="pure-u-1 pure-u-lg-1-3 p_h_r_3 header_block_inline">
        <p class="decorator" v-html="labelLargerContractAmount"></p>
      </div>

      <div class="pure-u-1 pure-u-lg-1-3 p_h_r_3 header_block_inline">
        <p class="decorator" v-html="labelHalfSpendingsContracts"></p>
      </div>
    </div>
  </div>
</template>

<script>
import { EventBus } from "../../mixins/event_bus";

export default {
  name: 'Summary',
  data(){
    return {
      labelTenders: I18n.t('gobierto_dashboards.dashboards.contracts.summary.tenders'),
      labelTendersFor: I18n.t('gobierto_dashboards.dashboards.contracts.summary.tenders_for'),
      labelContracts: I18n.t('gobierto_dashboards.dashboards.contracts.summary.contracts'),
      labelContractsFor: I18n.t('gobierto_dashboards.dashboards.contracts.summary.contracts_for'),
      labelMeanAmount: I18n.t('gobierto_dashboards.dashboards.contracts.summary.mean_amount'),
      labelMedianAmount: I18n.t('gobierto_dashboards.dashboards.contracts.summary.median_amount'),
      labelMeanSavings: I18n.t('gobierto_dashboards.dashboards.contracts.summary.mean_savings'),
      labelLessThan1000: I18n.t('gobierto_dashboards.dashboards.contracts.summary.label_less_than_1000'),
      labelLargerContractAmount: I18n.t('gobierto_dashboards.dashboards.contracts.summary.label_larger_contract_amount'),
      labelHalfSpendingsContracts: I18n.t('gobierto_dashboards.dashboards.contracts.summary.label_half_spendings_contracts')
    }
  },
  created() {
  },
  mounted() {
    EventBus.$emit("summary_ready");
  }
}
</script>
