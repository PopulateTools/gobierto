<template>
  <div>
    <h1 class="visualizations-contracts-show__title">
      {{ title }}
    </h1>

    <p v-if="description">
      {{ description }}
    </p>

    <div class="pure-g p_2 bg-gray visualizations-contracts-show">
      <div class="pure-u-1 pure-u-lg-1-1">
        <ContractsShowLabelHeader
          :label="labelAwardingEntity"
          :value="contractor"
          :icon="'building'"
        />
      </div>
      <ContractsShowLabelHeader
        :label="labelStatus"
        :value="status"
        :icon="'columns'"
      />
      <ContractsShowLabelHeader
        :label="labelType"
        :value="contract_type"
        :icon="'clipboard-list'"
      />
      <ContractsShowLabelHeader
        :label="labelProcess"
        :value="process_type"
        :icon="'archive'"
      />
      <div class="pure-u-1 pure-u-lg-1-1">
        <ContractsShowLabelHeader
          :label="labelCategory"
          :value="category_title"
          :icon="'tag'"
        />
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
          <ContractsShowLabelGroup
            :label="labelBidDescription"
            :value="initial_amount_no_taxes | money"
          />
          <ContractsShowLabelGroup
            v-show="numberOfProposals"
            :label="labelBiddersDescription"
            :value="numberOfProposals"
          />
        </div>
        <div class="pure-u-1 pure-u-lg-1-2">
          <ContractsShowLabelGroup
            :label="labelAwarding"
            :value="parseDate(award_date)"
          />
          <ContractsShowLabelGroup
            :label="labelContractAmount"
            :value="final_amount_no_taxes | money"
          />
          <template v-if="!hasBatch">
            <div class="pure-u-1 pure-u-lg-1-1 visualizations-contracts-show__body__group">
              <span class="visualizations-contracts-show__text__header">{{ labelAssigneeDescription }}</span>
              <router-link
                id="assignee_show_link"
                :to="{ name: 'assignees_show', params: {id: assignee_routing_id } }"
              >
                <strong class="d_block">{{ assignee }}</strong>
              </router-link>
            </div>
          </template>
          <template v-else>
            <ContractsShowTable
              :data="filterContractsBatchs"
            />
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
import { d3locale } from "lib/shared";
import ContractsShowLabelHeader from "./ContractsShowLabelHeader.vue";
import ContractsShowLabelGroup from "./ContractsShowLabelGroup.vue";
import ContractsShowTable from "./ContractsShowTable.vue";

export default {
  name: 'ContractsShow',
  components: {
    ContractsShowLabelHeader,
    ContractsShowLabelGroup,
    ContractsShowTable
  },
  mixins: [VueFiltersMixin],
  data() {
    return {
      contractsData: this.$root.$data.contractsData,
      tendersData: this.$root.$data.tendersData,
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
      cpvs: '',
      category_title: '',
      labelAwardingEntity: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.awarding_entity') || '',
      labelAssigneeDescription: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.assignee_description') || '',
      labelContractAmount: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.contract_amount') || '',
      labelType: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.type') || '',
      labelProcess: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.process') || '',
      labelTender: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.tender') || '',
      labelAwarding: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.awarding') || '',
      labelBidDescription: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.bid_description') || '',
      labelBiddersDescription: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.bidders_description') || '',
      labelEntity: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.entity') || '',
      labelQuestionDescription: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.question_description') || '',
      labelStatus: I18n.t('gobierto_visualizations.visualizations.contracts.status') || '',
      labelCategory: I18n.t('gobierto_visualizations.visualizations.subsidies.category') || '',
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
    },
    numberOfProposals() {
      const tenderContract = this.tendersData.filter(({ cpvs }) => cpvs === this.cpvs)
      return tenderContract[0]?.number_of_proposals
    }
  },
  created() {
    const itemId = this.$route.params.id;
    const contract = this.contractsData.find(({ id }) => id === itemId ) || {};

    EventBus.$emit("refresh-active-tab");

    if (contract) {
      const {
        title,
        cpvs,
        batch_number,
        category_title,
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
      this.cpvs = cpvs
      this.category_title = category_title
    }

    if (this.hasBatch) this.groupBatchs()
  },
  methods: {
    groupBatchs() {
      this.filterContractsBatchs = this.contractsData.filter(({ title }) => title === this.title).sort((a, b) => a.batch_number - b.batch_number);
    },
    calculatePercentage(value) {
      const filterByContractor = this.contractsData.filter((contract) => contract[value] === this[value])
      const totalAmount = filterByContractor.reduce((acc, { final_amount_no_taxes } ) => acc + final_amount_no_taxes, 0)
      return ((this.final_amount_no_taxes * 100) / totalAmount).toFixed(2)
    },
    parseDate(value) {
      if (!value) return
      const convertDate = new Date(value)
      const year = convertDate.getFullYear()
      const day = convertDate.getDate()
      const indexMonth = convertDate.getMonth()
      const { [I18n.locale]: { shortMonths } } = d3locale
      const month = shortMonths.filter((d, index) => index === indexMonth)

      return `${day} ${month} ${year}`
    }
  }
}
</script>
