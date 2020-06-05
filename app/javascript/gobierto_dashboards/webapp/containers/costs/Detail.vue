<template>
  <div class="pure-u-1 gutters m_b_1">
    <h2 id="gobierto-dashboards-title-detail" class="gobierto-dashboards-title">
      {{ labelDetail }}
    </h2>
    <Table
      :items="items"
      :year="year"
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
  props: {
    items: {
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
      labelDetail: I18n.t("gobierto_dashboards.dashboards.costs.detail") || "",
    }
  }
}
</script>
