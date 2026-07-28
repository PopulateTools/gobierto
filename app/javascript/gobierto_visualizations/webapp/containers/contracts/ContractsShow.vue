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
        v-if="document_number"
        class="visualizations-contracts-show__block"
        :label="labelDocumentNumber"
        :value="document_number"
        :icon="'folder'"
      />
      <ContractsShowLabelHeader
        v-if="contracting_system"
        class="visualizations-contracts-show__block"
        :label="labelContractingSystem"
        :value="contracting_system"
        :icon="'sitemap'"
      />
      <!-- The establishment tender has no row in `contratos`, so it is reachable
           only from here and by its URL. The guard keeps the row out of the detail
           on sites still serving the old CSV, where the field is always empty. -->
      <ContractsShowLabelHeader
        v-if="showEstablishment"
        class="visualizations-contracts-show__block"
        :label="labelEstablishment"
        :value="establishmentValue"
        :icon="'sitemap'"
        :to="establishmentRoute"
        :link-id="'establishment_show_link'"
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
            v-if="!isTenderDetail"
            :label="labelBiddersDescription"
            :value="number_of_proposals"
          />
          <ContractsShowLabelGroup
            v-if="isTenderDetail && number_of_batches"
            :label="labelNumberOfBatches"
            :value="number_of_batches"
          />
        </div>
        <div class="pure-u-1 pure-u-lg-1-2 pure-u-md-1-2">
          <ContractsShowLabelGroup
            v-if="!isTenderDetail"
            :label="labelAwarding"
            :value="gobierto_start_date | formatDate"
          />
          <!-- On a tender the total is the sum of independent contracts, so it
               carries a label of its own: it is nobody's award amount. -->
          <ContractsShowLabelGroup
            v-if="showAmount"
            :label="isTenderDetail ? labelDerivedContractsAmount : labelContractAmount"
            :value="calculateFinalAmount | money"
          />
          <template v-if="showSiblingsTable">
            <ContractsShowTable
              :data="filterContractsBatches"
              :mode="tableMode"
            />
          </template>
          <p v-else-if="isTenderDetail">
            {{ labelNoDerivedContracts }}
          </p>
          <template v-else-if="isContractDetail">
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
        </div>
      </div>
      <!-- Reads the contract fields and answers "what % of the spending is this
           contract": meaningless, and unrenderable, without a contract. -->
      <ContractsShowTableFooter
        v-if="isContractDetail"
        :data="contract"
      />
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
import { contractRoutingId, effectiveTenderId } from '../../lib/utils';

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
      isTenderDetail: false,
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
      number_of_batches: '',
      cpvs: '',
      category_title: '',
      document_number: '',
      contracting_system: '',
      estimated_value: '',
      establishment_title: '',
      establishment_document_number: '',
      labelAwardingEntity: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.awarding_entity') || '',
      labelAssigneeDescription: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.assignee_description') || '',
      labelContractAmount: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.contract_amount') || '',
      labelDerivedContractsAmount: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.derived_contracts_amount') || '',
      labelNoDerivedContracts: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.no_derived_contracts') || '',
      labelNumberOfBatches: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.number_of_batches') || '',
      labelTender: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.tender') || '',
      labelAwarding: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.formalization') || '',
      labelBidDescription: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.bid_description') || '',
      labelBiddersDescription: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.bidders_description') || '',
      labelStatus: I18n.t('gobierto_visualizations.visualizations.contracts.status') || '',
      labelCategory: I18n.t('gobierto_visualizations.visualizations.subsidies.category') || '',
      labelDocumentNumber: I18n.t('gobierto_visualizations.visualizations.contracts.document_number') || '',
      labelContractingSystem: I18n.t('gobierto_visualizations.visualizations.contracts.contracting_system') || '',
      labelEstablishment: I18n.t('gobierto_visualizations.visualizations.contracts.establishment') || '',
      labelProcess: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.process') || '',
      labelType: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.type') || '',
      labelEstimatedValue: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.estimated_value') || '',
      filterContractsBatches: []
    }
  },
  computed: {
    // The route resolved to a contract. `contract` stays {} both on a tender page
    // and when the id matches nothing at all, and the blocks reading contract
    // fields must not render in either case.
    isContractDetail() {
      return !!this.contract.id
    },
    // Contracts sharing the effective tender: the lots of a multi-lot tender
    // (batch_number > 0) and the contracts derived from a framework agreement or
    // a dynamic acquisition system (batch_number = 0). Returns [] when there is
    // no tender key — sites still serving the old CSV would otherwise group the
    // whole dataset — and also when the contract only finds itself, so the table
    // never shows a single row repeating the detail above it.
    siblings() {
      const key = effectiveTenderId(this.contract)
      if (!key) return []

      const siblings = this.contractsData.filter(contract => effectiveTenderId(contract) === key)
      return siblings.length > 1 ? siblings : []
    },
    hasSiblings() {
      return this.siblings.length > 0
    },
    hasBatch() {
      return this.batch_number > 0
    },
    // A contract derived from a framework agreement or a dynamic acquisition
    // system (contracting system 3 or 4). It is an independent contract, not a lot
    // of the tender it hangs from, even when it carries a batch_number of its own.
    isDerived() {
      return !!this.contract.is_derived_contract
    },
    // The siblings are the lots of one same tender, parts of a single contract.
    // A derived contract is not one of them even when it carries a batch_number:
    // then it is a lot of its own derived tender, whose sibling lots cannot be
    // told apart because tender_id holds the establishment.
    hasLots() {
      return this.hasBatch && !this.isDerived
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
    showEstablishment() {
      return !this.isTenderDetail && !!this.establishment_document_number
    },
    establishmentValue() {
      return [this.establishment_document_number, this.establishment_title]
        .filter(Boolean)
        .join(' — ')
    },
    establishmentRoute() {
      return { name: 'contracts_show', params: { id: effectiveTenderId(this.contract) } }
    },
    // On a tender page a row is a contract with its own title and link, never a
    // lot number — also for a multi-lot tender, where each lot is a contract.
    tableMode() {
      return this.isTenderDetail ? 'derived' : 'batches'
    },
    // A contract only tables its siblings when they are the lots of its own
    // tender: they are parts of the same contract, awarded together. The contracts
    // derived from a framework agreement / dynamic acquisition system are siblings
    // too, but they are independent contracts with an awardee each, and listing
    // them here reads as if this contract had won fifty of them. They belong to
    // the establishment, one click away through showEstablishment.
    showSiblingsTable() {
      return this.isTenderDetail
        ? this.filterContractsBatches.length > 0
        : this.hasLots && this.hasSiblings
    },
    showAmount() {
      return this.isContractDetail || this.showSiblingsTable
    },
    siblingsAmount() {
      return this.filterContractsBatches.reduce((acc, { final_amount_no_taxes }) => acc + final_amount_no_taxes, 0)
    },
    // Only the lots of one same tender add up: they are parts of one contract.
    // Contracts derived from a framework agreement / dynamic acquisition system
    // are independent contracts with an amount of their own, and summing them as
    // "the contract amount" would be false.
    calculateFinalAmount() {
      if (this.isTenderDetail) return this.siblingsAmount

      return this.hasLots && this.filterContractsBatches.length
        ? this.siblingsAmount
        : this.final_amount_no_taxes
    }
  },
  created() {
    const itemId = this.$route.params.id;

    // Resolved by contract_id, the routing key of a contract. On sites still
    // serving the old CSV contractRoutingId falls back to `id`, so a contract
    // always answers first and the tender branch below is never reached: the
    // behaviour there is identical to the previous one.
    //
    // A handful of contract_ids collide with a tender id; the contract wins and
    // the tender stays in the shadow. Residual case, not addressed here.
    const contract = this.contractsData.find(row => contractRoutingId(row) === itemId)

    EventBus.$emit("refresh-active-tab");

    if (contract) {
      this.setupContractDetail(contract)
    } else {
      // No contract answers to that id, so it may be a tender id: typically the
      // establishment of a framework agreement / dynamic acquisition system, or a
      // multi-lot tender. Those URLs already existed — `id` holds the effective
      // tender — and used to land on whichever derived contract came first.
      const tender = (this.$root.$data.tendersData || []).find(({ id }) => id === itemId)
      if (tender) this.setupTenderDetail(tender)
    }
  },
  methods: {
    setupContractDetail(contract) {
      this.contract = contract

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
        estimated_value,
        document_number,
        contracting_system,
        establishment_title,
        establishment_document_number
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
      this.assignee_routing_id = assignee_routing_id
      this.contractor = contractor
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
      this.document_number = document_number || ''
      this.contracting_system = contracting_system || ''
      this.establishment_title = establishment_title || ''
      this.establishment_document_number = establishment_document_number || ''

      // Only the lots of one same tender are grouped here. A derived contract
      // keeps its own title — it names what was actually bought, while the
      // establishment names the system it was bought through — and its siblings
      // are listed on the establishment page, not on its own.
      if (this.hasLots && this.hasSiblings) {
        this.setTenderTitle()
        this.groupBatches()
      }
    },
    // The route resolved to a tender: the header must describe the tender, and the
    // table lists the contracts hanging from it. The fields not shared with a
    // contract are hidden in the template through isTenderDetail, because
    // `licitaciones` has no data for them.
    setupTenderDetail(tender) {
      this.isTenderDetail = true

      const {
        title,
        document_number,
        contracting_system,
        contractor,
        status,
        contract_type,
        process_type,
        category_title,
        submission_date,
        open_proposals_date,
        initial_amount_no_taxes,
        contract_value,
        number_of_batches
      } = tender

      // tendersData arrives already translated (contracting_system, contract_type,
      // process_type, status, category_title), so nothing is translated again here.
      this.title = title
      this.document_number = document_number || ''
      this.contracting_system = contracting_system || ''
      this.contractor = contractor
      this.status = status
      this.contract_type = contract_type
      this.process_type = process_type
      this.category_title = category_title
      this.submission_date = submission_date || null
      this.open_proposals_date = open_proposals_date || null
      this.initial_amount_no_taxes = initial_amount_no_taxes
      this.estimated_value = +contract_value
      this.number_of_batches = number_of_batches

      this.filterContractsBatches = this.contractsData
        .filter(contract => effectiveTenderId(contract) === tender.id)
    },
    groupBatches() {
      // siblings is a computed property and sort mutates in place: copy first.
      this.filterContractsBatches = [...this.siblings].sort((a, b) => a.batch_number - b.batch_number);
    },
    setTenderTitle() {
      // Each lot of a multi-lot tender carries its own lot-specific title, but the
      // detail header should show the tender title, read from the tenders dataset
      // through the effective tender of the contract.
      const key = effectiveTenderId(this.contract)
      if (!key) return

      const tendersData = this.$root.$data.tendersData || []
      const tender = tendersData.find(({ id }) => id === key)
      if (tender && tender.title) this.title = tender.title
    }
  }
}
</script>
