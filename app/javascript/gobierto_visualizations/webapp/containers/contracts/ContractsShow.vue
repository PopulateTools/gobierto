<template>
  <div>
    <h1 class="visualizations-contracts-show__title">
      {{ title }}
    </h1>

    <p v-if="description">
      {{ description }}
    </p>

    <div class="pure-g p_2 bg-gray visualizations-contracts-show">
      <div class="pure-u-1 pure-u-lg-1-1 visualizations-contracts-show__header__group">
        <i class="fas fa-building visualizations-contracts-show__icon" />
        <span class="visualizations-contracts-show__text">{{ labelAwardingEntity }}</span>
        <span class="visualizations-contracts-show__text visualizations-contracts-show__text__bold">{{ contractor }}</span>
      </div>
      <div class="pure-u-1 pure-u-lg-1-1">
        <div class="visualizations-contracts-show__header__group__element">
          <i class="fas fa-columns visualizations-contracts-show__icon" />
          <span class="visualizations-contracts-show__text">{{ labelStatus }}</span>
          <span class="visualizations-contracts-show__text visualizations-contracts-show__text__bold">{{ status }}</span>
        </div>
        <div class="visualizations-contracts-show__header__group__element">
          <i class="fas fa-clipboard-list visualizations-contracts-show__icon" />
          <span class="visualizations-contracts-show__text">{{ labelType }}</span>
          <span class="visualizations-contracts-show__text visualizations-contracts-show__text__bold">{{ contract_type }}</span>
        </div>
        <div class="visualizations-contracts-show__header__group__element">
          <i class="fas fa-archive visualizations-contracts-show__icon" />
          <span class="visualizations-contracts-show__text">{{ labelProcess }}</span>
          <span class="visualizations-contracts-show__text visualizations-contracts-show__text__bold">{{ process_type }}</span>
        </div>
      </div>
      <div class="visualizations-contracts-show__body">
        <div
          v-show="minorContract"
          class="pure-u-1 pure-u-lg-1-2"
        >
          <div class="pure-u-1 pure-u-lg-1-1 visualizations-contracts-show__body__group">
            <span class="visualizations-contracts-show__text__header">{{ labelTender }}</span>
            <span class="visualizations-contracts-show__text">{{ parseDate(submission_date) }}</span>
            <i
              v-show="showArrowDate"
              class="fas fa-arrow-right"
            />
            <span class="visualizations-contracts-show__text">{{ parseDate(open_proposals_date) }}</span>
          </div>
          <div class="pure-u-1 pure-u-lg-1-1 visualizations-contracts-show__body__group">
            <span class="visualizations-contracts-show__text__header">{{ labelBidDescription }}</span>
            <span class="visualizations-contracts-show__text">{{ initial_amount_no_taxes | money }}</span>
          </div>
          <div class="pure-u-1 pure-u-lg-1-1 visualizations-contracts-show__body__group">
            <span class="visualizations-contracts-show__text__header">{{ labelBidders }}</span>
          </div>
        </div>
        <div class="pure-u-1 pure-u-lg-1-2">
          <div class="pure-u-1 pure-u-lg-1-1 visualizations-contracts-show__body__group">
            <span class="visualizations-contracts-show__text__header">{{ labelAwarding }}</span>
            <span class="visualizations-contracts-show__text">{{ parseDate(award_date) }}</span>
          </div>
          <div class="pure-u-1 pure-u-lg-1-1 visualizations-contracts-show__body__group">
            <span class="visualizations-contracts-show__text__header">{{ labelContractAmount }}</span>
            <span class="visualizations-contracts-show__text">{{ final_amount_no_taxes | money }}</span>
          </div>
          <template v-if="!hasBatch">
            <div class="pure-u-1 pure-u-lg-1-1 visualizations-contracts-show__body__group">
              <span class="visualizations-contracts-show__text__header">{{ labelAssignee }}</span>
              <router-link
                id="assignee_show_link"
                :to="{ name: 'assignees_show', params: {id: assignee_routing_id } }"
              >
                <strong class="d_block">{{ assignee }}</strong>
              </router-link>
            </div>
          </template>
          <template v-else>
            <span class="visualizations-contracts-show__text__header">{{ labelAssignees }}</span>
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
          </template>
        </div>
      </div>
      <div class="pure-u-1 pure-u-lg-1-2">
        <span class="visualizations-contracts-show__text__header">{{ labelQuestionDescription }}</span>
        <table class="visualizations-contracts-show-table">
          <tr>
            <td>
              <span class="visualizations-contracts-show__text">{{ labelEntity }}</span>
            </td>
            <td>
              <span class="visualizations-contracts-show__text"><b>{{ calculatePercentage('contractor') }} %</b></span>
            </td>
          </tr>
          <tr>
            <td>
              <span class="visualizations-contracts-show__text">{{ labelType }}</span>
            </td>
            <td>
              <span class="visualizations-contracts-show__text"><b>{{ calculatePercentage('contract_type') }} %</b></span>
            </td>
          </tr>
          <tr>
            <td>
              <span class="visualizations-contracts-show__text">{{ labelProcess }}</span>
            </td>
            <td>
              <span class="visualizations-contracts-show__text"><b>{{ calculatePercentage('process_type') }} %</b></span>
            </td>
          </tr>
        </table>
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
      minor_contract: '',
      open_proposals_date: '',
      submission_date: '',
      labelAwardingEntity: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.awarding_entity') || '',
      labelType: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.type') || '',
      labelProcess: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.process') || '',
      labelTender: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.tender') || '',
      labelAwarding: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.awarding') || '',
      labelBidDescription: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.bid_description') || '',
      labelContractAmount: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.contract_amount') || '',
      labelBidders: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.bidders') || '',
      labelAssignees: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.assignees') || '',
      labelBatch: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.batch') || '',
      labelEntity: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.entity') || '',
      labelQuestionDescription: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.question_description') || '',
      labelAssignee: I18n.t('gobierto_visualizations.visualizations.contracts.assignee') || '',
      labelStatus: I18n.t('gobierto_visualizations.visualizations.contracts.status') || '',
      filterContractsBatchs: []
    }
  },
  computed: {
    hasBatch() {
      return this.batch_number > 0
    },
    minorContract() {
      return this.minor_contract === 'f'
    },
    showArrowDate() {
      return this.submission_date && this.open_proposals_date
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
        award_date,
        minor_contract,
        open_proposals_date,
        submission_date
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
      this.minor_contract = minor_contract
      this.open_proposals_date = open_proposals_date || null
      this.submission_date = submission_date || null
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
      return ((this.final_amount_no_taxes * 100) / totalAmount).toFixed(2)
    },
    parseDate(value) {
      if (!value) return
      const convertDate = new Date(value)
      const year = convertDate.getFullYear()
      const day = convertDate.getDate()
      const month = convertDate.toLocaleString('default', { month: 'short' });

      return `${day} ${month} ${year}`
    }
  }
}
</script>
