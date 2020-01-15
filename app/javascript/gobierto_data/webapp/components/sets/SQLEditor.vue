<template>
  <div>
    <div class="gobierto-data-sql-editor">
      <SQLEditorHeader />
      <SQLEditorCode />
      <SQLEditorTable />
    </div>
  </div>
</template>
<script>
import SQLEditorCode from "./SQLEditorCode.vue";
import SQLEditorHeader from "./SQLEditorHeader.vue";
import SQLEditorTable from "./SQLEditorTable.vue";

export default {
  name: 'SQLEditor',
  components: {
    SQLEditorCode,
    SQLEditorHeader,
    SQLEditorTable
  }
}
</script>
