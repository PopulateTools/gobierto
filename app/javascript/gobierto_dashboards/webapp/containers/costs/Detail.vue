<template>
  <div class="pure-u-1 gutters m_b_1">
    <h2 class="gobierto-dashboards-title">{{ labelDetail }}</h2>
    <Table
      :items="items"
      :data="data"
    />
  </div>
</template>

<script>
import Table from './table/Table.vue'
export default {
  name: 'Detail',
  components: {
    Table
  },
  data() {
    return {
      labelDetail: I18n.t("gobierto_dashboards.dashboards.costs.detail") || "",
    }
  },
  props: {
    items: {
      type: Array,
      default: () => []
    },
    data: {
      type: Array,
      default: () => []
    }
  },
}
</script>
