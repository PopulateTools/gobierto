<template>
  <div class="gobierto-data-btn-download-data-modal arrow-top gobierto-data-sql-editor-recent-queries">
    <div class="gobierto-data-btn-download-data-modal-container">
      <button
        v-for="(item, index) in items"
        :key="index"
        :data-id="item | replace()"
        class="gobierto-data-recent-queries-list-element"
        @click="runRecentQuery(item)"
      >
        {{ item | truncate(50, '...') | replace() }}
      </button>
    </div>
  </div>
</template>
<script>
export default {
  name: "RecentQueries",
  filters: {
    truncate: function (text, length, suffix) {
        return text.substring(0, length) + suffix;
    },
    replace: function(text) {
      return text.replace(/%20/g, ' ').replace(/%/g, ' ');
    }
  },
  data() {
    return {
      items: []
    }
  },
  created() {
    this.$root.$on('showRecentQueries', this.createList)
  },
  methods: {
    createList(queries) {
      this.items = queries
    },
    runRecentQuery(code) {
      this.queryEditor = unescape(code)
      this.$root.$emit('runRencentQuery', this.queryEditor)
      this.$root.$emit('updateCode', code)
    }
  }
}
</script>
