<template>
  <div class="pure-u-1 gutters m_b_1">
    <Table
      :items="items"
      :data="data"
    />
  </div>
</template>

<script>
import Table from './Table.vue'
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
    data: {
      type: Array,
      default: () => []
    }
  },
}
</script>
