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
            <td>{{ tender.initial_amount }}</td>
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

export default {
  name: 'ContractsShow',
  data() {
    return {
      tendersData: this.$root.$data.tendersData,
      tender: null,
      labelTenderAmount: '',
      labelContractAmount: '',
      labelStatus: '',
      labelProcessType: '',
    }
  },
  updated() {
    this.$emit("active-tab", 2);
  },
  created() {
    this.labelTenderAmount = I18n.t('gobierto_dashboards.dashboards.contracts.tender_amount')
    this.labelContractAmount = I18n.t('gobierto_dashboards.dashboards.contracts.contract_amount')
    this.labelStatus = I18n.t('gobierto_dashboards.dashboards.contracts.status')
    this.labelProcessType = I18n.t('gobierto_dashboards.dashboards.contracts.process_type')

    const itemId = this.$route.params.id;

    this.tender = this.tendersData.find((tender) => {
      return tender.id === itemId
    });
  }
}
</script>
