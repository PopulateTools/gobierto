<template>
  <div class="gobierto-data-sets-nav--tab-container">
    <div class="gobierto-data-sql-editor">
      <SQLEditorHeader
        v-if="publicQueries.length"
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
        :query-number-rows="queryNumberRows"
        :query-duration="queryDuration"
        :query-error="queryError"
      />
      <SQLEditorResults
        v-if="items.length"
        :array-formats="arrayFormats"
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
    publicQueries: {
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
    arrayFormats: {
      type: Object,
      required: true
    },
    items: {
      type: Array,
      default: () => []
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
    queryName: {
      type: String,
      default: null
    },
    queryNumberRows: {
      type: Number,
      default: 0
    },
    queryDuration: {
      type: Number,
      default: 0
    },
    queryError: {
      type: String,
      default: null
    },
  },
}

</script>
