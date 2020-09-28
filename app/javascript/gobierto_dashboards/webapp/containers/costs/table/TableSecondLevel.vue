<template>
  <div>
    <TableHeader>
      <router-link
        :to="{ path:`/dashboards/costes/${$route.params.year}`}"
        class="gobierto-dashboards-table-header--link-top"
        tag="a"
        @click.native="loadTable(0)"
      >
        <i class="fas fa-chevron-left" />
        {{ labelSeeAll }}
      </router-link>
    </TableHeader>
    <TableSubHeader :items="itemsFilter" />
    <TableRow
      :items="dataActIntermediaTotal"
      :sub-items="dataGroupIntermedia"
      :total-items="totalElements"
      :table-header="showTableHeader"
      @filterChildren="agrupacioDataFilter"
      @loadTable="loadTable"
    />
  </div>
</template>
<script>
import TableHeader from './TableHeader.vue'
import TableRow from './TableRow.vue'
import TableSubHeader from './TableSubHeader.vue'
import { VueFiltersMixin } from "lib/shared"

export default {
  name: "TableSecondLevel",
  components: {
    TableHeader,
    TableSubHeader,
    TableRow
  },
  mixins: [VueFiltersMixin],
  props: {
    items: {
      type: Array,
      default: () => []
    },
    itemsFilter: {
      type: Array,
      default: () => []
    },
    year: {
      type: String,
      default: ''
    }
  },
  data() {
    return {
      labelTotal: I18n.t("gobierto_dashboards.dashboards.costs.total") || "",
      labelCostPerInhabitant: I18n.t("gobierto_dashboards.dashboards.costs.cost_per_inhabitant") || "",
      labelCostDirect: I18n.t("gobierto_dashboards.dashboards.costs.cost_direct") || "",
      labelCostIndirect: I18n.t("gobierto_dashboards.dashboards.costs.cost_indirect") || "",
      labelCostInhabitant: I18n.t("gobierto_dashboards.dashboards.costs.cost_inhabitant") || "",
      labelCostTotal: I18n.t("gobierto_dashboards.dashboards.costs.total") || "",
      labelIncome: I18n.t("gobierto_dashboards.dashboards.costs.income") || "",
      labelCoverage: I18n.t("gobierto_dashboards.dashboards.costs.coverage") || "",
      labelActivities: I18n.t("gobierto_dashboards.dashboards.costs.activities") || "",
      labelSeeAll: I18n.t("gobierto_dashboards.dashboards.costs.see_all") || "",
      dataActIntermediaTotal: [],
      dataGroupIntermedia: [],
      totalElements: null,
      showTableHeader: false,
      actIntermediaValue: ''
    }
  },
  watch: {
    $route(to) {
      if (to.name === 'TableSecondLevel') {
        this.intermediaData()
      }
    }
  },
  created() {
    this.intermediaData()
  },
  mounted() {
    const el = this.$el.getElementsByClassName('gobierto-dashboards-table-header--nav')[0];
    if (el) {
      el.scrollIntoView({ behavior: "smooth" });
    }
  },
  methods: {
    intermediaData() {
      const filterActIntermedia = this.$route.params.id
      let dataAgrupacio = this.items.filter(element => element.ordre_agrupacio === filterActIntermedia)
      let dataActIntermedia = dataAgrupacio.filter(element => element.act_intermitja !== '')
      let dataActIntermediaValues = [...dataActIntermedia.reduce((r, o) => {
        let key = o.act_intermitja

        const item = r.get(key) || Object.assign({}, o, {
          cost_directe: 0,
          cost_indirecte: 0,
          cost_total: 0,
          ingressos: 0,
          total: 0,
          nomact: '',
          totalPerHabitant: 0
        });

        item.cost_directe += o.cost_directe
        item.cost_indirecte += o.cost_indirecte
        item.cost_total += o.cost_total
        item.ingressos += o.ingressos
        item.total += (o.total || 0) + 1
        item.nomact = o.act_intermitja
        item.totalPerHabitant = item.cost_total / o.population

        return r.set(key, item);
      }, new Map).values()];

      const dataActIntermediaWithoutValues = dataAgrupacio.filter(element => element.act_intermitja === '')
      dataActIntermediaValues = dataActIntermediaValues.sort((a, b) => (a.cost_total > b.cost_total) ? -1 : 1)
      this.dataActIntermediaTotal = [...dataActIntermediaValues, ...dataActIntermediaWithoutValues]

    },
    agrupacioDataFilter(actIntermedia) {
      const dataGroupIntermedia = this.items.filter(element => element.act_intermitja === actIntermedia)
      this.dataGroupIntermedia = dataGroupIntermedia
      if (actIntermedia === '') {
        this.totalElements = 0
      } else {
        this.totalElements = dataGroupIntermedia.length
      }
    },
    loadTable(value) {
      this.$emit('changeTableHandler', value)
    }
  }
}
</script>
