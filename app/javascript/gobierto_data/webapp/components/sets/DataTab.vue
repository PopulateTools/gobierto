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
        :is-fork-prompt-visible="isForkPromptVisible"
        :is-query-saving-prompt-visible="isQuerySavingPromptVisible"
        :query-name="queryName"
        :enabled-fork-button="enabledForkButton"
        :enabled-revert-button="enabledRevertButton"
        :enabled-query-saved-button="enabledQuerySavedButton"
        :show-revert-query="showRevertQuery"
        :show-private="showPrivate"
        :is-user-logged="isUserLogged"
        :query-input-focus="queryInputFocus"
        :show-private-public-icon="showPrivatePublicIcon"
        :reset-private="resetPrivate"
        :registration-disabled="registrationDisabled"
      />
      <SQLEditorCode
        :object-columns="objectColumns"
        :query-stored="queryStored"
        :query-duration="queryDuration"
        :query-error="queryError"
        :table-name="tableName"
        :is-user-logged="isUserLogged"
        :registration-disabled="registrationDisabled"
      />
      <SQLEditorResults
        v-if="items.length"
        :array-formats="arrayFormats"
        :object-columns="objectColumns"
        :config-map="configMap"
        :enabled-viz-saved-button="enabledVizSavedButton"
        :is-viz-modified="isVizModified"
        :is-query-saved="isQuerySaved"
        :is-viz-saved="isVizSaved"
        :is-viz-saving-prompt-visible="isVizSavingPromptVisible"
        :items="items"
        :is-user-logged="isUserLogged"
        :query-stored="queryStored"
        :viz-input-focus="vizInputFocus"
        :viz-name="vizName"
        :viz-id="vizId"
        :show-private-public-icon-viz="showPrivatePublicIconViz"
        :registration-disabled="registrationDisabled"
      />
    </div>
  </div>
</template>
<script>
import SQLEditorCode from './data/SQLEditorCode.vue';
import SQLEditorHeader from './data/SQLEditorHeader.vue';
import SQLEditorResults from './data/SQLEditorResults.vue';
import '../../../lib/sql-theme.css'

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
    objectColumns: {
      type: Object,
      default: () => {}
    },
    configMap: {
      type: Object,
      default: () => {}
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
    isVizModified: {
      type: Boolean,
      default: false
    },
    isQuerySavingPromptVisible: {
      type: Boolean,
      default: false
    },
    isVizSavingPromptVisible: {
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
    enabledQuerySavedButton: {
      type: Boolean,
      default: false
    },
    enabledVizSavedButton: {
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
    isVizSaved: {
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
    },
    queryInputFocus: {
      type: Boolean,
      default: false
    },
    vizInputFocus: {
      type: Boolean,
      default: false
    },
    showPrivatePublicIcon: {
      type: Boolean,
      default: false
    },
    showPrivatePublicIconViz: {
      type: Boolean,
      default: false
    },
    resetPrivate: {
      type: Boolean,
      default: false
    },
    vizName: {
      type: String,
      default: ''
    },
    vizId: {
      type: Number,
      default: 0
    },
    registrationDisabled: {
      type: Boolean,
      default: false
    }
  }
}

</script>
