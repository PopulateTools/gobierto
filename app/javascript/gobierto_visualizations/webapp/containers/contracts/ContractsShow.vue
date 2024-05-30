<template>
  <div>
    <h1 class="visualizations-contracts-show__title">
      {{ title }}
    </h1>

    <p v-if="description">
      {{ description }}
    </p>

    <div class="pure-g p_2 bg-gray visualizations-contracts-show">
      <ContractsShowLabelHeader
        class="visualizations-contracts-show__block"
        :label="labelAwardingEntity"
        :value="contractor"
        :icon="'building'"
      />
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
      <ContractsShowLabelHeader
        class="visualizations-contracts-show__block"
        :label="labelCategory"
        :value="category_title"
        :icon="'tag'"
      />
      <div class="visualizations-contracts-show__body">
        <div
          v-show="!isMinorContract"
          class="pure-u-1 pure-u-lg-1-2 pure-u-md-1-2"
        >
          <div class="pure-u-1 pure-u-lg-1-1 visualizations-contracts-show__body__group">
            <span class="visualizations-contracts-show__text__header">{{ labelTender }}</span>
            <span class="visualizations-contracts-show__text">{{ open_proposals_date | formatDate }}</span>
            <i
              v-show="showArrowDate"
              class="fas fa-arrow-right"
            />
            <span class="visualizations-contracts-show__text">{{ submission_date | formatDate }}</span>
          </div>
          <ContractsShowLabelGroup
            :label="labelBidDescription"
            :value="initial_amount_no_taxes | money"
          />
          <template v-if="showEstimatedValue">
            <ContractsShowLabelGroup
              :label="labelEstimatedValue"
              :value="estimated_value | money"
            />
          </template>
          <ContractsShowLabelGroup
            :label="labelBiddersDescription"
            :value="number_of_proposals"
          />
        </div>
        <div class="pure-u-1 pure-u-lg-1-2 pure-u-md-1-2">
          <ContractsShowLabelGroup
            :label="labelAwarding"
            :value="gobierto_start_date | formatDate"
          />
          <ContractsShowLabelGroup
            :label="labelContractAmount"
            :value="calculateFinalAmount | money"
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
              :data="filterContractsBatches"
            />
          </template>
        </div>
      </div>
      <ContractsShowTableFooter :data="contract" />
    </div>
  </div>
</template>

<script>
import { VueFiltersMixin, date } from '../../../../lib/vue/filters'
import { EventBus } from '../../lib/mixins/event_bus';
import ContractsShowLabelHeader from '../../components/ContractsShowLabelHeader.vue';
import ContractsShowLabelGroup from '../../components/ContractsShowLabelGroup.vue';
import ContractsShowTable from '../../components/ContractsShowTable.vue';
import ContractsShowTableFooter from '../../components/ContractsShowTableFooter.vue';

export default {
  name: 'ContractsShow',
  components: {
    ContractsShowLabelHeader,
    ContractsShowLabelGroup,
    ContractsShowTable,
    ContractsShowTableFooter
  },
  filters: {
    formatDate(value) {
      return date(value, { year: 'numeric', month: 'short', day: 'numeric' })
    }
  },
  mixins: [VueFiltersMixin],
  data() {
    return {
      contractsData: this.$root.$data.contractsData,
      contract: {},
      title: '',
      description: '',
      assignee: '',
      assignee_id: '',
      final_amount_no_taxes: '',
      initial_amount_no_taxes: '',
      status: '',
      process_type: '',
      assignee_routing_id: '',
      contractor: '',
      contract_type: '',
      start_date: '',
      end_date: '',
      gobierto_start_date: '',
      batch_number: '',
      minor_contract: '',
      open_proposals_date: '',
      submission_date: '',
      number_of_proposals: '',
      cpvs: '',
      category_title: '',
      estimated_value: '',
      labelAwardingEntity: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.awarding_entity') || '',
      labelAssigneeDescription: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.assignee_description') || '',
      labelContractAmount: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.contract_amount') || '',
      labelTender: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.tender') || '',
      labelAwarding: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.formalization') || '',
      labelBidDescription: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.bid_description') || '',
      labelBiddersDescription: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.bidders_description') || '',
      labelStatus: I18n.t('gobierto_visualizations.visualizations.contracts.status') || '',
      labelCategory: I18n.t('gobierto_visualizations.visualizations.subsidies.category') || '',
      labelProcess: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.process') || '',
      labelType: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.type') || '',
      labelEstimatedValue: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.estimated_value') || '',
      filterContractsBatches: []
    }
  },
  computed: {
    hasBatch() {
      return this.batch_number > 0
    },
    isMinorContract() {
      return this.minor_contract === 't'
    },
    showArrowDate() {
      return this.submission_date && this.open_proposals_date
    },
    showEstimatedValue() {
      return this.initial_amount_no_taxes !== this.estimated_value
    },
    calculateFinalAmount() {
      return this.batch_number > 0
        ? this.filterContractsBatches.reduce((acc, { final_amount_no_taxes }) => acc + final_amount_no_taxes, 0)
        : this.final_amount_no_taxes
    }
  },
  created() {
    const itemId = this.$route.params.id;
    this.contract = this.contractsData.find(({ id }) => id === itemId ) || {};

    EventBus.$emit("refresh-active-tab");

    if (this.contract) {
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
        assignee_routing_id,
        start_date,
        end_date,
        gobierto_start_date,
        minor_contract,
        open_proposals_date,
        submission_date,
        number_of_proposals,
        estimated_value
      } = this.contract

      this.title = title
      this.description = description
      this.assignee = assignee
      this.assignee_id = assignee_id
      this.final_amount_no_taxes = final_amount_no_taxes
      this.initial_amount_no_taxes = initial_amount_no_taxes
      this.status = status
      this.process_type = process_type
      this.contract_type = contract_type
      this.assignee_routing_id = assignee_routing_id
      this.contractor = contractor
      this.contract_type = contract_type
      this.start_date = start_date
      this.end_date = end_date
      this.gobierto_start_date = gobierto_start_date
      this.batch_number = +batch_number
      this.minor_contract = minor_contract
      this.open_proposals_date = open_proposals_date || null
      this.submission_date = submission_date || null
      this.cpvs = cpvs
      this.category_title = category_title
      this.number_of_proposals = number_of_proposals
      this.estimated_value = +estimated_value
    }

    if (this.hasBatch) this.groupBatches()
  },
  methods: {
    groupBatches() {
      this.filterContractsBatches = this.contractsData.filter(({ title }) => title === this.title).sort((a, b) => a.batch_number - b.batch_number);
    }
  }
}
</script>
