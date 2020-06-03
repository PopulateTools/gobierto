<template>
  <div v-if="items.length">
    <TableHeader>
      <div class="gobierto-dashboards-table-header--link-container">
        <router-link
          :to="{ name: 'Home'}"
          class="gobierto-dashboards-table-header--link-top"
          tag="a"
        >
          Inicio
        </router-link>
        <i class="fas fa-chevron-right"/>
        <router-link
          :to="{ path:`/dashboards/costes/${$route.params.id}`}"
          class="gobierto-dashboards-table-header--link-top"
          tag="a"
        >
          {{ $route.params.id }}
        </router-link>
      </div>
    </TableHeader>
    <div v-if="items.length">
      <div
        v-for="{ agrupacio, nomact, cost_directe_2018, cost_indirecte_2018, cost_total_2018, cost_per_habitant, ingressos, respecte_ambit } in dataGroup"
        :key="nomact"
        class="gobierto-dashboards-table--header gobierto-dashboards-tablesecondlevel--header"
      >
        <div class="gobierto-dashboards-table-header--nav">
          {{ nomact }}
        </div>
        <div class="gobierto-dashboards-table-header--elements gobierto-dashboards-table-color-direct">
          <span>{{ cost_directe_2018 | money }}</span>
        </div>
        <div class="gobierto-dashboards-table-header--elements gobierto-dashboards-table-color-indirect">
          <span>{{ cost_indirecte_2018 | money }}</span>
        </div>
        <div class="gobierto-dashboards-table-header--elements gobierto-dashboards-table-color-total">
          <span>{{ cost_total_2018 | money }}</span>
        </div>
        <div class="gobierto-dashboards-table-header--elements gobierto-dashboards-table-color-inhabitant">
          <span>{{ cost_per_habitant | money }}</span>
        </div>
        <div class="gobierto-dashboards-table-header--elements gobierto-dashboards-table-color-income">
          <span>{{ ingressos | money }}</span>
        </div>
        <div class="gobierto-dashboards-table-header--elements">
          <span>{{ (respecte_ambit).toFixed(0) }}%</span>
        </div>
      </div>
    </div>
    <div class="gobierto-dashboards-table-item">
      <div class="gobierto-dashboards-table-item-left">
        <div class="gobierto-dashboards-table-item-left-container">
          <span class="gobierto-dashboards-table-item-title">
            {{ labelDescription }}
          </span>
          <span class="gobierto-dashboards-table-item-text">
            {{ description }}
          </span>
        </div>
        <div class="gobierto-dashboards-table-item-left-container">
          <span class="gobierto-dashboards-table-item-title">
            {{ labelCompetence }}
          </span>
          <span class="gobierto-dashboards-table-item-text">
            {{ competence }}
          </span>
        </div>
        <div class="gobierto-dashboards-table-item-left-container">
          <span class="gobierto-dashboards-table-item-title">
            {{ labelTypes }}
          </span>
          <span class="gobierto-dashboards-table-item-text">
            {{ types }}
          </span>
        </div>
        <div class="gobierto-dashboards-table-item-left-container">
          <span class="gobierto-dashboards-table-item-title">
            {{ labelLegalFramework }}
          </span>
          <span class="gobierto-dashboards-table-item-text">
            {{ legal }}
          </span>
        </div>
      </div>

      <div class="gobierto-dashboards-table-item-right">
        <div class="gobierto-dashboards-table-item-right-container">
          <div class="gobierto-dashboards-table-item-right-section">
            <span class="gobierto-dashboards-table-item-right-section-title">
              {{ labelCosts }}
            </span>
          </div>
          <div class="gobierto-dashboards-table-item-right-table">
            <div class="gobierto-dashboards-table-item-right-table-element">
              <span class="gobierto-dashboards-table-item-right-table-text">
                {{ labelPersonalCost }}
              </span>
              <span class="gobierto-dashboards-table-item-right-table-amount">
                {{ costPersonal | money }}
              </span>
            </div>
            <div class="gobierto-dashboards-table-item-right-table-element">
              <span class="gobierto-dashboards-table-item-right-table-text">
                {{ labelGoodsServices }}
              </span>
              <span class="gobierto-dashboards-table-item-right-table-amount">
                {{ goodServices | money }}
              </span>
            </div>
            <div class="gobierto-dashboards-table-item-right-table-element">
              <span class="gobierto-dashboards-table-item-right-table-text">
                {{ labelExternalServices }}
              </span>
              <span class="gobierto-dashboards-table-item-right-table-amount">
                {{ externalServices | money  }}
              </span>
            </div>
            <div class="gobierto-dashboards-table-item-right-table-element">
              <span class="gobierto-dashboards-table-item-right-table-text">
                {{ labelTransference }}
              </span>
              <span class="gobierto-dashboards-table-item-right-table-amount">
                {{ transferences | money  }}
              </span>
            </div>
            <div class="gobierto-dashboards-table-item-right-table-element">
              <span class="gobierto-dashboards-table-item-right-table-text">
                {{ labelEquipments }}
              </span>
              <span class="gobierto-dashboards-table-item-right-table-amount">
                {{ equiptments | money  }}
              </span>
            </div>
            <div class="gobierto-dashboards-table-item-right-table-element gobierto-dashboards-table-item-right-table-element-bold">
              <span class="gobierto-dashboards-table-item-right-table-text">
                {{ labelTotal }}
              </span>
              <span class="gobierto-dashboards-table-item-right-table-amount">
                {{ totalCost | money }}
              </span>
            </div>
          </div>
        </div>
        <div class="gobierto-dashboards-table-item-right-container gobierto-dashboards-table-item-right-container-income">
          <div class="gobierto-dashboards-table-item-right-section">
            <span class="gobierto-dashboards-table-item-right-section-title">
              {{ labelIncome }}
            </span>
          </div>
          <div class="gobierto-dashboards-table-item-right-table">
            <div class="gobierto-dashboards-table-item-right-table-element">
              <span class="gobierto-dashboards-table-item-right-table-text">
                {{ labelPublicTax }}
              </span>
              <span class="gobierto-dashboards-table-item-right-table-amount">
                {{ taxs | money  }}
              </span>
            </div>
            <div class="gobierto-dashboards-table-item-right-table-element">
              <span class="gobierto-dashboards-table-item-right-table-text">
                {{ labelSubsidies }}
              </span>
              <span class="gobierto-dashboards-table-item-right-table-amount">
                {{ subsidies | money  }}
              </span>
            </div>
            <div class="gobierto-dashboards-table-item-right-table-element gobierto-dashboards-table-item-right-table-element-bold">
              <span class="gobierto-dashboards-table-item-right-table-text">
                {{ labelTotal }}
              </span>
              <span class="gobierto-dashboards-table-item-right-table-amount">
                {{ totalIncomes | money }}
              </span>
            </div>
          </div>
        </div>
        <div class="gobierto-dashboards-table-item-right-container gobierto-dashboards-table-item-right-container-coverage">
          <div class="gobierto-dashboards-table-item-right-section">
            <span class="gobierto-dashboards-table-item-right-section-title">
              {{ labelCoverage }}
            </span>
          </div>
          <div class="gobierto-dashboards-table-item-right-table">
            <div class="gobierto-dashboards-table-item-right-table-element gobierto-dashboards-table-item-right-table-element-bold">
              <span class="gobierto-dashboards-table-item-right-table-text">
                {{ labelIncomeCost }}
              </span>
              <span class="gobierto-dashboards-table-item-right-table-amount">
                {{ incomeCost | money  }}
              </span>
            </div>
            <div class="gobierto-dashboards-table-item-right-table-element">
              <span class="gobierto-dashboards-table-item-right-table-text">
                % {{ labelCoverage }}
              </span>
              <span class="gobierto-dashboards-table-item-right-table-amount">
                {{ coverage }}%
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
<script>
import TableHeader from './TableHeader.vue'
import { VueFiltersMixin } from "lib/shared"
export default {
  name: "TableItem",
  mixins: [VueFiltersMixin],
  components: {
    TableHeader
  },
  data() {
    return {
      items: this.$root.$data.costData,
      dataGroup: [],
      labelCompetence: I18n.t("gobierto_dashboards.dashboards.costs.item.competence") || "",
      labelDescription: I18n.t("gobierto_dashboards.dashboards.costs.item.description") || "",
      labelPersonalCost: I18n.t("gobierto_dashboards.dashboards.costs.item.personal_cost") || "",
      labelTypes: I18n.t("gobierto_dashboards.dashboards.costs.item.types") || "",
      labelLegalFramework: I18n.t("gobierto_dashboards.dashboards.costs.item.legal_framework") || "",
      labelGoodsServices: I18n.t("gobierto_dashboards.dashboards.costs.item.goods_and_services") || "",
      labelExternalServices: I18n.t("gobierto_dashboards.dashboards.costs.item.external_services") || "",
      labelTransference: I18n.t("gobierto_dashboards.dashboards.costs.item.transference") || "",
      labelEquipments: I18n.t("gobierto_dashboards.dashboards.costs.item.equipments") || "",
      labelTotal: I18n.t("gobierto_dashboards.dashboards.costs.item.total") || "",
      labelSubsidies: I18n.t("gobierto_dashboards.dashboards.costs.item.subsidies") || "",
      labelIncomeCost: I18n.t("gobierto_dashboards.dashboards.costs.item.income_cost") || "",
      labelPublicTax: I18n.t("gobierto_dashboards.dashboards.costs.item.public_tax") || "",
      labelCoverage: I18n.t("gobierto_dashboards.dashboards.costs.coverage") || "",
      labelIncome: I18n.t("gobierto_dashboards.dashboards.costs.income") || "",
      labelCosts: I18n.t("gobierto_dashboards.layouts.application.gobierto_dashboards.costs") || "",
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
      income: ''
    }
  },
  computed: {
    totalCost() {
      return this.equiptments + this.transferences + this.externalServices + this.goodServices + this.costPersonal
    },
    totalIncomes() {
      return this.taxs + this.subsidies
    }
  },
  created() {
    this.agrupacioData(this.$route.params.item)
  },
  methods: {
    agrupacioData(id) {
      this.dataGroup = this.items.filter(element => element.codiact === id)

      const [{
        descripcio: description,
        competencia: competence,
        tipus_competencia: types,
        marc_legal: legal,
        cd_cost_personal: costPersonal,
        cd_bens_i_serveis: goodServices,
        cd_serveis_exteriors: externalServices,
        cd_transferencies: transferences,
        cd_equipaments: equiptments,
        taxa_o_preu_public: taxs,
        subvencio: subsidies,
        ingres_cost: incomeCost,
        ingressos: income,
        respecte_ambit: coverage
      }] = this.dataGroup

      this.description = description
      this.competence = competence
      this.types = types
      this.legal = legal
      this.costPersonal = costPersonal
      this.goodServices = goodServices
      this.externalServices = externalServices
      this.transferences = transferences
      this.equiptments = equiptments || 0
      this.taxs = taxs || 0
      this.subsidies = subsidies || 0
      this.incomeCost = incomeCost
      this.income = income || 0
      this.coverage = coverage
    }
  }
}
</script>
