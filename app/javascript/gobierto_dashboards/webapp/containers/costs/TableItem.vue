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
          :to="{ path:`/dashboards/costes/${$route.params.section}`}"
          class="gobierto-dashboards-table-header--link-top"
          tag="a"
        >
          {{ $route.params.section }}
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
            {{ dataGroup[0].descripcio }}
          </span>
        </div>
        <div class="gobierto-dashboards-table-item-left-container">
          <span class="gobierto-dashboards-table-item-title">
            {{ labelCompetence }}
          </span>
          <span class="gobierto-dashboards-table-item-text">
            {{ dataGroup[0].competencia }}
          </span>
        </div>
        <div class="gobierto-dashboards-table-item-left-container">
          <span class="gobierto-dashboards-table-item-title">
            {{ labelTypes }}
          </span>
          <span class="gobierto-dashboards-table-item-text">
            {{ dataGroup[0].tipus_competencia }}
          </span>
        </div>
        <div class="gobierto-dashboards-table-item-left-container">
          <span class="gobierto-dashboards-table-item-title">
            {{ labelLegalFramework }}
          </span>
          <span class="gobierto-dashboards-table-item-text">
            {{ dataGroup[0].marc_legal }}
          </span>
        </div>
      </div>

      <div class="gobierto-dashboards-table-item-right">

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
  created() {
    this.agrupacioData(this.$route.params.id)
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
        ingressos: income
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
    }
  }
}
</script>
