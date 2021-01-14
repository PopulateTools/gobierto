<template>
  <div>
    <h1>{{ title }}</h1>

    <p v-if="description">
      {{ description }}
    </p>

    <div class="pure-g p_2 bg-gray visualizations-contracts-show">
      <div class="pure-u-1 pure-u-lg-1-1">
        <i class="fas fa-building visualizations-contracts-show__icon" />
        <span class="visualizations-contracts-show__text">Entidad Adjudicadora</span>
        <span class="visualizations-contracts-show__text">{{ contractor }}</span>
      </div>
      <div class="pure-u-1 pure-u-lg-1-1">
        <i class="fas fa-columns visualizations-contracts-show__icon" />
        <span class="visualizations-contracts-show__text">{{ labelStatus }}</span>
        <span class="visualizations-contracts-show__text">{{ status }}</span>
        <i class="fas fa-clipboard-list visualizations-contracts-show__icon" />
        <span class="visualizations-contracts-show__text">Estado</span>
        <span class="visualizations-contracts-show__text">{{ contract_type }}</span>
        <i class="fas fa-archive visualizations-contracts-show__icon" />
        <span class="visualizations-contracts-show__text">Estado</span>
        <span class="visualizations-contracts-show__text">{{ process_type }}</span>
      </div>
      <div class="pure-u-1 pure-u-lg-1-2">
        <span class="visualizations-contracts-show__text__header">Licitación</span>
        <span class="visualizations-contracts-show__text">{{ start_date }}</span>
        <i class="fas fa-arrow-right" />
        <span class="visualizations-contracts-show__text">{{ end_date }}</span>
      </div>
      <div class="pure-u-1 pure-u-lg-1-2">
        <span class="visualizations-contracts-show__text__header">Licitación</span>
        <span class="visualizations-contracts-show__text">{{ award_date }}</span>
      </div>
      <div class="pure-u-1 pure-u-lg-1-2">
        <span class="visualizations-contracts-show__text__header">Presupuesto base de licitación sin impuestos</span>
        <span class="visualizations-contracts-show__text">{{ initial_amount_no_taxes | money }}</span>
      </div>
      <div class="pure-u-1 pure-u-lg-1-2">
        <span class="visualizations-contracts-show__text__header">Importe de adjudicación</span>
        <span class="visualizations-contracts-show__text">{{ final_amount_no_taxes | money }}</span>
      </div>
      <div class="pure-u-1 pure-u-lg-1-2">
        Licitadores
      </div>
      <div class="pure-u-1 pure-u-lg-1-2">
        <router-link
          id="assignee_show_link"
          :to="{ name: 'assignees_show', params: {id: assignee_routing_id } }"
        >
          <strong class="d_block">{{ assignee }}</strong>
        </router-link>
      </div>
      <div class="pure-u-1 pure-u-lg-1-2" />
      <div
        v-if="hasBatch"
        class="pure-u-1 pure-u-lg-1-2"
      >
        Adjudicatarios
        <table>
          <thead>
            <tr>
              <th>Lote</th>
              <th>Importe Adjudicación</th>
              <th>Adjudicatario</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="{ batch_number, final_amount_no_taxes, assignee } in filterContractsBatchs"
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
      <div class="pure-u-1 pure-u-lg-1-2">
        <span>¿Qué % de presupuesto supone este contrato?</span>
        <span>Órgano {{ calculatePercentage('contractor') }} %</span>
        <span>Tipo {{ calculatePercentage('contract_type') }} %</span>
        <span>Proceso {{ calculatePercentage('process_type') }} %</span>
      </div>
    </div>
  </div>
</template>

<script>

import { VueFiltersMixin } from "lib/vue/filters"
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
      contractor: '',
      contract_type: '',
      start_date: '',
      end_date: '',
      award_date: '',
      batch_number: '',
      labelAsignee: I18n.t('gobierto_visualizations.visualizations.contracts.assignee'),
      labelTenderAmount: I18n.t('gobierto_visualizations.visualizations.contracts.tender_amount'),
      labelContractAmount: I18n.t('gobierto_visualizations.visualizations.contracts.contract_amount'),
      labelStatus: I18n.t('gobierto_visualizations.visualizations.contracts.status'),
      labelProcessType: I18n.t('gobierto_visualizations.visualizations.contracts.process_type'),
      labelContractType: I18n.t('gobierto_visualizations.visualizations.contracts.contract_type'),
      labelPermalink: I18n.t('gobierto_visualizations.visualizations.contracts.permalink'),
      filterContractsBatchs: []
    }
  },
  computed: {
    hasBatch() {
      return this.batch_number > 0
    }
  },
  created() {
    const itemId = this.$route.params.id;
    const contract = this.contractsData.find(({ id }) => id === itemId ) || {};

    EventBus.$emit("refresh-active-tab");

    if (contract) {
      const {
        title,
        batch_number,
        contractor,
        description,
        assignee,
        assignee_id,
        final_amount_no_taxes,
        initial_amount_no_taxes,
        status,
        process_type,
        contract_type,
        permalink,
        assignee_routing_id,
        start_date,
        end_date,
        award_date
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
      this.contractor = contractor
      this.contract_type = contract_type
      this.start_date = start_date
      this.end_date = end_date
      this.award_date = award_date
      this.batch_number = +batch_number
    }

    if (this.hasBatch) this.groupBatchs()
  },
  methods: {
    groupBatchs() {
      this.filterContractsBatchs = this.contractsData.filter(({ title }) => title === this.title).sort((a, b) => a.batch_number - b.batch_number);
    },
    calculatePercentage(value) {
      const filterByContractor = this.contractsData.filter((contract) => contract[value] === this[value])
      const totalAmount = filterByContractor.map(({ final_amount_no_taxes }) => final_amount_no_taxes).reduce((prev, next) => prev + next);
      return ((this.final_amount_no_taxes * 100) / totalAmount).toFixed(0)
    },
  }
}
</script>
