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
          <router-link
            id="assignee_show_link"
            :to="{ name: 'assignees_show', params: {id: assignee_routing_id } }"
          >
            <strong class="d_block">{{ assignee }}</strong>
          </router-link>
          <span v-if="assignee_id">
            {{ assignee_id }}
          </span>
        </div>
      </div>

      <div class="pure-u-1 pure-u-lg-1-2">
        <table>
          <tr>
            <th class="left">
              {{ labelContractAmount }}
            </th>
            <td>{{ final_amount_no_taxes | money }}</td>
          </tr>
          <tr>
            <th class="left">
              {{ labelTenderAmount }}
            </th>
            <td>{{ initial_amount_no_taxes | money }}</td>
          </tr>
          <tr>
            <th class="left">
              {{ labelStatus }}
            </th>
            <td>{{ status }}</td>
          </tr>
          <tr>
            <th class="left">
              {{ labelContractType }}
            </th>
            <td>{{ contract_type }}</td>
          </tr>
          <tr>
            <th class="left">
              {{ labelProcessType }}
            </th>
            <td>{{ process_type }}</td>
          </tr>
          <tr>
            <th class="left">
              <a
                :href="permalink"
                target="_blank"
              >
                {{ labelPermalink }}
              </a>
            </th>
          </tr>
        </table>
      </div>
    </div>
  </div>
</template>

<script>

import { VueFiltersMixin } from "lib/shared"
import { EventBus } from "../../mixins/event_bus";

export default {
  name: 'ContractsShow',
  mixins: [VueFiltersMixin],
  data() {
    return {
      contractsData: this.$root.$data.contractsData,
      title: '',
      description: '',
      assignee: '',
      assignee_id: '',
      final_amount_no_taxes: '',
      initial_amount_no_taxes: '',
      status: '',
      process_type: '',
      permalink: '',
      assignee_routing_id: '',
      labelAsignee: I18n.t('gobierto_visualizations.visualizations.contracts.assignee'),
      labelTenderAmount: I18n.t('gobierto_visualizations.visualizations.contracts.tender_amount'),
      labelContractAmount: I18n.t('gobierto_visualizations.visualizations.contracts.contract_amount'),
      labelStatus: I18n.t('gobierto_visualizations.visualizations.contracts.status'),
      labelProcessType: I18n.t('gobierto_visualizations.visualizations.contracts.process_type'),
      labelContractType: I18n.t('gobierto_visualizations.visualizations.contracts.contract_type'),
      labelPermalink: I18n.t('gobierto_visualizations.visualizations.contracts.permalink')
    }
  },
  created() {
    const itemId = this.$route.params.id;
    const contract = this.contractsData.find(({ id }) => id === itemId ) || {};

    EventBus.$emit("refresh-active-tab");

    if (contract) {
      const {
        title,
        description,
        assignee,
        assignee_id,
        final_amount_no_taxes,
        initial_amount_no_taxes,
        status,
        process_type,
        contract_type,
        permalink,
        assignee_routing_id
      } = contract

      this.title = title
      this.description = description
      this.assignee = assignee
      this.assignee_id = assignee_id
      this.final_amount_no_taxes = final_amount_no_taxes
      this.initial_amount_no_taxes = initial_amount_no_taxes
      this.status = status
      this.process_type = process_type
      this.contract_type = contract_type
      this.permalink = permalink
      this.assignee_routing_id = assignee_routing_id
    }
  }
}
</script>
