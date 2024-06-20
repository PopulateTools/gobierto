<template>
  <div class="gobierto-data-sql-editor-recent-queries arrow-top">
    <div class="gobierto-data-btn-download-data-modal-container">
      <template v-if="recentQueries.length">
        <button
          v-for="(sql, index) in recentQueries"
          ref="button"
          :key="index"
          :class="{'active-query': currentItem === index}"
          class="gobierto-data-recent-queries-list-element"
          @click="clickRunQueryHandler(sql)"
        >
          {{ sql }}
        </button>
      </template>
      <template v-else>
        <span class="gobierto-data-recent-queries-list-element">{{ labelEmptyRecentQueries }}</span>
      </template>
    </div>
  </div>
</template>

<script>
export default {
  name: "RecentQueries",
  props: {
    recentQueries: {
      type: Array,
      default: () => []
    },
  },
  data() {
    return {
      labelEmptyRecentQueries: I18n.t("gobierto_data.projects.emptyRecentQueries") || "",
      currentItem: 0
    }
  },
  created() {
    document.addEventListener("keydown", this.onKeyDownNextRecentItem)
  },
  beforeUnmount() {
    document.removeEventListener("keydown", this.onKeyDownNextRecentItem)
  },
  methods: {
    onKeyDownNextRecentItem(event) {

      const { keyCode } = event

      if (keyCode == 38 && this.currentItem > 0) {
        this.currentItem--
      } else if (keyCode === 40 && this.currentItem < this.recentQueries.length) {
        this.currentItem++
      } else if (keyCode === 13) {
        this.clickRunQueryHandler(this.recentQueries[this.currentItem])
      }
    },
    clickRunQueryHandler(code) {
      this.$root.$emit("setCurrentQuery", code);
      this.$root.$emit("runCurrentQuery");
    }
  }
}
</script>
