<template>
  <div
    v-if="orderItems"
    class="gobierto-data-sql-editor-recent-queries arrow-top"
  >
    <div class="gobierto-data-btn-download-data-modal-container">
      <button
        v-for="(item, index) in orderItems"
        :key="index"
        :data-id="item.text | replace()"
        class="gobierto-data-recent-queries-list-element"
        @click="runRecentQuery(item.text)"
      >
        {{ item.text }}
      </button>
    </div>
  </div>
</template>
<script>
import axios from 'axios'
import { baseUrl } from "./../../../lib/commons.js";
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
  props: {
    tableName: {
      type: String,
      required: true
    }
  },
  data() {
    return {
      items: [],
      filterItemsByDataset: [],
      filterItemsByQuery: [],
      orderItems: []
    }
  },
  created() {
    this.$root.$on('showRecentQueries', this.createList)
    this.$root.$on('storeQuery', this.createList)
  },
  methods: {
    createList(queries) {
      this.items = queries
      this.filterItemsByDataset = this.items.filter(item => item.dataset.includes(this.tableName));
      this.filterItemsByQuery = this.filterItemsByDataset.filter(item => item.text.includes(this.tableName));
      this.orderItems = this.filterItemsByQuery.reverse()
    },
    runRecentQuery(code) {
      this.showSpinner = true;
      this.queryEditor = encodeURI(code)
      this.$root.$emit('postRecentQuery', code)
      this.$root.$emit('showMessages', false)
      this.$root.$emit('updateCode', code)
      this.endPoint = `${baseUrl}/data`
      this.url = `${this.endPoint}?sql=${this.queryEditor}`
      axios
        .get(this.url)
        .then(response => {
          this.data = []
          this.keysData = []
          this.rawData = response.data
          this.meta = this.rawData.meta
          this.data = this.rawData.data

          this.queryDurationRecors = [this.meta.rows, this.meta.duration]

          this.keysData = Object.keys(this.data[0])

          this.$root.$emit('recordsDuration', this.queryDurationRecors)
          this.$root.$emit('sendData', this.keysData, this.data)
          this.$root.$emit('showMessages', true)

        })
        .catch(error => {
          const messageError = error.response.data.errors[0].sql
          this.$root.$emit('apiError', messageError)

          this.data = []
          this.keysData = []
          this.$root.$emit('sendData', this.keysData, this.data)
        })

        setTimeout(() => {
          this.showSpinner = false
        }, 300)
    }
  }
}
</script>
