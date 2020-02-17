<template>
  <div>
    <div class="gobierto-data-sql-editor">
      <SQLEditorHeader
        :array-queries="arrayQueries"
        :public-queries="publicQueries"
        :dataset-id="datasetId"
        :table-name="tableName"
      />
      <SQLEditorCode
        :table-name="tableName"
      />
      <SQLEditorTabs
        :array-formats="arrayFormats"
        :active-tab="activeTabIndex"
        :array-queries="arrayQueries"
        @active-tab="activeTabIndex = $event"
      />
    </div>
  </div>
</template>
<script>
import SQLEditorCode from "./SQLEditorCode.vue";
import SQLEditorHeader from "./SQLEditorHeader.vue";
import SQLEditorTabs from "./SQLEditorTabs.vue";

export default {
  name: 'SQLEditor',
  components: {
    SQLEditorCode,
    SQLEditorHeader,
    SQLEditorTabs
  },
  props: {
    tableName: {
      type: String,
      required: true
    },
    arrayQueries: {
      type: Array,
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
    }
  },
  data() {
    return {
      activeTabIndex: 0,
      recentQueries: [],
      newRecentQuery: null
    }
  },
  created(){
    this.$root.$on('activateModalRecent', this.loadRecentQuery)
    this.$root.$on('postRecentQuery', this.saveNewRecentQuery)
    if (localStorage.getItem('recentQueries')) {
      try {
        this.recentQueries = JSON.parse(localStorage.getItem('recentQueries'));
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
        this.newRecentQuery = '';
        this.saveRecentQuery();
      }
    },
    saveRecentQuery() {
      const parsed = JSON.stringify(this.recentQueries);
      localStorage.setItem('recentQueries', parsed);
      this.$root.$emit('storeQuery', this.recentQueries)
    },
    loadRecentQuery() {
      this.$root.$emit('storeQuery', this.recentQueries)
    },
    saveNewRecentQuery(query) {
      this.newRecentQuery = query
      this.addRecentQuery()
    }
  }
}
</script>
