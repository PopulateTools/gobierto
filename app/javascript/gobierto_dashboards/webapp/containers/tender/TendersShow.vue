<template>
  <div>
    <h1>{{ tender.title }}</h1>

    <p v-if="tender.description">
      {{ tender.description }}
    </p>

    <div class="pure-g p_2 bg-gray">
      <div class="pure-u-1 pure-u-lg-1-2">
      </div>

      <div class="pure-u-1 pure-u-lg-1-2">
        <table>
          <tr>
            <th class="left">{{ labelTenderAmount }}</th>
            <td>{{ tender.initial_amount | money }}</td>
          </tr>
          <tr>
            <th class="left">{{ labelStatus }}</th>
            <td>{{ tender.status }}</td>
          </tr>
          <tr>
            <th class="left">{{ labelProcessType }}</th>
            <td>{{ tender.process_type }}</td>
          </tr>
        </table>
      </div>
    </div>

  </div>
</template>

<script>
import { VueFiltersMixin } from "lib/shared"

export default {
  name: 'TendersShow',
  mixins: [VueFiltersMixin],
  data() {
    return {
      tendersData: this.$root.$data.tendersData,
      tender: null,
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
  }
}
</script>
