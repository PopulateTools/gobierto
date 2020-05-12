<template>
  <div>
    <h1>{{ formattedContract.title }}</h1>

    <p v-if="formattedContract.description">
      {{ formattedContract.description }}
    </p>

    <div class="pure-g p_2 bg-gray">
      <div class="pure-u-1 pure-u-lg-1-2">
        <label class="soft">{{ labelAsignee }}</label>
        <div class="">
          <strong class="d_block">{{ formattedContract.assignee }}</strong>
          <span v-if="formattedContract.document_number">
            {{formattedContract.document_number}}
          </span>
        </div>
      </div>

      <div class="pure-u-1 pure-u-lg-1-2">
        <table>
          <tr>
            <th class="left">{{ labelContractAmount }}</th>
            <td>{{ formattedContract.final_amount }}</td>
          </tr>
          <tr>
            <th class="left">{{ labelTenderAmount }}</th>
            <td>{{ formattedContract.initial_amount }}</td>
          </tr>
          <tr>
            <th class="left">{{ labelStatus }}</th>
            <td>{{ formattedContract.status }}</td>
          </tr>
          <tr>
            <th class="left">{{ labelProcessType }}</th>
            <td>{{ formattedContract.process_type }}</td>
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
      contractsData: this.$root.$data.contractsData,
      contract: null,
      formattedContract: null,
      labelAsignee: I18n.t('gobierto_dashboards.dashboards.contracts.assignee'),
      labelTenderAmount: I18n.t('gobierto_dashboards.dashboards.contracts.tender_amount'),
      labelContractAmount: I18n.t('gobierto_dashboards.dashboards.contracts.contract_amount'),
      labelStatus: I18n.t('gobierto_dashboards.dashboards.contracts.status'),
      labelProcessType: I18n.t('gobierto_dashboards.dashboards.contracts.process_type')
    }
  },
  updated() {
    this.$emit("active-tab", 1);
  },
  created() {
    const itemId = this.$route.params.id;

    this.contract = this.contractsData.find((contract) => {
      return contract.id === itemId
    });

    this.initFormattedContract();
  },
  methods: {
    initFormattedContract(){
      this.formattedContract = Object.assign({}, this.contract);
      this.formattedContract.final_amount = this.formatCurrency(this.formattedContract.final_amount);
      this.formattedContract.initial_amount = this.formatCurrency(this.formattedContract.initial_amount);
    },
    formatCurrency(amount){
      return parseFloat(amount).toLocaleString(I18n.locale, {
        style: 'currency',
        currency: 'EUR'
      })
    }
  }
}
</script>
