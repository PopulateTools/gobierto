<template>
  <div class="pure-u-1 pure-u-lg-3-4 gobierto-data-layout-column">
    <DataSetsContent
      :active-dataset-tab="activeDatasetTab"
      @active-tab="activeTabIndex = $event"
    />
  </div>
</template>
<script>
import DataSetsContent from "./../components/sets/DataSetsContent.vue"

export default {
  name: "DataSets",
  components: {
    DataSetsContent
  },
  props: {
    activeDatasetTab: {
      type: Number,
      default: 0
    }
  }
}
</script>
