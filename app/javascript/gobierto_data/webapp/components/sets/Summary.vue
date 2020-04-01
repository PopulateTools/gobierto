<template>
  <div class="gobierto-data-sets-nav--tab-container">
    <Info
      :description-dataset="descriptionDataset"
      :category-dataset="categoryDataset"
      :frequency-dataset="frequencyDataset"
      :date-updated="dateUpdated"
    />
    <keep-alive>
      <DownloadButton
        :class="[
          directionLeft ? 'modal-left': 'modal-right'
        ]"
        :array-formats="arrayFormats"
        class="arrow-top"
      />
    </keep-alive>
    <Resources :resources-list="resourcesList" />
    <Queries
      :dataset-id="datasetId"
      :private-queries="privateQueries"
      :public-queries="publicQueries"
    />
  </div>
</template>

<script>
import Resources from "./../commons/Resources.vue";
import Info from "./../commons/Info.vue";
import DownloadButton from "./../commons/DownloadButton.vue";
import Queries from "./../commons/Queries.vue";

export default {
  name: "Summary",
  components: {
    Resources,
    Queries,
    DownloadButton,
    Info
  },
  props: {
    datasetId: {
      type: Number,
      required: true
    },
    privateQueries: {
      type: Array,
      default: () => []
    },
    publicQueries: {
      type: Array,
      default: () => []
    },
    arrayFormats: {
      type: Object,
      default: () => {}
    },
    descriptionDataset: {
      type: String,
      default: ''
    },
    categoryDataset: {
      type: String,
      default: ''
    },
    frequencyDataset: {
      type: String,
      default: ''
    },
    resourcesList: {
      type: Array,
      required: true,
      default: () => []
    },
    dateUpdated: {
      type: String,
      default: ''
    }
  },
  data() {
    return {
      isActive: false,
      directionLeft: true
    }
  }
}
</script>
