<template>
  <div class="gobierto-data-sql-editor-recent-queries arrow-top">
    <div class="gobierto-data-btn-download-data-modal-container">
      <button
        v-for="(item, index) in orderItems"
        ref="button"
        :key="index"
        :class="{'active-query': currentItem === index}"
        :data-id="item.text"
        class="gobierto-data-recent-queries-list-element"
        @click="runRecentQuery(item.text)"
      >
        {{ item.text }}
      </button>
    </div>
  </div>
</template>

<script>
export default {
  name: "RecentQueries",
  props: {
    tableName: {
      type: String,
      required: true
    }
  },
  data() {
    return {
      orderItems: null,
      currentItem: 0
    }
  },
  created() {
    this.$root.$on('showRecentQueries', this.createList)
    this.$root.$on('storeQuery', this.createList)
  },
  mounted() {
    document.addEventListener("keyup", this.nextItem);
  },
  methods: {
    nextItem () {
      if (event.keyCode == 38 && this.currentItem > 0) {
        this.currentItem--
      } else if (event.keyCode == 40 && this.currentItem < this.items.length) {
        this.currentItem++
      }
    },
    createList(queries) {
      if (queries === null || queries === undefined) {
        this.orderItems = []
      } else {
        const items = queries
        const filterItemsByDataset = items.filter(item => item.dataset === this.tableName);
        const filterItemsByQuery = filterItemsByDataset.filter(item => item.text.includes(this.tableName));
        this.orderItems = filterItemsByQuery.reverse()
      }
    },
    runRecentQuery(code) {
      console.log('DEPRECATED CODE runRecentQuery', code);
    }
  }
}
</script>
