<template>
  <div class="gobierto-data-sets-nav--tab-container">
    <SQLEditor
      id="codemirror"
      :slug-name="item"
      :table-name="tableName"
      :array-queries="arrayQueries"
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
    tableName: {
      type: String,
      required: true
    },
    arrayQueries: {
      type: Array,
      required: true
    }
  }
}
</script>
