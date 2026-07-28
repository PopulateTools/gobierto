<template>
  <div>
    <span class="visualizations-contracts-show__text__header">{{ labelAssigneesDescription }}</span>
    <!-- The class is shared with ContractsShowTableFooter, always present in the
         detail: the id is what identifies this table. -->
    <table
      id="contracts_show_siblings"
      class="visualizations-contracts-show-table"
    >
      <thead>
        <tr>
          <th>{{ isDerived ? labelDerivedContract : labelBatch }}</th>
          <th>{{ labelContractAmount }}</th>
          <th>{{ labelAssignee }}</th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="({ id, batch_number, contract_id, title, final_amount_no_taxes, assignee, assignee_routing_id }, index) in data"
          :key="contract_id || index"
        >
          <td v-if="isDerived">
            <!-- The detail route resolves its param against `id` (see
                 ContractsIndex#goesToTableItem), not against `contract_id`. -->
            <router-link
              v-if="id"
              :to="{ name: 'contracts_show', params: { id } }"
            >
              {{ title }}
            </router-link>
            <template v-else>
              {{ title }}
            </template>
          </td>
          <td v-else>
            {{ batch_number }}
          </td>
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
    },
    // 'batches' lists the lots of a multi-lot tender, keyed by lot number.
    // 'derived' lists the contracts derived from a framework agreement or a
    // dynamic acquisition system, where the lot number means nothing (they all
    // share batch_number 0) and each row is a contract of its own.
    mode: {
      type: String,
      default: 'batches',
      validator: value => ['batches', 'derived'].includes(value)
    }
  },
  data() {
    return {
      labelAssigneesDescription: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.assignees_description') || '',
      labelContractAmount: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.contract_amount') || '',
      labelBatch: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.batch') || '',
      labelDerivedContract: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.derived_contract') || '',
      labelAssignee: I18n.t('gobierto_visualizations.visualizations.contracts.assignee') || ''
    }
  },
  computed: {
    isDerived() {
      return this.mode === 'derived'
    }
  }
}
</script>
