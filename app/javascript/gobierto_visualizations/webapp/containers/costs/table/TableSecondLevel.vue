<template>
  <div>
    <TableHeader>
      <router-link
        :to="{ path:`/visualizaciones/costes/${$route.params.year}`}"
        class="gobierto-visualizations-table-header--link-top"
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
      @filter-children="agrupacioDataFilter"
      @load-table="loadTable"
    />
  </div>
</template>
<script>
import TableHeader from './TableHeader.vue'
import TableRow from './TableRow.vue'
import TableSubHeader from './TableSubHeader.vue'
import { VueFiltersMixin } from '../../../../../lib/vue/filters'

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
      labelTotal: I18n.t("gobierto_visualizations.visualizations.costs.total") || "",
      labelCostPerInhabitant: I18n.t("gobierto_visualizations.visualizations.costs.cost_per_inhabitant") || "",
      labelCostDirect: I18n.t("gobierto_visualizations.visualizations.costs.cost_direct") || "",
      labelCostIndirect: I18n.t("gobierto_visualizations.visualizations.costs.cost_indirect") || "",
      labelCostInhabitant: I18n.t("gobierto_visualizations.visualizations.costs.cost_inhabitant") || "",
      labelCostTotal: I18n.t("gobierto_visualizations.visualizations.costs.total") || "",
      labelIncome: I18n.t("gobierto_visualizations.visualizations.costs.income") || "",
      labelCoverage: I18n.t("gobierto_visualizations.visualizations.costs.coverage") || "",
      labelActivities: I18n.t("gobierto_visualizations.visualizations.costs.activities") || "",
      labelSeeAll: I18n.t("gobierto_visualizations.visualizations.costs.see_all") || "",
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
    const el = this.$el.getElementsByClassName('gobierto-visualizations-table-header--nav')[0];
    if (el) {
      el.scrollIntoView({ behavior: "smooth" });
    }
  },
  methods: {
    intermediaData() {
      const filterActIntermedia = this.$route.params.id
      let dataAgrupacio = this.items.filter(element => element.ordreagrup === filterActIntermedia)
      let dataActIntermedia = dataAgrupacio.filter(element => element.actintermitja !== '')
      let dataActIntermediaValues = [...dataActIntermedia.reduce((r, o) => {
        let key = o.actintermitja

        const item = r.get(key) || Object.assign({}, o, {
          costdirecte: 0,
          costindirecte: 0,
          costtotal: 0,
          ingressos: 0,
          total: 0,
          nomact: '',
          totalPerHabitant: 0
        });

        item.costdirecte += o.costdirecte
        item.costindirecte += o.costindirecte
        item.costtotal += o.costtotal
        item.ingressos += o.ingressos
        item.total += (o.total || 0) + 1
        item.nomact = o.actintermitja
        item.totalPerHabitant = item.costtotal / o.population

        return r.set(key, item);
      }, new Map).values()];

      const dataActIntermediaWithoutValues = dataAgrupacio.filter(element => element.actintermitja === '')
      dataActIntermediaValues = dataActIntermediaValues.sort((a, b) => (a.costtotal > b.costtotal) ? -1 : 1)
      this.dataActIntermediaTotal = [...dataActIntermediaValues, ...dataActIntermediaWithoutValues]

    },
    agrupacioDataFilter(actIntermedia) {
      const dataGroupIntermedia = this.items.filter(element => element.actintermitja === actIntermedia)
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
