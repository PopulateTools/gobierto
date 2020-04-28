<template>
  <div class="gobierto-data-sets-nav--tab-container">
    <div class="gobierto-data-sql-editor">
      <SQLEditorHeader
        :private-queries="privateQueries"
        :public-queries="publicQueries"
        :recent-queries="recentQueries"
        :is-query-running="isQueryRunning"
        :is-query-modified="isQueryModified"
        :query-name="queryName"
      />
      <SQLEditorCode
        :array-columns="arrayColumns"
        :query-stored="queryStored"
        :query-default="queryDefault"
        :query-duration="queryDuration"
        :query-error="queryError"
        :query-revert="queryRevert"
        :reset-query-default="resetQueryDefault"
        :revert-query-saved="revertQuerySaved"
      />
      <SQLEditorResults
        v-if="items.length"
        :array-formats="arrayFormats"
        :array-columns-query="arrayColumnsQuery"
        :items="items"
      />
    </div>
  </div>
</template>
<script>
import SQLEditorCode from "./data/SQLEditorCode.vue";
import SQLEditorHeader from "./data/SQLEditorHeader.vue";
import SQLEditorResults from "./data/SQLEditorResults.vue";
import "./../../../lib/sql-theme.css"

export default {
  name: 'DataTab',
  components: {
    SQLEditorCode,
    SQLEditorHeader,
    SQLEditorResults
  },
  props: {
    privateQueries: {
      type: Array,
      required: true
    },
    recentQueries: {
      type: Array,
      default: () => []
    },
    arrayColumns: {
      type: Object,
      required: true
    },
    arrayColumnsQuery: {
      type: Array,
      default: () => []
    },
    publicQueries: {
      type: Array,
      required: true
    },
    arrayFormats: {
      type: Object,
      required: true
    },
    items: {
      type: String,
      default: ''
    },
    isQueryRunning: {
      type: Boolean,
      default: false
    },
    isQueryModified: {
      type: Boolean,
      default: false
    },
    queryStored: {
      type: String,
      default: null
    },
    queryDefault: {
      type: String,
      default: null
    },
    queryRevert: {
      type: String,
      default: null
    },
    queryName: {
      type: String,
      default: null
    },
    queryDuration: {
      type: Number,
      default: 0
    },
    queryError: {
      type: String,
      default: null
    },
    resetQueryDefault: {
      type: Boolean,
      default: false
    },
    revertQuerySaved: {
      type: Boolean,
      default: false
    },
  }
}

</script>
