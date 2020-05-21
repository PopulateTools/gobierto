<template>
  <div>
    <h1>{{ title }}</h1>

    <p v-if="description">
      {{ description }}
    </p>

    <div class="pure-g p_2 bg-gray">
      <div class="pure-u-1 pure-u-lg-1-2">
        <label class="soft">{{ labelAsignee }}</label>
        <div class="">
          <strong class="d_block">{{ assignee }}</strong>
          <span v-if="document_number">
            {{document_number}}
          </span>
        </div>
      </div>

      <div class="pure-u-1 pure-u-lg-1-2">
        <table>
          <tr>
            <th class="left">{{ labelContractAmount }}</th>
            <td>{{ final_amount | money }}</td>
          </tr>
          <tr>
            <th class="left">{{ labelTenderAmount }}</th>
            <td>{{ initial_amount | money }}</td>
          </tr>
          <tr>
            <th class="left">{{ labelStatus }}</th>
            <td>{{ status }}</td>
          </tr>
          <tr>
            <th class="left">{{ labelProcessType }}</th>
            <td>{{ process_type }}</td>
          </tr>
          <tr>
            <th class="left">
              <a :href="permalink" target='blank'>{{ labelPermalink }}</a>
            </th>
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
      title: '',
      description: '',
      assignee: '',
      document_number: '',
      final_amount: '',
      initial_amount: '',
      status: '',
      process_type: '',
      permalink: '',
      labelAsignee: I18n.t('gobierto_dashboards.dashboards.contracts.assignee'),
      labelTenderAmount: I18n.t('gobierto_dashboards.dashboards.contracts.tender_amount'),
      labelContractAmount: I18n.t('gobierto_dashboards.dashboards.contracts.contract_amount'),
      labelStatus: I18n.t('gobierto_dashboards.dashboards.contracts.status'),
      labelProcessType: I18n.t('gobierto_dashboards.dashboards.contracts.process_type'),
      labelPermalink: I18n.t('gobierto_dashboards.dashboards.contracts.permalink')
    }
  },
  created() {
    const itemId = this.$route.params.id;
    const contract = this.contractsData.find(({ id }) => id === itemId );

    if (contract) {
      const {
        title,
        description,
        assignee,
        document_number,
        final_amount,
        initial_amount,
        status,
        process_type,
        permalink
      } = contract

      this.title = title
      this.description = description
      this.assignee = assignee
      this.document_number = document_number
      this.final_amount = final_amount
      this.initial_amount = initial_amount
      this.status = status
      this.process_type = process_type
      this.permalink = permalink
    }
  }
}
</script>
