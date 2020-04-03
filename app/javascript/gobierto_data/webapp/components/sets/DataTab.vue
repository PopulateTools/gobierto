<template>
  <div class="gobierto-data-sets-nav--tab-container">
    <div class="gobierto-data-sql-editor">
      <SQLEditorHeader
        v-if="publicQueries.length"
        :private-queries="privateQueries"
        :public-queries="publicQueries"
        :dataset-id="datasetId"
        :table-name="tableName"
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
        v-if="items"
        :array-formats="arrayFormats"
        :items="items"
        :link="link"
        :table-name="tableName"
        :active-tab="activeTabIndex"
        :private-queries="privateQueries"
        :dataset-id="datasetId"
        :current-query="queryStored"
        @active-tab="activeTabIndex = $event"
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
    tableName: {
      type: String,
      required: true
    },
    privateQueries: {
      type: Array,
      required: true
    },
    arrayColumns: {
      type: Object,
      required: true
    },
    publicQueries: {
      type: Array,
      required: true
    },
    arrayFormats: {
      type: Object,
      required: true
    },
    datasetId: {
      type: Number,
      required: true
    },
    items: {
      type: Array,
      default: () => []
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
  data() {
    return {
      activeTabIndex: 0,
      link: '',
      localTableName : ''
    }
  },
  created() {
    this.localTableName = this.tableName

    if (localStorage.getItem('recentQueries')) {
      try {
        this.recentQueries = JSON.parse(localStorage.getItem('recentQueries'));
        this.localQueries = JSON.parse(localStorage.getItem('savedData'));
        this.addRecentQuery()
      } catch (e) {
        localStorage.removeItem('recentQueries');
      }
    }
  },
  methods: {
    addRecentQuery() {
      if (!this.newRecentQuery) {
        return;
      }

      if (Object.values(this.recentQueries).indexOf(this.newRecentQuery) > -1) {
        this.$root.$emit('storeQuery', this.recentQueries)
      } else {
        this.recentQueries.push(this.newRecentQuery);
        localStorage.setItem('recentQueries', JSON.stringify(this.recentQueries));

        if (this.localTableName === this.tableName) {
          this.orderRecentQueries = [{
            dataset: this.tableName,
            text: this.newRecentQuery
          }]
          this.newRecentQuery = '';

          const tempRecentQueries = [ ...this.localQueries, ...this.orderRecentQueries ]
          this.totalRecentQueries = tempRecentQueries
          this.orderRecentQueries = []
          localStorage.setItem("savedData", JSON.stringify(this.totalRecentQueries));

          this.saveRecentQuery(this.totalRecentQueries);
        }
      }
    },
    saveRecentQuery() {
      localStorage.setItem("savedData", JSON.stringify(this.totalRecentQueries));
      this.$root.$emit('storeQuery', this.totalRecentQueries)
    },
    loadRecentQuery() {
      this.totalRecentQueries = this.localQueries
      this.$root.$emit('storeQuery', this.totalRecentQueries)
    },
    saveNewRecentQuery(query) {
      this.newRecentQuery = query
      this.queryStored = query
      this.addRecentQuery()
    },
  }
}

</script>
