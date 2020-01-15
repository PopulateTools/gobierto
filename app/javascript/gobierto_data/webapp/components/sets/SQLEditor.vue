<template>
  <div>
    <div class="gobierto-data-sql-editor">
      <SQLEditorHeader />
      <SQLEditorCode />
    </div>
  </div>
</template>
<script>
import SQLEditorCode from "./SQLEditorCode.vue";
import SQLEditorHeader from "./SQLEditorHeader.vue";

export default {
  name: 'SQLEditor',
  components: {
    SQLEditorCode,
    SQLEditorHeader
  }
}
</script>
