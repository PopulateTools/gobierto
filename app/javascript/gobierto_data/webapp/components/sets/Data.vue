<template>
  <div class="gobierto-data-sets-nav--tab-container">
    <SQLEditor
      id="codemirror"
      :slug-name="item"
      :array-queries="arrayQueries"
      :dataset-id="datasetId"
    />
  </div>
</template>

<script>
import SQLEditor from "./SQLEditor.vue";
export default {
  name: "Data",
  components: {
    SQLEditor
  },
  props: {
    item: {
      type: String,
      required: true
    },
    arrayQueries: {
      type: Array,
      required: true
    },
    datasetId: {
      type: Number,
      required: true
    }
  }
}
</script>
