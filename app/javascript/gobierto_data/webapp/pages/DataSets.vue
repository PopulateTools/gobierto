<template>
  <div class="pure-u-1 pure-u-lg-3-4 gobierto-data-layout-column">
    <NavDatasets
      :items="items"
      @active-tab="activeTabIndex = $event"
    />
  </div>
</template>
<script>
import NavDatasets from "./../components/sets/Nav.vue"

export default {
  name: "DataSets",
  components: {
    NavDatasets
  },
  props: {
    items: {
      type: Object,
      default: () => []
    }
  },
  data() {
    return {
      activeTabIndex: 0
    }
  }
}
</script>
