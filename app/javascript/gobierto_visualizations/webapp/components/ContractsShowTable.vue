<template>
  <div>
    <span class="visualizations-contracts-show__text__header">{{ labelAssigneesDescription }}</span>
    <table class="visualizations-contracts-show-table">
      <thead>
        <tr>
          <th>{{ labelBatch }}</th>
          <th>{{ labelContractAmount }}</th>
          <th>{{ labelAssignee }}</th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="{ batch_number, final_amount_no_taxes, assignee, assignee_routing_id } in data"
          :key="batch_number"
        >
          <td>{{ batch_number }}</td>
          <td>{{ final_amount_no_taxes | money }}</td>
          <td>
            <router-link
              id="assignee_show_link"
              :to="{ name: 'assignees_show', params: {id: assignee_routing_id } }"
            >
              <strong class="d_block">{{ assignee }}</strong>
            </router-link>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
<script>

import { VueFiltersMixin } from '../../../lib/vue/filters'
export default {
  name: 'ContractsShowTable',
  mixins: [VueFiltersMixin],
  props: {
    data: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      labelAssigneesDescription: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.assignees_description') || '',
      labelContractAmount: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.contract_amount') || '',
      labelBatch: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.batch') || '',
      labelAssignee: I18n.t('gobierto_visualizations.visualizations.contracts.assignee') || ''
    }
  }
}
</script>
