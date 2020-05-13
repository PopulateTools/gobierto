<template>
  <div>
    <h1>{{ contract.title }}</h1>

    <p v-if="contract.description">
      {{ contract.description }}
    </p>

    <div class="pure-g p_2 bg-gray">
      <div class="pure-u-1 pure-u-lg-1-2">
        <label class="soft">{{ labelAsignee }}</label>
        <div class="">
          <strong class="d_block">{{ contract.assignee }}</strong>
          <span v-if="contract.document_number">
            {{contract.document_number}}
          </span>
        </div>
      </div>

      <div class="pure-u-1 pure-u-lg-1-2">
        <table>
          <tr>
            <th class="left">{{ labelContractAmount }}</th>
            <td>{{ contract.final_amount | money }}</td>
          </tr>
          <tr>
            <th class="left">{{ labelTenderAmount }}</th>
            <td>{{ contract.initial_amount | money }}</td>
          </tr>
          <tr>
            <th class="left">{{ labelStatus }}</th>
            <td>{{ contract.status }}</td>
          </tr>
          <tr>
            <th class="left">{{ labelProcessType }}</th>
            <td>{{ contract.process_type }}</td>
          </tr>
        </table>

      </div>
    </div>

  </div>
</template>

<script>

import { VueFiltersMixin } from "lib/shared"

export default {
  name: 'ContractsShow',
  mixins: [VueFiltersMixin],
  data() {
    return {
      contractsData: this.$root.$data.contractsData,
      contract: null,
      labelAsignee: I18n.t('gobierto_dashboards.dashboards.contracts.assignee'),
      labelTenderAmount: I18n.t('gobierto_dashboards.dashboards.contracts.tender_amount'),
      labelContractAmount: I18n.t('gobierto_dashboards.dashboards.contracts.contract_amount'),
      labelStatus: I18n.t('gobierto_dashboards.dashboards.contracts.status'),
      labelProcessType: I18n.t('gobierto_dashboards.dashboards.contracts.process_type')
    }
  },
  created() {
    const itemId = this.$route.params.id;

    this.contract = this.contractsData.find((contract) => {
      return contract.id === itemId
    });
  }
}
</script>
