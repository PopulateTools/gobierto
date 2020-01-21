<template>
  <div class="gobierto-data-btn-download-data-modal arrow-top gobierto-data-sql-editor-recent-queries">
    <button
      v-for="(item, index) in items"
      :key="index"
      :data-id="item | replace()"
      class="gobierto-data-recent-queries-list-element"
      @click="runRecentQuery(index, item)"
    >
      {{ item | truncate(30, '...') | replace() }}
    </button>
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
    runRecentQuery(value, code) {
      this.$root.$emit('runRencentQuery', value, false)
      this.$root.$emit('updateCode', code)
    }
  }
}
</script>
