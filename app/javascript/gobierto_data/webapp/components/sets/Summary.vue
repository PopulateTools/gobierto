<template>
  <div class="gobierto-data-sets-nav--tab-container">
    <Info
      :description-dataset="descriptionDataset"
      :category-dataset="categoryDataset"
      :frequency-dataset="frequencyDataset"
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
    <Resources :resource-list="resourcesList" />
    <Queries
      :array-queries="arrayQueries"
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
    arrayQueries: {
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
      required: true
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
