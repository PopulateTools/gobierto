<template>
  <div>
    <h1>{{ formattedTender.title }}</h1>

    <p v-if="formattedTender.description">
      {{ formattedTender.description }}
    </p>

    <div class="pure-g p_2 bg-gray">
      <div class="pure-u-1 pure-u-lg-1-2">
      </div>

      <div class="pure-u-1 pure-u-lg-1-2">
        <table>
          <tr>
            <th class="left">{{ labelTenderAmount }}</th>
            <td>{{ formattedTender.initial_amount }}</td>
          </tr>
          <tr>
            <th class="left">{{ labelStatus }}</th>
            <td>{{ formattedTender.status }}</td>
          </tr>
          <tr>
            <th class="left">{{ labelProcessType }}</th>
            <td>{{ formattedTender.process_type }}</td>
          </tr>
        </table>
      </div>
    </div>

  </div>
</template>

<script>
import { formatCurrency } from "../../lib/utils.js";

export default {
  name: 'TendersShow',
  data() {
    return {
      tendersData: this.$root.$data.tendersData,
      tender: null,
      formattedTender: null,
      labelTenderAmount: I18n.t('gobierto_dashboards.dashboards.contracts.tender_amount'),
      labelContractAmount: I18n.t('gobierto_dashboards.dashboards.contracts.contract_amount'),
      labelStatus: I18n.t('gobierto_dashboards.dashboards.contracts.status'),
      labelProcessType: I18n.t('gobierto_dashboards.dashboards.contracts.process_type')
    }
  },
  created() {
    const itemId = this.$route.params.id;

    this.tender = this.tendersData.find((tender) => {
      return tender.id === itemId
    });

    this.initFormattedTender();
  },
  methods: {
    initFormattedTender(){
      this.formattedTender = Object.assign({}, this.tender);
      this.formattedTender.initial_amount = formatCurrency(this.formattedTender.initial_amount);
    }
  }
}
</script>
