<template>
  <div class="gobierto-data-sets-nav--tab-container">
    <SQLEditor
      id="codemirror"
      :table-name="tableName"
      :dataset-id="datasetId"
      :array-queries="arrayQueries"
      :public-queries="publicQueries"
      :array-formats="arrayFormats"
      :array-columns="arrayColumns"
      :number-rows="numberRows"
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
    datasetId: {
      type: Number,
      required: true
    },
    tableName: {
      type: String,
      required: true
    },
    arrayColumns: {
      type: Object,
      required: true
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
    }
  }
}
</script>
