<template>
  <div class="gobierto-data-btn-download-data-modal arrow-top gobierto-data-sql-editor-recent-queries">
    <button
      v-for="(item, index) in items"
      :key="index"
      class="gobierto-data-resources-list-element"
      @click="runRecentQuery(index)"
    >
      {{ index }}
    </button>
  </div>
</template>
<script>
export default {
  name: "RecentQueries",
  data() {
    return {
      items: []
    }
  },
  created() {
    this.$root.$on('showRecentQueries', this.createList)
  },
  methods: {
    createList(value) {
      this.items = value
    },
    runRecentQuery(value) {
      this.$root.$emit('runRencentQuery', value)
    }
  }
}
</script>
