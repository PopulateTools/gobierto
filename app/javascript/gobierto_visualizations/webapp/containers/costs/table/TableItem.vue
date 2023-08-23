<template>
  <div v-if="items.length">
    <TableHeader>
      <div class="gobierto-visualizations-table-header--link-container">
        <router-link
          :to="{ path:`/visualizaciones/costes/${$route.params.year}`}"
          class="gobierto-visualizations-table-header--link-top"
          tag="a"
          @click.native="loadTable(0)"
        >
          {{ labelHome }}
        </router-link>
        <i class="fas fa-chevron-right" />
        <router-link
          :to="{ path:`/visualizaciones/costes/${$route.params.year}/${$route.params.id}`}"
          class="gobierto-visualizations-table-header--link-top"
          tag="a"
          @click.native="loadTable(1)"
        >
          {{ agrupacioID }}
        </router-link>
      </div>
    </TableHeader>
    <TableRow
      :items="dataGroup"
      :table-item="showTableHeader"
    />
    <div class="gobierto-visualizations-table-item">
      <div class="gobierto-visualizations-table-item-left">
        <div class="gobierto-visualizations-table-item-left-container">
          <span class="gobierto-visualizations-table-item-title">
            {{ labelDescription }}
          </span>
          <span class="gobierto-visualizations-table-item-text">
            {{ description }}
          </span>
        </div>
        <div class="gobierto-visualizations-table-item-left-container">
          <span class="gobierto-visualizations-table-item-title">
            {{ labelCompetence }}
          </span>
          <span class="gobierto-visualizations-table-item-text">
            {{ competence }}
          </span>
        </div>
        <div class="gobierto-visualizations-table-item-left-container">
          <span class="gobierto-visualizations-table-item-title">
            {{ labelTypes }}
          </span>
          <span class="gobierto-visualizations-table-item-text">
            {{ types }}
          </span>
        </div>
        <div class="gobierto-visualizations-table-item-left-container">
          <span class="gobierto-visualizations-table-item-title">
            {{ labelLegalFramework }}
          </span>
          <span class="gobierto-visualizations-table-item-text">
            {{ legal }}
          </span>
        </div>
      </div>

      <div class="gobierto-visualizations-table-item-right">
        <div class="gobierto-visualizations-table-item-right-container">
          <div class="gobierto-visualizations-table-item-right-section">
            <span class="gobierto-visualizations-table-item-right-section-title">
              {{ labelCosts }}
            </span>
          </div>
          <div class="gobierto-visualizations-table-item-right-table">
            <div class="gobierto-visualizations-table-item-right-table-element">
              <div class="gobierto-visualizations-table-item-right-table-container">
                <span class="gobierto-visualizations-table-item-right-table-text">
                  {{ labelPersonalCost }}
                </span>
                <span class="gobierto-visualizations-table-item-right-table-amount">
                  {{ costPersonal | money }}
                </span>
              </div>
              <i
                class="far fa-question-circle"
                style="color: var(--color-base); cursor: pointer;"
                @mouseover="showTooltipItem = labelPersonalCost"
                @mouseleave="showTooltipItem = null"
              >
                <div
                  v-show="showTooltipItem === labelPersonalCost"
                  class="gobierto-visualizations-item--tooltip"
                >
                  {{ tooltipTextStaffCost }}
                </div>
              </i>
            </div>
            <div class="gobierto-visualizations-table-item-right-table-element">
              <div class="gobierto-visualizations-table-item-right-table-container">
                <span class="gobierto-visualizations-table-item-right-table-text">
                  {{ labelGoodsServices }}
                </span>
                <span class="gobierto-visualizations-table-item-right-table-amount">
                  {{ goodServices | money }}
                </span>
              </div>
              <i
                class="far fa-question-circle"
                style="color: var(--color-base); cursor: pointer;"
                @mouseover="showTooltipItem = labelGoodsServices"
                @mouseleave="showTooltipItem = null"
              >
                <div
                  v-show="showTooltipItem === labelGoodsServices"
                  class="gobierto-visualizations-item--tooltip"
                >
                  {{ tooltipTextGoodServices }}
                </div>
              </i>
            </div>
            <div class="gobierto-visualizations-table-item-right-table-element">
              <div class="gobierto-visualizations-table-item-right-table-container">
                <span class="gobierto-visualizations-table-item-right-table-text">
                  {{ labelExternalServices }}
                </span>
                <span class="gobierto-visualizations-table-item-right-table-amount">
                  {{ externalServices | money }}
                </span>
              </div>
              <i
                class="far fa-question-circle"
                style="color: var(--color-base); cursor: pointer;"
                @mouseover="showTooltipItem = labelExternalServices"
                @mouseleave="showTooltipItem = null"
              >
                <div
                  v-show="showTooltipItem === labelExternalServices"
                  class="gobierto-visualizations-item--tooltip"
                >
                  {{ tooltipTextExternalServices }}
                </div>
              </i>
            </div>
            <div class="gobierto-visualizations-table-item-right-table-element">
              <div class="gobierto-visualizations-table-item-right-table-container">
                <span class="gobierto-visualizations-table-item-right-table-text">
                  {{ labelTransference }}
                </span>
                <span class="gobierto-visualizations-table-item-right-table-amount">
                  {{ transferences | money }}
                </span>
              </div>
              <i
                class="far fa-question-circle"
                style="color: var(--color-base); cursor: pointer;"
                @mouseover="showTooltipItem = labelTransference"
                @mouseleave="showTooltipItem = null"
              >
                <div
                  v-show="showTooltipItem === labelTransference"
                  class="gobierto-visualizations-item--tooltip"
                >
                  {{ tooltipTextTransferences }}
                </div>
              </i>
            </div>
            <div class="gobierto-visualizations-table-item-right-table-element">
              <div class="gobierto-visualizations-table-item-right-table-container">
                <span class="gobierto-visualizations-table-item-right-table-text">
                  {{ labelEquipments }}
                </span>
                <span class="gobierto-visualizations-table-item-right-table-amount">
                  {{ equiptments | money }}
                </span>
              </div>
              <i
                class="far fa-question-circle"
                style="color: var(--color-base); cursor: pointer;"
                @mouseover="showTooltipItem = labelEquipments"
                @mouseleave="showTooltipItem = null"
              >
                <div
                  v-show="showTooltipItem === labelEquipments"
                  class="gobierto-visualizations-item--tooltip"
                >
                  {{ tooltipTextEquipments }}
                </div>
              </i>
            </div>
            <div class="gobierto-visualizations-table-item-right-table-element">
              <div class="gobierto-visualizations-table-item-right-table-container">
                <span class="gobierto-visualizations-table-item-right-table-text">
                  {{ labelCostIndirect }}
                </span>
                <span class="gobierto-visualizations-table-item-right-table-amount">
                  {{ costIndirect | money }}
                </span>
              </div>
              <i
                class="far fa-question-circle"
                style="color: var(--color-base); cursor: pointer;"
                @mouseover="showTooltipItem = labelCostIndirect"
                @mouseleave="showTooltipItem = null"
              >
                <div
                  v-show="showTooltipItem === labelCostIndirect"
                  class="gobierto-visualizations-item--tooltip"
                >
                  {{ tooltipTextCostIndirect }}
                </div>
              </i>
            </div>
            <div class="gobierto-visualizations-table-item-right-table-element gobierto-visualizations-table-item-right-table-element-bold">
              <div class="gobierto-visualizations-table-item-right-table-container">
                <span class="gobierto-visualizations-table-item-right-table-text">
                  {{ labelTotal }}
                </span>
                <span class="gobierto-visualizations-table-item-right-table-amount">
                  {{ costTotal | money }}
                </span>
              </div>
            </div>
          </div>
        </div>
        <div class="gobierto-visualizations-table-item-right-container gobierto-visualizations-table-item-right-container-income">
          <div class="gobierto-visualizations-table-item-right-section">
            <span class="gobierto-visualizations-table-item-right-section-title">
              {{ labelIncome }}
            </span>
          </div>
          <div class="gobierto-visualizations-table-item-right-table">
            <div class="gobierto-visualizations-table-item-right-table-element">
              <div class="gobierto-visualizations-table-item-right-table-container">
                <span class="gobierto-visualizations-table-item-right-table-text">
                  {{ labelPublicTax }}
                </span>
                <span class="gobierto-visualizations-table-item-right-table-amount">
                  {{ calculateTax | money }}
                </span>
              </div>
              <i
                class="far fa-question-circle"
                style="color: var(--color-base); cursor: pointer;"
                @mouseover="showTooltipItem = labelPublicTax"
                @mouseleave="showTooltipItem = null"
              >
                <div
                  v-show="showTooltipItem === labelPublicTax"
                  class="gobierto-visualizations-item--tooltip"
                >
                  {{ tooltipTextTaxes }}
                </div>
              </i>
            </div>
            <div class="gobierto-visualizations-table-item-right-table-element">
              <div class="gobierto-visualizations-table-item-right-table-container">
                <span class="gobierto-visualizations-table-item-right-table-text">
                  {{ labelSubsidies }}
                </span>
                <span class="gobierto-visualizations-table-item-right-table-amount">
                  {{ subsidies | money }}
                </span>
              </div>
            </div>
            <div class="gobierto-visualizations-table-item-right-table-element gobierto-visualizations-table-item-right-table-element-bold">
              <div class="gobierto-visualizations-table-item-right-table-container">
                <span class="gobierto-visualizations-table-item-right-table-text">
                  {{ labelTotalIncome }}
                </span>
                <span class="gobierto-visualizations-table-item-right-table-amount">
                  {{ income | money }}
                </span>
              </div>
              <i
                class="far fa-question-circle"
                style="color: var(--color-base); cursor: pointer;"
                @mouseover="showTooltipItem = labelSubsidies"
                @mouseleave="showTooltipItem = null"
              >
                <div
                  v-show="showTooltipItem === labelSubsidies"
                  class="gobierto-visualizations-item--tooltip"
                >
                  {{ tooltipTextSubvencions }}
                </div>
              </i>
            </div>
          </div>
        </div>
        <div class="gobierto-visualizations-table-item-right-container gobierto-visualizations-table-item-right-container-coverage">
          <div class="gobierto-visualizations-table-item-right-section">
            <span class="gobierto-visualizations-table-item-right-section-title">
              {{ labelCoverage }}
            </span>
          </div>
          <div class="gobierto-visualizations-table-item-right-table">
            <div class="gobierto-visualizations-table-item-right-table-element gobierto-visualizations-table-item-right-table-element-bold">
              <div class="gobierto-visualizations-table-item-right-table-container">
                <span class="gobierto-visualizations-table-item-right-table-text">
                  {{ labelIncomeCost }}
                </span>
                <span class="gobierto-visualizations-table-item-right-table-amount">
                  {{ incomeCost | money }}
                </span>
              </div>
              <i
                class="far fa-question-circle"
                style="color: var(--color-base); cursor: pointer;"
                @mouseover="showTooltipItem = labelIncomeCost"
                @mouseleave="showTooltipItem = null"
              >
                <div
                  v-show="showTooltipItem === labelIncomeCost"
                  class="gobierto-visualizations-item--tooltip"
                >
                  {{ tooltipTextIncomeCost }}
                </div>
              </i>
            </div>
            <div class="gobierto-visualizations-table-item-right-table-element">
              <div class="gobierto-visualizations-table-item-right-table-container">
                <span class="gobierto-visualizations-table-item-right-table-text">
                  % {{ labelCoverage }}
                </span>
                <span class="gobierto-visualizations-table-item-right-table-amount">
                  {{ coverage.toFixed(0) }}%
                </span>
              </div>
              <i
                class="far fa-question-circle"
                style="color: var(--color-base); cursor: pointer;"
                @mouseover="showTooltipItem = labelCoverage"
                @mouseleave="showTooltipItem = null"
              >
                <div
                  v-show="showTooltipItem === labelCoverage"
                  class="gobierto-visualizations-item--tooltip"
                >
                  {{ tooltipTextCoverage }}
                </div>
              </i>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
<script>
import TableHeader from './TableHeader.vue'
import TableRow from './TableRow.vue'
import { VueFiltersMixin } from "lib/vue/filters"

export default {
  name: "TableItem",
  components: {
    TableHeader,
    TableRow
  },
  mixins: [VueFiltersMixin],
  props: {
    year: {
      type: String,
      default: ''
    }
  },
  data() {
    return {
      items: this.$root.$data.costData,
      dataGroup: [],
      labelCostInhabitant: I18n.t("gobierto_visualizations.visualizations.costs.cost_inhabitant") || "",
      labelCostTotal: I18n.t("gobierto_visualizations.visualizations.costs.total") || "",
      labelCostDirect: I18n.t("gobierto_visualizations.visualizations.costs.cost_direct") || "",
      labelCompetence: I18n.t("gobierto_visualizations.visualizations.costs.item.competence") || "",
      labelDescription: I18n.t("gobierto_visualizations.visualizations.costs.item.description") || "",
      labelPersonalCost: I18n.t("gobierto_visualizations.visualizations.costs.item.personal_cost") || "",
      labelTypes: I18n.t("gobierto_visualizations.visualizations.costs.item.types") || "",
      labelLegalFramework: I18n.t("gobierto_visualizations.visualizations.costs.item.legal_framework") || "",
      labelGoodsServices: I18n.t("gobierto_visualizations.visualizations.costs.item.goods_and_services") || "",
      labelExternalServices: I18n.t("gobierto_visualizations.visualizations.costs.item.external_services") || "",
      labelTransference: I18n.t("gobierto_visualizations.visualizations.costs.item.transference") || "",
      labelEquipments: I18n.t("gobierto_visualizations.visualizations.costs.item.equipments") || "",
      labelTotal: I18n.t("gobierto_visualizations.visualizations.costs.item.total") || "",
      labelTotalIncome: I18n.t("gobierto_visualizations.visualizations.costs.item.total") || "",
      labelSubsidies: I18n.t("gobierto_visualizations.visualizations.costs.item.subsidies") || "",
      labelIncomeCost: I18n.t("gobierto_visualizations.visualizations.costs.item.income_cost") || "",
      labelPublicTax: I18n.t("gobierto_visualizations.visualizations.costs.item.public_tax") || "",
      labelCoverage: I18n.t("gobierto_visualizations.visualizations.costs.coverage") || "",
      labelIncome: I18n.t("gobierto_visualizations.visualizations.costs.income") || "",
      labelCosts: I18n.t("gobierto_visualizations.layouts.application.gobierto_visualizations.costs") || "",
      labelHome : I18n.t("gobierto_visualizations.visualizations.costs.home") || "",
      labelCostIndirect : I18n.t("gobierto_visualizations.visualizations.costs.cost_indirect") || "",
      description: '',
      competence: '',
      types: '',
      legal: '',
      costPersonal: '',
      goodServices: '',
      externalServices: '',
      transferences: '',
      equiptments: '',
      taxs: '',
      subsidies: '',
      incomeCost: '',
      agrupacioID: '',
      costIndirect: '',
      income: '',
      costTotal: '',
      showTooltipItem: null,
      showTableHeader: true,
      tooltipTextStaffCost: I18n.t("gobierto_visualizations.visualizations.costs.tooltips_items.staff_cost") || "",
      tooltipTextGoodServices: I18n.t("gobierto_visualizations.visualizations.costs.tooltips_items.goodsServices") || "",tooltipTextExternalServices: I18n.t("gobierto_visualizations.visualizations.costs.tooltips_items.externalServices") || "",tooltipTextTransferences: I18n.t("gobierto_visualizations.visualizations.costs.tooltips_items.transferences") || "",tooltipTextEquipments: I18n.t("gobierto_visualizations.visualizations.costs.tooltips_items.equipments") || "",tooltipTextCostIndirect: I18n.t("gobierto_visualizations.visualizations.costs.tooltips_items.cost_indirect") || "",tooltipTextTaxes: I18n.t("gobierto_visualizations.visualizations.costs.tooltips_items.taxes") || "",
      tooltipTextSubvencions: I18n.t("gobierto_visualizations.visualizations.costs.tooltips_items.subsidies") || "",
      tooltipTextIncomeCost: I18n.t("gobierto_visualizations.visualizations.costs.tooltips_items.income_cost") || "",
      tooltipTextCoverage: I18n.t("gobierto_visualizations.visualizations.costs.tooltips_items.coverage") || "",
    }
  },
  computed: {
    /*
    Calculate the taxapreub because the 2022 data doesn't contain the taxapreub,
    so we need to calculate it with (this.income - this.subsidies).
    What is this this.codiAct !== "44111001"??? is an exception
    la actividad 44111001 dónde este año hemos incorporado los ingresos
    de la concesionaria y no corresponden a ninguna de las dos columnas(ingressos or subsidies).
    */
    calculateTax() {
      return this.taxs === 0 && this.codiAct !== "44111001" ? this.income - this.subsidies : this.taxs
    }
  },
  created() {
    this.agrupacioData(this.$route.params.item)
  },
  mounted() {
    const el = this.$el.getElementsByClassName('gobierto-visualizations-table-header--nav')[0];
    if (el) {
      el.scrollIntoView({ behavior: "smooth" });
    }
  },
  methods: {
    agrupacioData(id) {
      const yearFiltered = this.year
      this.dataGroup = this.items.filter(element => element.codiact === id && element.any_ === yearFiltered)

      const [{
        descripcio: description,
        competencia: competence,
        tipus: types,
        marclegal: legal,
        costindirecte: costIndirect,
        costdirectepers: costPersonal,
        costdirebens: goodServices,
        costdirservext: externalServices,
        costdirtransf: transferences,
        costdirequip: equiptments,
        taxapreupub: taxs,
        subvencions: subsidies,
        ingressos_cost: incomeCost,
        ingressos: income,
        agrupacio: agrupacio,
        costtotal: costTotal,
        codiact: codiAct
      }] = this.dataGroup

      this.description = description
      this.competence = competence
      this.types = types
      this.legal = legal
      this.costPersonal = costPersonal
      this.costIndirect = costIndirect
      this.goodServices = goodServices
      this.externalServices = externalServices
      this.transferences = transferences
      this.equiptments = equiptments || 0
      this.taxs = taxs || 0
      this.subsidies = subsidies || 0
      this.incomeCost = incomeCost
      this.income = income || 0
      this.agrupacioID = agrupacio
      this.costTotal = costTotal
      this.coverage = (income * 100) / costTotal
      this.codiAct = codiAct
    },
    loadTable(value) {
      this.$emit('changeTableHandler', value)
    }
  }
}
</script>
