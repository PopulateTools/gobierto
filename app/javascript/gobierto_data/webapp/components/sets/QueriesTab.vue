<template>
  <div class="gobierto-data-sets-nav--tab-container">
    <Queries
      :dataset-id="datasetId"
      :private-queries="privateQueries"
      :public-queries="publicQueries"
    />
  </div>
</template>
<script>
import Queries from "./../commons/Queries.vue";

export default {
  name: "QueriesTab",
  components: {
    Queries
  },
  props: {
    privateQueries: {
      type: Array,
      required: true
    },
    publicQueries: {
      type: Array,
      required: true
    },
    datasetId: {
      type: Number,
      required: true
    },
  }
}
</script>
