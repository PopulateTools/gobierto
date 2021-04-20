<template>
  <div class="pure-u-1 pure-u-lg-1-1">
    <div class="pure-u-1 pure-u-lg-1-2">
      <span class="visualizations-contracts-show__text__header">{{ labelQuestionDescription }}</span>
      <table class="visualizations-contracts-show-table">
        <ContractsShowTableFooterTr
          :label="labelEntity"
          :value="calculatePercentage('contractor')"
        />
        <ContractsShowTableFooterTr
          :label="labelType"
          :value="calculatePercentage('contract_type')"
        />
        <ContractsShowTableFooterTr
          :label="labelProcess"
          :value="calculatePercentage('process_type')"
        />
      </table>
    </div>
    <div
      v-if="showPermalink"
      class="visualizations-contracts-show__footer_link"
    >
      <a :href="permalink">
        <i
          class="fas fa-external-link-alt"
          style="color: var(--color-base);"
        />
        {{ labelLink }}
      </a>
    </div>
  </div>
</template>
<script>

import ContractsShowTableFooterTr from "./ContractsShowTableFooterTr.vue";
export default {
  name: 'ContractsShowTableFooter',
  components: {
    ContractsShowTableFooterTr
  },
  props: {
    data: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      contractsData: this.$root.$data.contractsData,
      contractor: '',
      contract_type: '',
      process_type: '',
      final_amount_no_taxes: '',
      permalink: '',
      labelProcess: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.process') || '',
      labelEntity: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.entity') || '',
      labelType: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.type') || '',
      labelQuestionDescription: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.question_description') || '',
      labelLink: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_show.external_source') || '',
    }
  },
  computed: {
    showPermalink() {
      return !this.permalink.includes('.gobierto.es')
    }
  },
  created() {
    const {
      contractor,
      contract_type,
      process_type,
      final_amount_no_taxes,
      permalink
    } = this.data

    this.contractor = contractor
    this.contract_type = contract_type
    this.process_type = process_type
    this.final_amount_no_taxes = final_amount_no_taxes
    this.permalink = permalink
  },
  methods: {
    calculatePercentage(value) {
      const filterByContractor = this.contractsData.filter((contract) => contract[value] === this[value])
      const totalAmount = filterByContractor.reduce((acc, { final_amount_no_taxes } ) => acc + final_amount_no_taxes, 0)
      return totalAmount ? ((this.final_amount_no_taxes * 100) / totalAmount).toFixed(2) : 0
    },
  }
}
</script>
