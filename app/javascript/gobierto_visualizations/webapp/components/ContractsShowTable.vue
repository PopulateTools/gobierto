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
          v-for="(row, index) in data"
          :key="row.contract_id || index"
        >
          <td v-if="isDerived">
            <!-- Each row is a contract of its own, so it links through its routing
                 key: `id` holds the effective tender and every derived contract of
                 the same establishment shares it. -->
            <router-link
              v-if="rowRoutingId(row)"
              :to="{ name: 'contracts_show', params: { id: rowRoutingId(row) } }"
            >
              {{ row.title }}
            </router-link>
            <template v-else>
              {{ row.title }}
            </template>
          </td>
          <td v-else>
            {{ row.batch_number }}
          </td>
          <td>{{ row.final_amount_no_taxes | money }}</td>
          <td>
            <router-link
              id="assignee_show_link"
              :to="{ name: 'assignees_show', params: {id: row.assignee_routing_id } }"
            >
              <strong class="d_block">{{ row.assignee }}</strong>
            </router-link>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
<script>

import { VueFiltersMixin } from '../../../lib/vue/filters'
import { contractRoutingId } from '../lib/utils';
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
  },
  methods: {
    rowRoutingId(row) {
      return contractRoutingId(row)
    }
  }
}
</script>
