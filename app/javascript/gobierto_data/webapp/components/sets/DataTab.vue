<template>
  <div class="gobierto-data-sets-nav--tab-container">
    <div class="gobierto-data-sql-editor">
      <SQLEditorHeader
        :private-queries="privateQueries"
        :public-queries="publicQueries"
        :recent-queries="recentQueries"
        :is-query-running="isQueryRunning"
        :is-query-modified="isQueryModified"
        :is-query-saved="isQuerySaved"
        :is-saving-prompt-visible="isSavingPromptVisible"
        :is-fork-prompt-visible="isForkPromptVisible"
        :query-name="queryName"
        :enabled-saved-button="enabledSavedButton"
        :enabled-fork-button="enabledForkButton"
        :enabled-revert-button="enabledRevertButton"
        :show-revert-query="showRevertQuery"
        :show-private="showPrivate"
        :is-user-logged="isUserLogged"
      />
      <SQLEditorCode
        :array-columns="arrayColumns"
        :query-stored="queryStored"
        :query-duration="queryDuration"
        :query-error="queryError"
        :table-name="tableName"
      />
      <SQLEditorResults
        v-if="items.length"
        :array-formats="arrayFormats"
        :array-columns-query="arrayColumnsQuery"
        :query-stored="queryStored"
        :enabled-saved-button="enabledSavedButton"
        :is-query-modified="isQueryModified"
        :is-query-saved="isQuerySaved"
        :is-saving-prompt-visible="isSavingPromptVisible"
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
      default: () => []
    },
    recentQueries: {
      type: Array,
      default: () => []
    },
    arrayColumns: {
      type: Object,
      default: () => {}
    },
    arrayColumnsQuery: {
      type: Array,
      default: () => []
    },
    publicQueries: {
      type: Array,
      default: () => []
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
    isSavingPromptVisible: {
      type: Boolean,
      default: false
    },
    isForkPromptVisible: {
      type: Boolean,
      default: true
    },
    queryStored: {
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
    enabledSavedButton: {
      type: Boolean,
      default: false
    },
    enabledForkButton: {
      type: Boolean,
      default: false
    },
    enabledRevertButton: {
      type: Boolean,
      default: false
    },
    showRevertQuery: {
      type: Boolean,
      default: false
    },
    showPrivate: {
      type: Boolean,
      default: false
    },
    isQuerySaved: {
      type: Boolean,
      default: false
    },
    tableName: {
      type: String,
      default: ''
    },
    isUserLogged: {
      type: Boolean,
      default: false
    }
  }
}

</script>
