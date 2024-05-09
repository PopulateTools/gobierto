<template>
  <div class="pure-u-1 m_b_1">
    <h2
      id="gobierto-visualizations-title-detail"
      class="gobierto-visualizations-title"
    >
      {{ labelDetail }}
    </h2>
    <component
      :is="currentComponent"
      :items="items"
      :items-filter="itemsFilter"
      :year="year"
      @changeTableHandler="changeTableComponent"
    />
  </div>
</template>
<script>
const COMPONENTS_TABLE = [
  () => import('./TableFirstLevel.vue'),
  () => import('./TableSecondLevel.vue'),
  () => import('./TableItem.vue')
];

export default {
  name: 'Table',
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
    },
    baseTitle: {
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
      labelIncome: I18n.t("gobierto_visualizations.visualizations.costs.income") || "",
      labelCoverage: I18n.t("gobierto_visualizations.visualizations.costs.coverage") || "",
      labelDetail: I18n.t("gobierto_visualizations.visualizations.costs.detail") || "",
      currentComponent: 0,
    }
  },
  watch: {
    $route(to) {
      if (to.name === 'TableSecondLevel') {
        const { params: { id: id } } = to
        this.currentComponent = COMPONENTS_TABLE[1];
        this.changeTitleSecondLevel(id)
      } else if ( to.name === 'TableItem') {
        const { params: { item: item } } = to
        this.currentComponent = COMPONENTS_TABLE[2];
        this.changeTitleItem(item)
      } else {
        this.currentComponent = COMPONENTS_TABLE[0];
      }
    }
  },
  created(){
    this.currentComponent = COMPONENTS_TABLE[0];
    const {
      name: nameComponent,
      params: {
        id: id,
        item: item
      }
    } = this.$route;
    if (nameComponent === 'TableSecondLevel') {
      this.currentComponent = COMPONENTS_TABLE[1];
      this.changeTitleSecondLevel(id)
    } else if ( nameComponent === 'TableItem') {
      this.currentComponent = COMPONENTS_TABLE[2];
      this.changeTitleItem(item)
    } else {
      this.currentComponent = COMPONENTS_TABLE[0];
    }
  },
  methods: {
    changeTableComponent(value) {
      this.currentComponent = COMPONENTS_TABLE[value];
    },
    changeTitleSecondLevel(id) {
      const filterItems = this.itemsFilter.filter(element => element.ordreagrup === id)

      const [{
        agrupacio: titleAgrupacio
      }] = filterItems

      this.updateTitle(titleAgrupacio)
    },
    changeTitleItem(id) {
      const filterItem = this.items.filter(element => element.codiact === id)

      const [{
        nomact: titleItem
      }] = filterItem

      this.updateTitle(titleItem)
    },
    updateTitle(newTitle) {
      this.$nextTick(() => {
        this.$nextTick(() => {
          const baseTitle = this.baseTitle;
          let title = `${newTitle} ${baseTitle}`
          document.title = title;
        });
      });
    }
  }
}
</script>
