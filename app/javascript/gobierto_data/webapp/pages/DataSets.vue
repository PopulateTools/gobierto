<template>
  <div class="pure-u-1 pure-u-lg-3-4 gobierto-data-layout-column">
    <NavDatasets
      :active-tab="activeTabIndex"
      :array-queries="arrayQueries"
      :public-queries="publicQueries"
      :array-formats="arrayFormats"
      :array-columns="arrayColumns"
      :number-rows="numberRows"
      :table-name="tableName"
      :dataset-id="datasetId"
      :title-dataset="titleDataset"
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
    activeTab: {
      type: Number,
      default: 0
    },
    datasetId: {
      type: Number,
      default: 0
    },
    arrayQueries: {
      type: Array,
      required: true
    },
    numberRows: {
      type: Number,
      required: true
    },
    publicQueries: {
      type: Array,
      required: true
    },
    arrayFormats: {
      type: Object,
      required: true
    },
    arrayColumns: {
      type: Object,
      required: true
    },
    tableName: {
      type: String,
      required: true
    },
    titleDataset: {
      type: String,
      required: true
    }
  },
  data() {
    return {
      activeTabIndex: 0
    }
  }
}
</script>
