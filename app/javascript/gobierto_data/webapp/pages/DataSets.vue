<template>
  <div class="pure-u-1 pure-u-lg-3-4 gobierto-data-layout-column">
    <NavDatasets
      :active-dataset-tab="activeDatasetTab"
      @active-tab="activeTabIndex = $event"
    />
  </div>
</template>
<script>
import NavDatasets from "./../components/sets/Nav.vue"

export default {
  name: "DataSets",
  props: {
    activeDatasetTab: {
      type: Number,
      default: 0
    }
  },
  components: {
    NavDatasets
  }
}
</script>
