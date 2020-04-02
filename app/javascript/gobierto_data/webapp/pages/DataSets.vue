<template>
  <div class="pure-u-1 pure-u-lg-3-4 gobierto-data-layout-column">
    <NavSets
      :active-dataset-tab="activeDatasetTab"
      @active-tab="activeTabIndex = $event"
    />
  </div>
</template>
<script>
import NavSets from "./../components/sets/Nav.vue"

export default {
  name: "DataSets",
  components: {
    NavSets
  },
  props: {
    activeDatasetTab: {
      type: Number,
      default: 0
    }
  }
}
</script>
