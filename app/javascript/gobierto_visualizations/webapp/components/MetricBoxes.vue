<template>
  <div
    id="tendersContractsSummary"
    class="metric_boxes mt4"
  >
    <div class="metric_box">
      <div class="inner nomargin ">
        <div class="pure-g p_1">
          <div class="pure-u-1 pure-u-lg-1-3">
            <h3>{{ labelTenders }}</h3>

            <div class="metric m_b_1">
              <span id="number-tenders" />
            </div>
            <p class="m_t_0">
              {{ labelTendersFor }}
            </p>
            <div class="metric m_b_1">
              <small><span id="sum-tenders" /></small>
            </div>

            <div class="pure-g">
              <div class="pure-u-1-2 explanation explanation--relative">
                {{ labelMeanAmount }}
                <strong class="d_block"><span id="mean-tenders" /></strong>
              </div>

              <div class="pure-u-1-2 explanation explanation--relative">
                {{ labelMedianAmount }}
                <strong class="d_block"><span id="median-tenders" /></strong>
              </div>
            </div>
          </div> <!-- tenders block -->

          <div class="pure-u-1 pure-u-lg-2-3">
            <h3>{{ labelAwardedContracts }}</h3>

            <div class="metric m_b_1">
              <span id="number-contracts" />
            </div>
            <div class="pure-g">
              <div class="pure-u-1-2">
                <p class="m_t_0">
                  {{ labelContractsFor }}
                </p>
                <div class="metric m_b_1">
                  <small><span id="sum-contracts" /></small>
                </div>

                <div class="pure-g">
                  <div class="pure-u-1-2 explanation explanation--relative">
                    {{ labelMeanAmount }}
                    <strong class="d_block">
                      <span id="mean-contracts" />
                    </strong>
                  </div>

                  <div class="pure-u-1-2 explanation explanation--relative">
                    {{ labelMedianAmount }}
                    <strong class="d_block">
                      <span id="median-contracts" />
                    </strong>
                  </div>
                </div>
              </div>
            </div>
          </div> <!-- contracts -->
        </div>
      </div>
    </div> <!-- metric_box -->
  </div> <!-- metrix_boxes -->
</template>

<script>
export default {
  name: "MetricBoxes",
  data() {
    return {
      labelTenders: I18n.t("gobierto_visualizations.visualizations.contracts.summary.tenders"),
      labelTendersFor: I18n.t("gobierto_visualizations.visualizations.contracts.summary.tenders_for"),
      labelAwardedContracts: I18n.t("gobierto_visualizations.visualizations.contracts.summary.contracts"),
      labelContractsFor: I18n.t("gobierto_visualizations.visualizations.contracts.summary.contracts_for"),
      labelMeanAmount: I18n.t("gobierto_visualizations.visualizations.contracts.summary.mean_amount"),
      labelMedianAmount: I18n.t("gobierto_visualizations.visualizations.contracts.summary.median_amount"),
      labelMeanSavings: I18n.t("gobierto_visualizations.visualizations.contracts.summary.mean_savings"),
    }
  }
}
</script>
